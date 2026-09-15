#!/usr/bin/env python3
"""Fetch base64 proxy subscriptions and render a sing-box config.

Input: a file with one subscription URL per line. Each subscription is a
base64 blob of share links (ss/vmess/vless/trojan/hysteria2). Output: a
complete sing-box config with a mixed inbound, one outbound per node, an
urltest auto-group and a manual selector, validated by `sing-box check`
before atomically replacing the previous config.

Secrets (subscription URLs, node credentials) only ever live in the URLs
file and the generated config (mode 600); nothing is embedded in the
Nix store.
"""

import argparse
import base64
import json
import os
import re
import subprocess
import sys
import urllib.parse
import urllib.request

LINK_RE = re.compile(r"(vmess|vless|trojan|ss|hysteria2|hy2)://[^\s'\"<>]+", re.IGNORECASE)
RESERVED_TAGS = {"proxy", "auto", "direct", "mixed-in"}
URLTEST_URL = "https://www.gstatic.com/generate_204"


def b64(data):
    """Decode standard or urlsafe base64, tolerating missing padding."""
    data = re.sub(r"\s+", "", data)
    pad = "=" * (-len(data) % 4)
    for decoder in (base64.b64decode, base64.urlsafe_b64decode):
        try:
            return decoder(data + pad).decode("utf-8")
        except (ValueError, UnicodeDecodeError):
            continue
    raise ValueError(f"not base64: {data[:40]!r}")


def truthy(value):
    return str(value).strip().lower() in ("1", "true", "yes")


def query_dict(link):
    return {
        k: v[0]
        for k, v in urllib.parse.parse_qs(urllib.parse.urlsplit(link).query, keep_blank_values=True).items()
    }


def tag_of(link, fallback):
    fragment = urllib.parse.urlsplit(link).fragment
    return urllib.parse.unquote(fragment) if fragment else fallback


def tls_block(sni, insecure=False, fingerprint=None, alpn=None):
    tls = {"enabled": True, "server_name": sni}
    if insecure:
        tls["insecure"] = True
    if fingerprint:
        tls["utls"] = {"enabled": True, "fingerprint": fingerprint}
    if alpn:
        if isinstance(alpn, str):
            alpn = [a.strip() for a in alpn.split(",") if a.strip()]
        tls["alpn"] = alpn
    return tls


def transport_block(net, host, path, service, header_type="none"):
    """Map the share-link transport fields onto a sing-box transport."""
    net = (net or "tcp").lower()
    path = urllib.parse.unquote(path or "") or "/"
    if net == "ws":
        transport = {"type": "ws", "path": path}
        if host:
            transport["headers"] = {"Host": host}
        return transport
    if net == "grpc":
        transport = {"type": "grpc"}
        if service:
            transport["service_name"] = urllib.parse.unquote(service)
        return transport
    if net == "httpupgrade":
        transport = {"type": "httpupgrade", "path": path}
        if host:
            transport["host"] = host
        return transport
    if net in ("h2", "http") or (net == "tcp" and header_type == "http"):
        transport = {"type": "http", "path": path}
        if host:
            transport["host"] = [host]
        return transport
    return None  # plain tcp / quic / xhttp: no transport section


def parse_ss(link):
    u = urllib.parse.urlsplit(link)
    netloc = u.netloc
    if "@" not in netloc:  # legacy: whole netloc is base64 of method:password@host:port
        raw = b64(netloc)
        userinfo, _, hostport = raw.rpartition("@")
        host, _, port = hostport.rpartition(":")
        method, _, password = userinfo.partition(":")
        port = int(port)
    else:  # SIP002: userinfo (base64 or plain) @ host:port
        host, port = u.hostname, u.port
        userinfo_raw = urllib.parse.unquote(netloc.rsplit("@", 1)[0])
        try:
            method, _, password = b64(userinfo_raw).partition(":")
        except ValueError:
            method, _, password = userinfo_raw.partition(":")
    if not host or not port:
        raise ValueError("missing host/port")
    out = {
        "type": "shadowsocks",
        "tag": tag_of(link, f"{host}:{port}"),
        "server": host,
        "server_port": port,
        "method": method,
        "password": password,
    }
    plugin = query_dict(link).get("plugin")
    if plugin:
        parts = plugin.split(";")
        out["plugin"] = {"simple-obfs": "obfs-local"}.get(parts[0], parts[0])
        if len(parts) > 1:
            out["plugin_opts"] = ";".join(parts[1:])
    return out


