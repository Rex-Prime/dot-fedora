if [[ -n "$ZSH_DEBUGRC" ]]; then
  zmodload zsh/zprof
fi
# P10k instant prompt

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#typeset -U path cdpath fpath manpath
#for profile in ${(z)NIX_PROFILES}; do
#  fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
#done
fpath=(/usr/share/zsh/site-functions /usr/share/zsh/$ZSH_VERSION/functions $fpath)

# Initialize zinit
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"


#autoload -Uz _zinit
#(( ${+_comps} )) && _comps[zinit]=_zinit
# Load plugins with zinit
zinit ice depth=1

zinit light romkatv/powerlevel10k

zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting
zinit light Aloxaf/fzf-tab

autoload -Uz compinit
compinit

zinit wait lucid for \
  OMZ::plugins/git/git.plugin.zsh \
  OMZ::plugins/sudo/sudo.plugin.zsh \
  OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh \
  OMZ::plugins/zoxide/zoxide.plugin.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Yazi wrapper that changes terminal shell directory after Yazi exits
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# EXPORTS!!

# This has caused me an entire days worth of headaches
# This is important to use if I am not using oh-my-zsh
# cuz otherwise I cant scroll with my mouse
export LESS=-R # display colored text properly instead of raw escape codes
export PAGER=less # sets $PAGER value
# Input Prompt
export GPG_TTY=$(tty)

export EDITOR="nvim"

export DEFAULT_TARGET_DIR=~/Screenshots

WORDCHARS="${WORDCHARS//\/}" # stops cursor at /

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
mkdir -p "$(dirname "$HISTFILE")"

# ZSH options for better experience
setopt NO_BEEP
setopt NO_LIST_BEEP

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt INTERACTIVE_COMMENTS
setopt autocd

unsetopt APPEND_HISTORY
unsetopt EXTENDED_HISTORY
unsetopt HIST_EXPIRE_DUPS_FIRST
unsetopt HIST_FIND_NO_DUPS
unsetopt HIST_IGNORE_ALL_DUPS
unsetopt HIST_SAVE_NO_DUPS

# ===== KEYBINDINGS =====
# Navigation
bindkey "^[[1;5C" forward-word      # Ctrl+Right
bindkey "^[[1;5D" backward-word     # Ctrl+Left
#bindkey "^[[H" beginning-of-line    # Home
#bindkey "^[[F" end-of-line          # End
# Editing
bindkey '^H' backward-kill-word     # Ctrl+Backspace
#bindkey '^[[3;5~' kill-word         # Ctrl+Delete

# Tab completion
# bindkey '^I' complete-word          # Tab

# Ensure emacs keybindings (disables vi-mode)
bindkey -e

# Kitty shell integration
if test -n "$KITTY_INSTALLATION_DIR"; then
  export KITTY_SHELL_INTEGRATION="no-rc no-cursor"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi

# Aliases
alias ..='cd ..'
alias ...='cd ../..'

alias el='eza'
alias ll='eza -l --header --icons --group-directories-first --time-style=long-iso'
alias la='eza -la --header --icons --group-directories-first --time-style=long-iso'
alias tree='eza --tree --icons'

alias ff='fastfetch'
alias of='onefetch'

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi

