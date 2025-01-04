{
  programs.zsh = {
    enable = true;
    autocd = false;

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
    initExtra = ''
        alias bat='bat --style=numbers --paging never'

        alias l="eza -lhF --icons"
        alias la="eza -lahF --icons"
        alias lsd="eza -lhDF --icons"
        alias ls="eza --icons"
        alias ltree="eza -T --icons"

        alias c='clear'
        alias grep="grep --color=auto "
        alias sudo='sudo '
        alias ping='ping -c 5'
        alias reload='source $ZDOTDIR/.zshrc'

        alias ssh="kitty +kitten ssh"
        alias icat="kitty +kitten icat"
        alias diff="kitty +kitten diff"

        alias untar='tar xvf'
        alias cwd='pwd | tr -d "\r\n" | xclip -selection clipboard'
        alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'
        alias week='date +%V'

        alias docker-suicide='docker kill $(docker ps -q); docker rm $(docker ps -aq); docker rmi $(docker images -qa); docker volume rm $(docker volume ls -q)'

        eval "$(starship init zsh)"
    '';
  };
}
