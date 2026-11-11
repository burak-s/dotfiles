# Oh My Zsh ve eklentiler NixOS tarafindan yuklenir.
CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
bindkey '^[[C' autosuggest-accept
bindkey '^[[F' autosuggest-accept

# Makineye ozel SDK yollari ve otomatik ssh-agent baslatma alinmadi.
typeset -U path PATH
path=("$HOME/.local/bin" $path)
[[ -d "$HOME/go/bin" ]] && path=("$HOME/go/bin" $path)
# .zshenv icindeki kosulsuz Cargo source yerine guvenli kontrol.
[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
