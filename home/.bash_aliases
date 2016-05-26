shopt -s autocd extglob globstar
# Load custom extensions
for i in ~/.bashrc.d/*.{rc,sh}; do test \! -f "$i" || . "$i"; done
if test -d ~/.local/bin && grep -v ":$HOME/.local/bin:" <<<":$PATH:" >/dev/null; then
    export PATH="$HOME/.local/bin:$PATH"
fi
