# home manager depended!!!
{ config, lib, pkgs, types, ... }:
let
  username = config.central.username;
in with lib;
{
  options.shell.zsh = {
    enable = mkEnableOption "enable zsh";
  };

  config = mkIf config.shell.zsh.enable {
    programs.zsh.enable = true;

    home-manager.users.${username} = { ... }: {
      programs.zsh = {
        enable = true;
        autocd = false;
        enableCompletion = true;

        history = {
            path = "$HOME/.zsh_history";
            size = 25000;
            save = 25000;
        };

        antidote = {
            enable = true;
            plugins = [
              "zsh-users/zsh-syntax-highlighting"
              "zsh-users/zsh-autosuggestions"
            ];
        };

        shellAliases = {
            bat = "bat --style=numbers --paging never";
            ls = "eza --icons=always";
            c = "clear";
            grep = "grep --color=auto";
            sudo = "sudo ";
            ping = "ping -c 5";
            reload = "source $ZDOTDIR/.zshrc";
            ssh = "kitty +kitten ssh";
            icat = "kitty +kitten icat";
            diff = "kitty +kitten diff";
            untar = "tar xvf";
            cwd = "pwd | tr -d '\r\n' | xclip -selection clipboard";
            timer = "echo 'Timer started. Stop with Ctrl-D.' && date && time cat && date";
        };

        shellGlobalAliases = {
          ISODATE = "$(date --iso-8601 | tr -d \\n)";
          UUID = "$(uuidgen | tr -d \\n)";
        };

        siteFunctions = {
          killgrep = ''
            if [ -z "$1" ]; then
                echo "Usage: killgrep <pattern>"
                return 1
            fi

            pids=$(ps aux | grep "$1" | grep -v grep | awk '{print $2}')

            if [ -z "$pids" ]; then
                echo "No processes found matching '$1'."
                return 0
            fi

            count=$(echo "$pids" | wc -w)

            echo "Killing $count process(es): $pids"
            echo "$pids" | xargs kill -9
            echo "Done."
          '';
          nukedocker = ''
            echo "Stopping all running containers..."
            docker kill $(docker ps -q) 2>/dev/null

            echo "Removing all containers..."
            docker rm $(docker ps -aq) 2>/dev/null

            echo "Removing all images..."
            docker rmi $(docker images -aq) 2>/dev/null

            echo "Docker cleanup complete."
          '';
        };

        initContent = ''
            eval "$(starship init zsh)"
        '';
      };
    };
  };
}
