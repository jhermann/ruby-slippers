shopt -s autocd extglob globstar

# Load custom extensions
for i in ~/.bashrc.d/*.{rc,sh}; do test \! -f "$i" || . "$i"; done

# Fix PATH anomalies
export PATH=$(echo $(tr : \\n <<<"$PATH" | uniq) | tr ' ' ':')
if test -d "$HOME/.local/bin"; then
    export PATH=$HOME/.local/bin:$(/bin/sed -re "s#$HOME/.local/bin:##" <<<"$PATH")
fi
export PATH=$HOME/bin:$(/bin/sed -re "s#$HOME/bin:##" <<<"$PATH")
