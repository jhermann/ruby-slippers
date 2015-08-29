#! /bin/bash
#
# install platform-independant tools into $HOME
#
set -e
scriptdir="$(cd "$(dirname "$0")" && pwd)"
venvdir="$HOME/.pyvenv/ruby-slippers"
tmpbase="/tmp/$(basename "$0")-$USER-$$"
git_remote_hg_url="https://raw.github.com/felipec/git-remote-hg/master/git-remote-hg"
action="$1"; shift || :


pyvenv() {
    if test ! -d "$venvdir"; then
        hostpython="/usr/bin/python2"
        test -x "$hostpython" || hostpython="/usr/bin/python"
        "$scriptdir"/home/bin/mkvenv "$hostpython" --setuptools --no-site-packages "$venvdir"
    fi
}


pip_install() {
    echo "*** pip install" "$@"
    "$venvdir/bin/pip" install "$@"
}

tool_install() {
    pip_install "$1"
    tools="$tools $1"
}


script_install() {
    local script="$1"
    local url="$2"
    if test ! -x ~/bin/"$script"; then
        wget "$url" -O ~/bin/"$script"
        chmod a+x ~/bin/"$script"
    fi
}


main() {
    mkdir -p ~/.local ~/bin

    # Make venv
    pyvenv

    # Install tools into venv
    tools=""
    pip_install "yolk3k" || :
    pip_install "pylint>=1.0"; tools="$tools pyreverse epylint pylint pylint-gui symilar"
    pip_install "flake8"; tools="$tools pyflakes pep8 flake8"
    pip_install "httpie"; tools="$tools http"
    tool_install "markdown2"
    tool_install "isort"
    pip_install "pypi-show-urls"; tools="$tools pypi-show-urls"
    pip_install "docutils >= 0.11"; tools="$tools rst2xml.py rst2s5.py rst2odt.py rst2man.py rst2latex.py rst2html.py"
    pip_install "Sphinx == 1.1.3"; tools="$tools sphinx-quickstart sphinx-build sphinx-autogen sphinx-apidoc"
    pip_install "https://github.com/jhermann/nodeenv/archive/master.zip#egg=nodeenv"; tools="$tools nodeenv"
    pip_install "mercurial"; tools="$tools hg"
    pip_install "devpi-client"; tools="$tools devpi"
    tool_install "pipsi"
    pip_install "pip-tools"; tools="$tools pip-review pip-dump"
    pip_install "pythonpy"; tools="$tools py"
    tool_install "wheel"
    tool_install "bumpversion"
    tool_install "check-manifest"
    tool_install "howdoi"
    tool_install "clf"
    tool_install "pypirc"
    tool_install "twine"
    tool_install "restview"
    tool_install "pex"
    # tool_install "joe"
    pip_install "ansible"; tools="$tools ansible ansible-doc ansible-galaxy ansible-playbook ansible-pull ansible-vault"

    # Nikola
    command which nikola || pipsi install "nikola"
    ~/.local/venvs/nikola/bin/python -c "import certifi" 2>/dev/null \
        || ~/.local/venvs/nikola/bin/pip install "nikola[extras]"

    # Link selected tools into ~/bin
    mkdir -p ~/bin
    for tool in $tools; do
        target=${tool%.py}
        echo "Symlinking ~/bin/$target"
        ln -nfs "../.pyvenv/ruby-slippers/bin/$tool" "$HOME/bin/$target"
    done
    ls -lrt "$venvdir/bin" | tail -n10

    # Add venv's 'bash_completion.d', if existing
    if ! grep '^_load_resource_dir '$(sed -re "s#$HOME#~#" <<<"$venvdir")'/bash_completion.d$' ~/.bash_completion >/dev/null; then
        echo >>~/.bash_completion "_load_resource_dir "$(sed -re "s#$HOME#~#" <<<"$venvdir")"/bash_completion.d"
    fi

    # Install pastee
    if test ! -x ~/bin/pastee; then
        curl -skSL "https://pastee.org/pastee.py" >~/bin/pastee
        chmod a+x ~/bin/pastee
    fi

    # Install yEd
    if test ! -d ~/lib/yed-current -a -n "$(ls -1 /tmp/yEd-*.zip 2>/dev/null)"; then
        mkdir -p ~/lib; cd ~/lib
        unzip -xu "$(ls -1rt /tmp/yEd-*.zip | tail -n1)"
        ln -nfs $(ls -1rtd yed-[0-9]* | tail -n1) yed-current
    fi

    # Install git-remote-hg
    if test ! -x ~/bin/git-remote-hg; then
        { echo "#! $venvdir/bin/python"; curl -skSL "$git_remote_hg_url"; } > ~/bin/git-remote-hg
        chmod +x ~/bin/git-remote-hg
    fi

    # autorevision
    script_install autorevision "https://raw.githubusercontent.com/Autorevision/autorevision/master/autorevision.sh"

    # mkcast
    script_install mkcast "https://raw.githubusercontent.com/KeyboardFire/mkcast/master/mkcast"
    script_install newcast "https://raw.githubusercontent.com/KeyboardFire/mkcast/master/newcast"

    # autoenv
    test -d ~/.local/autoenv || git clone "https://github.com/kennethreitz/autoenv.git" ~/.local/autoenv
    test -f ~/.bashrc.d/autoenv.sh || \
        ln -s ~/.local/autoenv/activate.sh ~/.bashrc.d/autoenv.sh

    # less.vim "m"
    if test ! -x ~/bin/m; then
        curl -skSL https://raw.githubusercontent.com/jhermann/less.vim/master/m >~/bin/m
        chmod a+x ~/bin/m
    fi

    # ansible-new-role
    if test ! -x ~/bin/ansible-new-role; then
        curl -skSL https://raw.githubusercontent.com/realgo/ansible-new-role/master/ansible-new-role >~/bin/ansible-new-role
        chmod a+x ~/bin/ansible-new-role
    fi

    # gimme (go installer)
    if test ! -x ~/bin/gimme; then
        curl -sL -o ~/bin/gimme "https://raw.githubusercontent.com/travis-ci/gimme/master/gimme"
        chmod a+x ~/bin/gimme
    fi

    # Hack font
    if test ! -f ~/.fonts/Hack-Regular.ttf; then
        curl -sL -o /tmp/hack-ttf.zip "https://github.com/chrissimpkins/Hack/releases/download/v2.010/Hack-v2_010-ttf.zip"
        mkdir -p ~/.fonts
        ( cd ~/.fonts && unzip -j -o /tmp/hack-ttf.zip )
    fi

    # Manual intervention needed?
    test -d ~/lib/yed-current || echo "WARN: for yEd, you need to download it to /tmp," \
        "from http://www.yworks.com/en/products_download.php"
}


main
