#
# Go related stuff
#

function _clean_golang_env {
    export PATH=$(sed -r -e "s~:$HOME/.local/gvm/[^:]+~~g" -e 's/:+/:/g' -e 's/^:|:$//g' <<<":$PATH")
}

if test -d $HOME/.local/gvm; then
    _clean_golang_env  # make sure "…/scripts/gvm" is sourced AFTER this

    export GOPATH=$HOME/lib/gocode

    # Activate GVM
    [[ -s "$HOME/.local/gvm/scripts/gvm" ]] && source "$HOME/.local/gvm/scripts/gvm"
fi
