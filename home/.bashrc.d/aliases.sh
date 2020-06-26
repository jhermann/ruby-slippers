#
# bash alias definitions
#

# Shortcuts
alias dir="ls -F"
alias l="ls -l"
alias la="ls -la"
alias md=mkdir
alias ..="cd .."
alias ...="cd ../.."
alias xo=xdg-open
alias tree="tree -I '*~|*.py[co]|__pycache__|.git|.venv'"
alias notes="pe $HOME/Documents/notes.md"

# Define default args
alias eg="command eg --config-file=$HOME/.config/eg/config.ini"

# Little helpers
alias rebashrc=". ~/.bashrc"
alias total="awk '{tot=tot+\$1} END {print tot}'"
alias avg="awk '{sum+=\$1} END { print sum/NR}'"
alias utf8tolatin1="iconv -f utf-8 -t iso8859-1"
alias apt-update-debug='apt update -o Debug::Acquire::http=true'
alias sz-tty='wmctrl -r :ACTIVE: -e 0,-1,-1,1470,990; sleep .3; echo "Terminal size set to $(tput cols)×$(tput lines)"'
alias uc-nbsp="python3 -c 'print(\"\\xA0\", end=\"\")' | xsel -bi"
alias uc-em-quad="python3 -c 'print(\"\\u2001\", end=\"\")' | xsel -bi"
alias uc-0-space="python3 -c 'print(\"\\u200B\", end=\"\")' | xsel -bi"

# SCM
alias cdiff='colordiff | less -r'
alias svndiffb='svn diff --diff-cmd diffb | cdiff '
alias svnignore="svn propedit svn:ignore"

# Typos
alias gti=git


ssh_key_fp() {
    local keyfile=${1:?You MUST provide a private key file as the 1st arg}; shift
    ssh-keygen -l -f "$keyfile" "$@"
}
xmlpretty() {
    xmllint --format "$@" | pygmentize | less -R
}
