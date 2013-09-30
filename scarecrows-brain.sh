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
    echo "*** pip install" "$@"
    "$venvdir/bin/pip" install "$@"
}


main() {
    tools=""
    pyvenv
    pip_install "yolk" || :
    pip_install "pylint>=1.0"; tools="$tools pyreverse epylint pylint pylint-gui symilar"
    pip_install "flake8"; tools="$tools pyflakes pep8 flake8"
    pip_install "httpie"; tools="$tools http"
    pip_install "markdown2"; tools="$tools markdown2"
    pip_install "isort"; tools="$tools isort"
    pip_install "pypi-show-urls"; tools="$tools pypi-show-urls"

    mkdir -p ~/bin
    for tool in $tools; do
        echo "Symlinking ~/bin/$tool"
        ln -nfs "../.pyvenv/ruby-slippers/bin/$tool" "$HOME/bin/$tool"
    done
    ls -lrt "$HOME/.pyvenv/ruby-slippers/bin/" | tail -n10
}


main