def parse_vmess(link):
    j = json.loads(b64(link[len("vmess://") :]))
    host = str(j["add"])
    port = int(j["port"])
    out = {
        "type": "vmess",
        "tag": str(j.get("ps") or f"{host}:{port}"),
        "server": host,
        "server_port": port,
        "uuid": str(j["id"]),
        "security": str(j.get("scy") or "auto"),
        "alter_id": int(j.get("aid") or 0),
    }
    if str(j.get("tls", "")).lower() in ("tls", "reality", "1", "true"):
        out["tls"] = tls_block(
            j.get("sni") or j.get("host") or host,
            truthy(j.get("allowInsecure") or ""),
            j.get("fp") or None,
            j.get("alpn"),
        )
    transport = transport_block(j.get("net"), j.get("host"), j.get("path"), j.get("path"), j.get("type"))
    if transport:
        out["transport"] = transport
    return out


def parse_vless(link):
    u = urllib.parse.urlsplit(link)
    if not u.hostname or not u.port:
        raise ValueError("missing host/port")
    q = query_dict(link)
    out = {
        "type": "vless",
        "tag": tag_of(link, f"{u.hostname}:{u.port}"),
        "server": u.hostname,
        "server_port": u.port,
        "uuid": u.username,
    }
    if q.get("flow"):
        out["flow"] = q["flow"]
    security = (q.get("security") or "").lower()
    if security in ("tls", "reality"):
        tls = tls_block(
            q.get("sni") or q.get("host") or u.hostname,
            truthy(q.get("allowInsecure") or q.get("insecure") or ""),
            q.get("fp"),
            q.get("alpn"),
        )
        if security == "reality":
            if not q.get("pbk"):
                raise ValueError("reality link without pbk")
            tls["reality"] = {"enabled": True, "public_key": q["pbk"], "short_id": q.get("sid") or ""}
        out["tls"] = tls
    transport = transport_block(q.get("type"), q.get("host"), q.get("path"), q.get("serviceName"))
    if transport:
        out["transport"] = transport
    return out


def parse_trojan(link):
    u = urllib.parse.urlsplit(link)
    if not u.hostname or not u.port:
        raise ValueError("missing host/port")
    q = query_dict(link)
    out = {
        "type": "trojan",
        "tag": tag_of(link, f"{u.hostname}:{u.port}"),
        "server": u.hostname,
        "server_port": u.port,
        "password": urllib.parse.unquote(u.username or ""),
    }
    if (q.get("security") or "tls").lower() != "none":  # trojan implies TLS
        out["tls"] = tls_block(
            q.get("sni") or q.get("peer") or u.hostname,
            truthy(q.get("allowInsecure") or ""),
            q.get("fp"),
            q.get("alpn"),
        )
    transport = transport_block(q.get("type"), q.get("host"), q.get("path"), q.get("serviceName"))
    if transport:
        out["transport"] = transport
    return out


def parse_hysteria2(link):
    u = urllib.parse.urlsplit(link)
    if not u.hostname or not u.port:
        raise ValueError("missing host/port")
    q = query_dict(link)
    out = {
        "type": "hysteria2",
        "tag": tag_of(link, f"{u.hostname}:{u.port}"),
        "server": u.hostname,
        "server_port": u.port,
        "password": urllib.parse.unquote(u.username or ""),
        "tls": tls_block(q.get("sni") or u.hostname, truthy(q.get("insecure") or "")),
    }
    if q.get("obfs"):
        out["obfs"] = {"type": q["obfs"], "password": q.get("obfs-password") or ""}
    return out


PARSERS = {
    "ss": parse_ss,
    "vmess": parse_vmess,
    "vless": parse_vless,
    "trojan": parse_trojan,
    "hysteria2": parse_hysteria2,
    "hy2": parse_hysteria2,
}


def fetch(url):
    request = urllib.request.Request(url, headers={"User-Agent": "singbox-subscribe/1.0"})
    with urllib.request.urlopen(request, timeout=30) as response:
        body = response.read().decode("utf-8", "replace")
    return body if "://" in body else b64(body)


