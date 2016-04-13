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
alias notes="pe $HOME/Documents/notes.md"

# Little helpers
alias rebashrc=". ~/.bashrc"
alias total="awk '{tot=tot+\$1} END {print tot}'"
alias avg="awk '{sum+=\$1} END { print sum/NR}'"
alias utf8tolatin1="iconv -f utf-8 -t iso8859-1"

# SCM
alias cdiff='colordiff | less -r'
alias svndiffb='svn diff --diff-cmd diffb | cdiff '
alias svnignore="svn propedit svn:ignore"

# Typos
alias gti=git
