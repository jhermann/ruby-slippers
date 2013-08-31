#! /bin/bash
#
# install platform-independant tools into $HOME
#
set -e
scriptdir=$(cd $(dirname "$0") && pwd)
venvdir="$HOME/.pyvenv/ruby-slippers"
tmpbase="/tmp/"$(basename "$0")"-$USER-$$"
action="$1"; shift || :


pyvenv() {
    if test ! -d "$venvdir"; then
        hostpython="/usr/bin/python2"
        test -x "$hostpython" || hostpython="/usr/bin/python"
        $scriptdir/home/bin/mkvenv "$hostpython" --setuptools --no-site-packages "$venvdir"
    fi
}


pip_install() {
    "$venvdir/bin/pip" install -M "$@"
}


main() {
    tools=""
    pyvenv
    pip_install yolk
    pip_install httpie; tools="$tools http"

    mkdir -p ~/bin
    for tool in $tools; do
        ln -nfs "../.pyvenv/ruby-slippers/bin/$tool" "$HOME/bin/$tool"
    done
}


main

