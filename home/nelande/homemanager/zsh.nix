{
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
      icat =" kitty +kitten icat";
      diff = "kitty +kitten diff";
      untar = "tar xvf";
      cwd = "pwd | tr -d '\r\n' | xclip -selection clipboard";
      timer = "echo 'Timer started. Stop with Ctrl-D.' && date && time cat && date";
      week = "date +%V";
      docker-suicide = "docker kill $(docker ps -q); docker rm $(docker ps -aq); docker rmi $(docker images -qa); docker volume rm $(docker volume ls -q)";
    };

    initExtra = ''
        eval "$(starship init zsh)"
    '';
  };
}
