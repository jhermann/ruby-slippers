#
# Python related stuff
#

alias click-click-click='source ~/.pyvenv/ruby-slippers/bin/activate'
alias pyzen="python -c 'import this'"

# Activate "pipsi" installs
if test -d ~/.local/bin && grep -v ":$HOME/.local/bin:" <<<":$PATH:" >/dev/null; then
    export PATH="$HOME/.local/bin:$PATH"
fi
