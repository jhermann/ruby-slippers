#
# Go related stuff
#

function _clean_golang_env {
    export PATH=$(sed -r -e "s~:$HOME/.local/gvm/[^:]+~~g" -e 's/:+/:/g' -e 's/^:|:$//g' <<<":$PATH")
}
_clean_golang_env  # note that "…/scripts/gvm" is sourced AFTER this script in "~/.bashrc"

export GOPATH=$HOME/lib/gocode
