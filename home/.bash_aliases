# Load custom extensions
for i in ~/.bashrc.d/*.{rc,sh}; do test \! -f "$i" || . "$i"; done