def unique_tag(taken, tag):
    base = " ".join(tag.split()) or "node"
    tag, n = base, 1
    while tag in taken or tag in RESERVED_TAGS:
        n += 1
        tag = f"{base} #{n}"
    taken.add(tag)
    return tag


def build_config(nodes, args):
    tags = [node["tag"] for node in nodes]
    config = {
        "log": {"level": "warn", "timestamp": True},
        "experimental": {
            "cache_file": {"enabled": True, "path": args.cache_file},
            "clash_api": {"external_controller": f"{args.clash_listen}:{args.clash_port}"},
        },
        "inbounds": [
            {"type": "mixed", "tag": "mixed-in", "listen": args.listen, "listen_port": args.port}
        ],
        "outbounds": [
            {
                "type": "selector",
                "tag": "proxy",
                "outbounds": ["auto"] + tags,
                "default": "auto",
                "interrupt_exist_connections": False,
            },
            {
                "type": "urltest",
                "tag": "auto",
                "outbounds": tags,
                "url": URLTEST_URL,
                "interval": "3m",
                "tolerance": 50,
            },
        ]
        + nodes
        + [{"type": "direct", "tag": "direct"}],
        "route": {
            "rules": ([{"action": "route", "ip_is_private": True, "outbound": "direct"}] if args.private_direct else []),
            "final": "proxy",
            "auto_detect_interface": True,
        },
    }
    return config


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--urls-file", required=True, help="file with one subscription URL per line")
    parser.add_argument("--output-dir", required=True, help="directory for the generated config.json")
    parser.add_argument("--sing-box", help="sing-box binary used to validate the config before switching")
    parser.add_argument("--listen", default="127.0.0.1", help="mixed proxy listen address")
    parser.add_argument("--port", type=int, default=2080, help="mixed proxy port")
    parser.add_argument("--clash-listen", default="127.0.0.1", help="clash API listen address")
    parser.add_argument("--clash-port", type=int, default=9090, help="clash API port")
    parser.add_argument("--cache-file", default="/var/lib/singbox/cache.db", help="sing-box cache file path")
    parser.add_argument(
        "--no-private-direct",
        dest="private_direct",
        action="store_false",
        help="do not route private IP ranges directly",
    )
    args = parser.parse_args()

    with open(args.urls_file, encoding="utf-8") as f:
        urls = [line.strip() for line in f if line.strip() and not line.lstrip().startswith("#")]
    if not urls:
        sys.exit(f"no subscription URLs in {args.urls_file}")

    links, fetch_failures = [], 0
    for url in urls:
        try:
            links.extend(match.group(0) for match in LINK_RE.finditer(fetch(url)))
        except Exception as exc:  # noqa: BLE001 — one bad URL must not kill the rest
            print(f"warn: fetch {url}: {exc}", file=sys.stderr)
            fetch_failures += 1
    if fetch_failures == len(urls):
        sys.exit("every subscription URL failed; keeping existing config")

    nodes, taken, skipped = [], set(), 0
    for link in links:
        try:
            node = PARSERS[link.split("://", 1)[0].lower()](link)
        except Exception as exc:  # noqa: BLE001 — skip broken links, keep the rest
            print(f"warn: skipped {link.split('://', 1)[0]} link: {exc}", file=sys.stderr)
            skipped += 1
            continue
        node["tag"] = unique_tag(taken, node["tag"])
        nodes.append(node)
    if not nodes:
        sys.exit(f"no parsable nodes ({skipped} links failed); keeping existing config")

    config = build_config(nodes, args)
    os.makedirs(args.output_dir, exist_ok=True)
    tmp_path = os.path.join(args.output_dir, "config.json.tmp")
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)

    if args.sing_box:
        result = subprocess.run([args.sing_box, "check", "-c", tmp_path], capture_output=True, text=True)
        if result.returncode != 0:
            sys.exit(f"sing-box check failed:\n{result.stdout}{result.stderr}")

    final_path = os.path.join(args.output_dir, "config.json")
    os.replace(tmp_path, final_path)
    os.chmod(final_path, 0o600)
    print(
        f"sing-box config written to {final_path}: "
        f"{len(nodes)} nodes from {len(urls) - fetch_failures}/{len(urls)} subscription(s), {skipped} links skipped"
    )


if __name__ == "__main__":
    main()
