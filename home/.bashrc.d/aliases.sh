#
# bash alias definitions
#
alias dir="ls -F"
alias l="ls -l"
alias la="ls -la"
alias md=mkdir
alias ..="cd .."
alias ...="cd ../.."

alias rebashrc=". ~/.bashrc"

alias cdiff='colordiff | less -r'
alias svndiffb='svn diff --diff-cmd diffb | cdiff '
alias svnignore="svn propedit svn:ignore"

alias total="awk '{tot=tot+\$1} END {print tot}'"
alias avg="awk '{sum+=\$1} END { print sum/NR}'"

# Typos
alias gti=git

