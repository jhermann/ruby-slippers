shopt -s autocd extglob globstar

# Load custom extensions
for i in ~/.bashrc.d/*.{rc,sh}; do test \! -f "$i" || . "$i"; done

# Fix PATH anomalies
export PATH=$(tr : \\n <<<"$PATH" | uniq | tr \\n :)
export PATH="${PATH%:}"
export PATH=$HOME/bin:$(/bin/sed -re "s#$HOME/bin:##g" <<<"$PATH")
if test -d "$HOME/.local/bin"; then
    export PATH=$HOME/.local/bin:$(/bin/sed -re "s#$HOME/.local/bin:##g" <<<"$PATH")
fi
##tr : \\n <<<"$PATH"
