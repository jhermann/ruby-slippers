shopt -s autocd extglob globstar
# Load custom extensions
for i in ~/.bashrc.d/*.{rc,sh}; do test \! -f "$i" || . "$i"; done
grep ":$HOME/.local/bin:" <<<":$PATH:" >/dev/null || export PATH="$HOME/.local/bin:$PATH"
