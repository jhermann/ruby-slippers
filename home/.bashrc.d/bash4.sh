# For setting history length, see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Protect against failures of bashv4 stuff in older shells
if test "${BASH_VERSINFO[0]}" -ge 4 ; then
    # If set, the pattern "**" used in a pathname expansion context will
    # match all files and zero or more directories and subdirectories.
    shopt -s globstar
fi
