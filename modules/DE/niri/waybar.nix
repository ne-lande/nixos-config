{
  enable = true;
  systemd.enable = true;
  settings = {
    bar = {
      layer = "top";
      position = "left";
      margin-top = 16;
      margin-bottom = 16;
      margin-left = 16;
      margin-right = 0;
      spacing = 4;
      gtk-layer-shell = true;
      modules-left = [
        "cpu"
        "custom/gpu"
        "memory"
      ];
      cpu = {
        format = "CPU\n{usage}%";
        on-click = "";
        justify = "center";
        tooltip = true;
      };
      "custom/gpu" = {
        exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits";
        interval = 5;

        format = "GPU\n{text}%";
        justify = "center";
      };
      memory = {
        format = "MEM\n{percentage}%";
        justify = "center";
        tooltip-format = "RAM T:{total:0.1f}GB; A:{avail:0.1f}GB; U:{used:0.1f}GB ({percentage}%)\nSWAP T:{swapTotal:0.1f}GB; A:{swapAvail:0.1f}GB; U:{swapUsed:0.1f}GB ({swapPercentage}%)";
        on-click = "";
        tooltip = true;
      };
      "pulseaudio#audio" = {
        format = "{icon}";
        format-bluetooth = "󰂯\n{icon}";
        format-bluetooth-muted = "󰂯\n󰖁";
        format-muted = "󰖁";
        format-icons = {
          headphone = "󰋋";
          hands-free = "󰋋";
          headset = "󰋋";
          phone = "";
          portable = "";
          car = "";
          default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
        };
        on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
        on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
        tooltip = true;
        tooltip-format = "{icon} {desc} {volume}%";
      };
      "pulseaudio#microphone" = {
        format = "{format_source}";
        #"format-source"= "󰍬 {volume}%";
        format-source = "󰍬";
        # "format-source-muted"= "󰍭 {volume}%";
        format-source-muted = "󰍭";
        on-click = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        on-scroll-up = "pactl set-source-volume @DEFAULT_SOURCE@ +1%";
        on-scroll-down = "pactl set-source-volume @DEFAULT_SOURCE@ -1%";
        max-volume = 100;
        tooltip = true;
        tooltip-format = "{icon} {desc} {volume}%";
      };
      "network#wlo1" = {
        interval = 1;
        interface = "wlo1";
        format-icons = [
          "󰤯"
          "󰤟"
          "󰤢"
          "󰤥"
          "󰤨"
        ];
        format-wifi = "{icon}";
        format-disconnected = "";
        on-click = "nm-connection-editor";
        tooltip = true;
        tooltip-format = "󰢮 {ifname}\n󰩟 {ipaddr}/{cidr}\n{icon} {essid}\n󱑽 {signalStrength}% {signaldBm} dBm {frequency} MHz\n󰞒 {bandwidthDownBytes}\n󰞕 {bandwidthUpBytes}";
      };
      "network#eno1" = {
        interval = 1;
        interface = "eno1";
        format-icons = [ "󰈀" ];
        format-ethernet = "{icon}";
        format-disconnected = "";
        on-click = "";
        tooltip = true;
        tooltip-format = "󰢮 {ifname}\n󰩟 {ipaddr}/{cidr}\n󰞒 {bandwidthDownBytes}\n󰞕 {bandwidthUpBytes}";
      };
      bluetooth = {
        format-disabled = "";
        format-off = "";
        format-on = "󰂯";
        format-connected = "󰂯";
        format-connected-battery = "󰂯";
        tooltip-format-connected = "{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias} 󰂄{device_battery_percentage}% {device_address}";
        on-click = "blueman-manager";
        tooltip = true;
      };
      modules-center = [
        "niri/workspaces"
      ];
      modules-right = [
        "clock"
        "niri/language"
      ];
      "niri/language" = {
        format = "{short}";
      };
      tray = {
        icon-size = 17;
        spacing = 8;
        show-passive-items = true;
      };
      clock = {
        interval = 1;
        format-alt = "󰥔\n{0:%H\n%M\n%S}";
        format = "󰥔\n{0:%H\n%M\n%S}\n\n󰣆\n{0:%y\n%m\n%d}";
        justify = "center";
        tooltip = true;
        tooltip-format = "{calendar}";
        calendar = {
          mode = "year";
          mode-mon-col = 3;
          format = {
            today = "<span color='#0dbc79'>{}</span>";
          };
        };
      };
    };
  };
  style = ''
    * {
      background-color: transparent;
      font-family: "FiraCode Nerd Font", monospace;
      font-size: 18px;
      font-weight: bold;
      /*padding: 0;
      margin: 0;*/
      border: none;
      box-shadow: none;
      text-shadow: none;
    }

    window#waybar {
      background-color: alpha(#11170a, 0.7);
      padding: 0;
      margin: 0;
      border: 4px solid alpha(#505050, 0.7);
    }

    tooltip {
      background-color: alpha(#11170a, 0.7);
      border: 4px solid alpha(#505050, 0.7);
    }
    tooltip_label {
      color: white;
    }

    #cpu,
    #gpu,
    #memory,
    #clock,
    #language {
      padding: 2px 8px;
    }
  '';
}
