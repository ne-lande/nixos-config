## fish configuration? for ya ofc
{
  config,
  lib,
  ...
}:
let
  username = config.central.username;
in
with lib;
{
  options.shell.fish = {
    enable = mkEnableOption "enable fish";
  };

  config = mkIf config.shell.fish.enable {

    programs.fish.enable = true;
    home-manager.users.${username} =
      { ... }:
      {
        programs.fish = {
          enable = true;
          binds = {
            "ctrl-a".command = "beginning-of-line";
            "ctrl-e".command = "end-of-line";
            "ctrl-left".command = "backward-word";
            "ctrl-right".command = "forward-word";
          };
          interactiveShellInit = ''
            set fish_greeting
          '';
          functions = {
            nukedocker = {
              body = ''
                if not type -q docker
                    echo "docker not found"
                    return 1
                end

                echo "Stopping all running containers..."
                set containers (docker ps -q)
                if test (count $containers) -gt 0
                    docker kill $containers 2>/dev/null
                end

                echo "Removing all containers..."
                set all_containers (docker ps -aq)
                if test (count $all_containers) -gt 0
                    docker rm $all_containers 2>/dev/null
                end

                echo "Removing all images..."
                set images (docker images -aq)
                if test (count $images) -gt 0
                    docker rmi $images 2>/dev/null
                end

                echo "Removing all networks..."
                docker network prune -f

                echo "Removing all volumes..."
                docker volume prune -f

                echo "Docker cleanup complete."
              '';
            };
            killgrep = {
              body = ''
                if test -z "$argv[1]"
                    echo "Usage: killgrep <pattern>"
                    return 1
                end

                set pids (ps aux | grep $argv[1] | grep -v grep | awk '{print $2}')

                if test -z "$pids"
                    echo "No processes found matching '$argv[1]'."
                    return 0
                end

                set count (printf "%s\n" $pids | wc -w)

                echo "Killing $count process(es): $pids"
                printf "%s\n" $pids | xargs kill -9
                echo "Done."
              '';
            };
          };
          shellAbbrs = { };
          shellAliases = {
            bat = "bat --style=numbers --paging never";
            ls = "eza --icons=always";
            c = "clear";
            grep = "grep --color=auto";
            sudo = "sudo ";
            ping = "ping -c 5";
            ssh = "kitty +kitten ssh";
            icat = "kitty +kitten icat";
            diff = "kitty +kitten diff";
            untar = "tar xvf";
            cwd = "pwd | tr -d '\r\n' | xclip -selection clipboard";
            timer = "echo 'Timer started. Stop with Ctrl-D.' && date && time cat && date";
          };
        };
      };
  };
}
