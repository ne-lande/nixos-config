{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.central.username;
  c = import ./DE/niri/colors.nix;
in
with lib;
{
  options.music = {
    enable = mkEnableOption "enable music";
    musicDirectory = mkOption {
      type = types.str;
      default = "/stor/Music";
      description = "The directory where music is stored.";
    };
    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The address of the MPD server.";
    };
    port = mkOption {
      type = types.int;
      default = 6600;
      description = "The port of the MPD server.";
    };
    userUid = mkOption {
      type = types.int;
      default = 1000;
      description = "UID of the user, needed for XDG_RUNTIME_DIR in the MPD service.";
    };
  };

  config = mkIf config.music.enable {
    systemd.services.mpd.environment = {
      # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
      XDG_RUNTIME_DIR = "/run/user/${toString config.music.userUid}";
    };

    services.mpd = {
      enable = true;
      user = username;
      group = "audio";
      settings = {
        audio_output = [
          {
            type = "pipewire";
            name = "My PipeWire Output";
          }
        ];
        music_directory = config.music.musicDirectory;
        bind_to_address = config.music.address;
        port = config.music.port;
      };
    };

    home-manager.users.${username} =
      { ... }:
      {
        home.packages = [ pkgs.libnotify ];

        programs.cava.enable = true;

        programs.rmpc = {
          enable = true;
          package = pkgs.rmpc;
          config = ''
            #![enable(implicit_some)]
            #![enable(unwrap_newtypes)]
            #![enable(unwrap_variant_newtypes)]
            (
                address: "${config.music.address}:${toString config.music.port}",
                on_song_change: ["sh", "-c", "rmpc albumart -o /tmp/rmpc_cover.png 2>/dev/null; notify-send -t 3000 -i /tmp/rmpc_cover.png 'Now Playing' \"$TITLE - $ARTIST\""],
                album_art: (
                    method: Kitty,
                    max_size_px: (width: 1200, height: 1200),
                    disabled_protocols: ["http://", "https://"],
                    vertical_align: Center,
                    horizontal_align: Center,
                ),
                theme: "~/.config/rmpc/theme.ron",
            )
          '';
        };

        xdg.configFile."rmpc/theme.ron".text = ''
          #![enable(implicit_some)]
          #![enable(unwrap_newtypes)]
          #![enable(unwrap_variant_newtypes)]
          (
              default_album_art_path: None,
              format_tag_separator: " | ",
              browser_column_widths: [20, 38, 42],
              background_color: None,
              text_color: None,
              header_background_color: None,
              modal_background_color: None,
              modal_backdrop: false,
              preview_label_style: (fg: "${c.yellow}"),
              preview_metadata_group_style: (fg: "${c.yellow}", modifiers: "Bold"),
              highlighted_item_style: (fg: "${c.accent}", modifiers: "Bold"),
              current_item_style: (fg: "black", bg: "${c.accent}", modifiers: "Bold"),
              borders_style: (fg: "${c.accent}"),
              highlight_border_style: (fg: "${c.accent}"),
              symbols: (
                  song: "S",
                  dir: "D",
                  playlist: "P",
                  marker: "M",
                  ellipsis: "...",
                  song_style: None,
                  dir_style: None,
                  playlist_style: None,
              ),
              level_styles: (
                  info: (fg: "${c.accent}", bg: "black"),
                  warn: (fg: "${c.yellow}", bg: "black"),
                  error: (fg: "${c.red}", bg: "black"),
                  debug: (fg: "${c.accentLight}", bg: "black"),
                  trace: (fg: "${c.magenta}", bg: "black"),
              ),
              progress_bar: (
                  symbols: ["█", "█", "█", " ", "█"],
                  track_style: None,
                  elapsed_style: (fg: "${c.accent}"),
                  thumb_style: (fg: "${c.accent}"),
                  use_track_when_empty: true,
              ),
              scrollbar: (
                  symbols: ["│", "█", "▲", "▼"],
                  track_style: (),
                  ends_style: (),
                  thumb_style: (fg: "${c.accent}"),
              ),
              tab_bar: (
                  active_style: (fg: "black", bg: "${c.accent}", modifiers: "Bold"),
                  inactive_style: (),
              ),
              lyrics: (
                  timestamp: false
              ),
              browser_song_format: [
                  (
                      kind: Group([
                          (kind: Property(Track)),
                          (kind: Text(" ")),
                      ])
                  ),
                  (
                      kind: Group([
                          (kind: Property(Artist)),
                          (kind: Text(" - ")),
                          (kind: Property(Title)),
                      ]),
                      default: (kind: Property(Filename))
                  ),
              ],
              song_table_format: [
                  (
                      prop: (kind: Property(Artist),
                          default: (kind: Text("Unknown"))
                      ),
                      label_prop: (kind: Text("Artist")),
                      width: "20%",
                  ),
                  (
                      prop: (kind: Property(Title),
                          default: (kind: Text("Unknown"))
                      ),
                      label_prop: (kind: Text("Title")),
                      width: "35%",
                  ),
                  (
                      prop: (kind: Property(Album), style: (fg: "white"),
                          default: (kind: Text("Unknown Album"), style: (fg: "white"))
                      ),
                      label_prop: (kind: Text("Album")),
                      width: "30%",
                  ),
                  (
                      prop: (kind: Property(Duration),
                          default: (kind: Text("-"))
                      ),
                      label_prop: (kind: Text("Duration")),
                      width: "15%",
                      alignment: Right,
                  ),
              ],
              layout: Split(
                  direction: Vertical,
                  panes: [
                      (
                          size: "4",
                          pane: Split(
                              direction: Horizontal,
                              panes: [
                                  (
                                      size: "35",
                                      borders: "LEFT | TOP | BOTTOM",
                                      border_symbols: Inherited(parent: Rounded, bottom_left: "├"),
                                      pane: Component("header_left")
                                  ),
                                  (
                                      size: "100%",
                                      borders: "ALL",
                                      border_symbols: Inherited(parent: Rounded, top_left: "┬", top_right: "┬", bottom_left: "┴", bottom_right: "┴"),
                                      pane: Component("header_center")
                                  ),
                                  (
                                      size: "35",
                                      borders: "RIGHT | TOP | BOTTOM",
                                      border_symbols: Inherited(parent: Rounded, bottom_right: "┤"),
                                      pane: Component("header_right")
                                  ),
                              ]
                          )
                      ),
                      (
                          pane: Pane(Tabs),
                          borders: "RIGHT | LEFT | BOTTOM",
                          border_symbols: Rounded,
                          size: "2",
                      ),
                      (
                          pane: Pane(TabContent),
                          size: "100%",
                      ),
                      (
                          size: "3",
                          pane: Split(
                              direction: Horizontal,
                              panes: [
                                  (
                                      size: "12",
                                      borders: "ALL",
                                      border_symbols: Inherited(parent: Rounded, top_right: "┬", bottom_right: "┴"),
                                      pane: Component("input_mode")
                                  ),
                                  (
                                      size: "100%",
                                      borders: "TOP | BOTTOM | RIGHT",
                                      border_symbols: Rounded,
                                      border_title: [(kind: Text(" ")), (kind: Property(Status(QueueLength()))), (kind: Text(" songs / ")), (kind: Property(Status(QueueTimeTotal()))), (kind: Text(" total time "))],
                                      border_title_alignment: Right,
                                      pane: Component("progress_bar"),
                                  ),
                              ]
                          ),
                      ),
                  ],
              ),
              components: {
                  "state": Pane(Property(
                      content: [
                          (kind: Text("["), style: (fg: "${c.yellow}", modifiers: "Bold")),
                          (kind: Property(Status(StateV2( ))), style: (fg: "${c.yellow}", modifiers: "Bold")),
                          (kind: Text("]"), style: (fg: "${c.yellow}", modifiers: "Bold")),
                      ], align: Left,
                  )),
                  "title": Pane(Property(
                      content: [
                          (kind: Property(Song(Title)), style: (modifiers: "Bold"),
                              default: (kind: Text("No Song"), style: (modifiers: "Bold"))),
                      ], align: Center, scroll_speed: 1
                  )),
                  "volume": Split(
                      direction: Horizontal,
                      panes: [
                          (size: "1", pane: Pane(Property(content: [(kind: Text(""))]))),
                          (size: "100%", pane: Pane(Volume(kind: Slider(symbols: (filled: "─", thumb: "●", track: "─"))))),
                          (size: "3", pane: Pane(Property(content: [(kind: Property(Status(Volume)), style: (fg: "${c.accent}"))], align: Right))),
                          (size: "2", pane: Pane(Property(content: [(kind: Text("%"), style: (fg: "${c.accent}"))]))),
                      ]
                  ),
                  "elapsed_and_bitrate": Pane(Property(
                      content: [
                          (kind: Property(Status(Elapsed))),
                          (kind: Text(" / ")),
                          (kind: Property(Status(Duration))),
                          (kind: Group([
                              (kind: Text(" (")),
                              (kind: Property(Status(Bitrate))),
                              (kind: Text(" kbps)")),
                          ])),
                      ],
                      align: Left,
                  )),
                  "artist_and_album": Pane(Property(
                      content: [
                          (kind: Property(Song(Artist)), style: (fg: "${c.yellow}", modifiers: "Bold"),
                              default: (kind: Text("Unknown"), style: (fg: "${c.yellow}", modifiers: "Bold"))),
                          (kind: Text(" - ")),
                          (kind: Property(Song(Album)), default: (kind: Text("Unknown Album"))),
                      ], align: Center, scroll_speed: 1
                  )),
                  "states": Split(
                      direction: Horizontal,
                      panes: [
                          (
                              size: "1",
                              pane: Pane(Empty())
                          ),
                          (
                              size: "100%",
                              pane: Pane(Property(content: [(kind: Property(Status(InputBuffer())), style: (fg: "${c.accent}"), align: Left)]))
                          ),
                          (
                              size: "6",
                              pane: Pane(Property(content: [
                                  (kind: Text("["), style: (fg: "${c.accent}", modifiers: "Bold")),
                                  (kind: Property(Status(RepeatV2(
                                      on_label: "z",
                                      off_label: "z",
                                      on_style: (fg: "${c.yellow}", modifiers: "Bold"),
                                      off_style: (fg: "${c.accent}", modifiers: "Dim"),
                                  )))),
                                  (kind: Property(Status(RandomV2(
                                      on_label: "x",
                                      off_label: "x",
                                      on_style: (fg: "${c.yellow}", modifiers: "Bold"),
                                      off_style: (fg: "${c.accent}", modifiers: "Dim"),
                                  )))),
                                  (kind: Property(Status(ConsumeV2(
                                      on_label: "c",
                                      off_label: "c",
                                      oneshot_label: "c",
                                      on_style: (fg: "${c.yellow}", modifiers: "Bold"),
                                      off_style: (fg: "${c.accent}", modifiers: "Dim"),
                                      oneshot_style: (fg: "${c.red}", modifiers: "Dim"),
                                  )))),
                                  (kind: Property(Status(SingleV2(
                                      on_label: "v",
                                      off_label: "v",
                                      oneshot_label: "v",
                                      on_style: (fg: "${c.yellow}", modifiers: "Bold"),
                                      off_style: (fg: "${c.accent}", modifiers: "Dim"),
                                      oneshot_style: (fg: "${c.red}", modifiers: "Bold"),
                                  )))),
                                  (kind: Text("]"), style: (fg: "${c.accent}", modifiers: "Bold")),
                                  ],
                                  align: Right
                              ))
                          ),
                      ]
                  ),
                  "input_mode": Pane(Property(
                      content: [
                          (kind: Transform(Replace(content: (kind: Property(Status(InputMode()))), replacements: [
                              (match: "Normal", replace: (kind: Text(" NORMAL "), style: (fg: "black", bg: "${c.accent}"))),
                              (match: "Insert", replace: (kind: Text(" INSERT "), style: (fg: "black", bg: "${c.accentLight}"))),
                          ])))
                      ], align: Center
                  )),
                  "header_left": Split(
                      direction: Vertical,
                      panes: [
                          (size: "1", pane: Component("state")),
                          (size: "1", pane: Component("elapsed_and_bitrate")),
                      ]
                  ),
                  "header_center": Split(
                      direction: Vertical,
                      panes: [
                          (size: "1", pane: Component("title")),
                          (size: "1", pane: Component("artist_and_album")),
                      ]
                  ),
                  "header_right": Split(
                      direction: Vertical,
                      panes: [
                          (size: "1", pane: Component("volume")),
                          (size: "1", pane: Component("states")),
                      ]
                  ),
                  "progress_bar": Split(
                      direction: Horizontal,
                      panes: [
                          (
                              size: "1",
                              pane: Pane(Empty())
                          ),
                          (
                              size: "100%",
                              pane: Pane(ProgressBar)
                          ),
                          (
                              size: "1",
                              pane: Pane(Empty())
                          ),
                      ]
                  )
              },
          )
        '';
      };
  };
}
