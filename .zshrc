fpath=( "$HOME/.zfunctions" $fpath )

# suggestions
$b tarruda/zsh-autosuggestions

# Enable autosuggestions automatically
zle-line-init() {
    zle autosuggest-start
}

zle -N zle-line-init

# Load default dotfiles
source ~/.bash_profile
