# Load our dotfiles like ~/.bash_prompt, etc…
#   ~/.extra can be used for settings you don’t want to commit,
#   Use it to configure your PATH, thus it being first in line.

export PATH="/usr/local/sbin:$PATH"
export RBENV_ROOT=/usr/local/var/rbenv
export PATH=$PATH:$MYSQL
export DYLD_LIBRARY_PATH=/usr/local/mysql/lib:$DYLD_LIBRARY_PATH
export NODE_ENV=development

for file in ~/.{extra,bash_prompt,exports,aliases,functions}; do
    [ -r "$file" ] && source "$file"
done
unset file

# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"

# Save multi-line commands as one command
shopt -s cmdhist

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
