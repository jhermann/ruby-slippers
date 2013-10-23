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
    pip_install "docutils >= 0.11"; tools="$tools rst2xml.py rst2s5.py rst2odt.py rst2man.py rst2latex.py rst2html.py"
    pip_install "Sphinx == 1.1.3"; tools="$tools sphinx-quickstart sphinx-build sphinx-autogen sphinx-apidoc"

    mkdir -p ~/bin
    for tool in $tools; do
        target=${tool%.py}
        echo "Symlinking ~/bin/$target"
        ln -nfs "../.pyvenv/ruby-slippers/bin/$tool" "$HOME/bin/$target"
    done
    ls -lrt "$HOME/.pyvenv/ruby-slippers/bin/" | tail -n10
}


main