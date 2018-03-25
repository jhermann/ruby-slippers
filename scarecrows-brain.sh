#! /bin/bash
#
# install platform-independant tools into $HOME
#
set -e
scriptdir="$(command cd "$(dirname "$0")" && pwd)"
venvdir="${RUBY_SLIPPERS_VENV:-$HOME/.local/virtualenvs/ruby-slippers}"
venv_base=$(dirname $venvdir)
tmpbase="/tmp/$(basename "$0")-$USER-$$"
git_remote_hg_url="https://raw.github.com/felipec/git-remote-hg/master/git-remote-hg"
git_standup_url="https://raw.githubusercontent.com/kamranahmedse/git-standup/master/git-standup"
action="$1"; shift || :


pyvenv() {
    local name="${1:-ruby-slippers}"
    local pyvenv_dir="$venv_base/$name"
    if test ! -d "$pyvenv_dir"; then
        hostpython="/usr/bin/python2"
        test -x "$hostpython" || hostpython="/usr/bin/python"
        "$scriptdir"/home/bin/mkvenv "$hostpython" --setuptools --no-site-packages "$pyvenv_dir"
    fi
}


pipsi_install_spec() {
    local name="${1:?You must provide a name}"; shift
    local pkgspec="${1:?You must provide a package spec or URL}"; shift
    echo "*** pip script install" "$name"
    pyvenv "$name"
    "$venv_base/$name/bin/pip" install -U "pip>=8" "wheel" "setuptools" || :
    "$venv_base/$name/bin/pip" install "$pkgspec" "$@"
}

pipsi_install() {
    local name="${1:?You must provide a name}"; shift
    pipsi_install_spec "$name" "$name" "$@"
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


script_py_install() {
    local script="$1"
    script_install "$@"

    head -n1 <~/bin/"$script" | grep "$venvdir/bin/python" >/dev/null \
        || sed -i,orig -re "1s:#!.*:#! $venvdir/bin/python:" ~/bin/"$script"
}


main() {
    mkdir -p ~/.local ~/bin

    # Make venv
    pyvenv
    ln -nfs "$venvdir/bin/python" "$HOME/bin/python-$(basename $venvdir)"

    # Install tools into venv
    tools=""
    pip_install -U "pip>=8" "wheel" "setuptools" || :
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
    #pip_install "devpi-client"; tools="$tools devpi"
    tool_install "pipsi"
    pip_install "pip-tools"; tools="$tools pip-review pip-dump"
    pip_install "pythonpy"; tools="$tools py"
    tool_install "wheel"
    tool_install "bumpversion"
    tool_install "check-manifest"
    tool_install "howdoi"
    tool_install "clf"
    pip_install "nose"; tool_install "pypirc"
    tool_install "twine"
    tool_install "pawk"
    tool_install "starred"
    tool_install "cookiecutter"
    tool_install "restview"
    tool_install "pex"
    # tool_install "joe"
    pip_install "ansible"; tools="$tools ansible ansible-doc ansible-galaxy ansible-playbook ansible-pull ansible-vault"
    pipsi_install_spec urbandicli "https://github.com/novel/py-urbandict/archive/master.zip#egg=urbandict";
        tools="$tools urbandicli"

    # Nikola
    command which nikola || pipsi_install "nikola"
    $venv_base/nikola/bin/python -c "import certifi" 2>/dev/null \
        || $venv_base/nikola/bin/pip install "nikola[extras]"

    # Link selected tools into ~/bin
    mkdir -p ~/bin
    for tool in $tools; do
        target=${tool%.py}
        echo "Symlinking ~/bin/$target"
        ln -nfs "$(sed -re s:$HOME:..: <<<$venvdir)/bin/$tool" "$HOME/bin/$target"
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
    if test ! -d ~/.local/lib/yed-current -a -n "$(ls -1 /tmp/yEd-*.zip 2>/dev/null)"; then
        mkdir -p ~/.local/lib; cd ~/.local/lib
        unzip -xu "$(ls -1rt /tmp/yEd-*.zip | tail -n1)"
        ln -nfs $(ls -1rtd yed-[0-9]* | tail -n1) yed-current
    fi

    # Install git-standup
    if test ! -x ~/bin/git-standup; then
        { curl -skSL "$git_standup_url"; } > ~/bin/git-standup
        chmod +x ~/bin/git-standup
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

    # git tbdiff
    script_py_install git-tbdiff "https://raw.githubusercontent.com/trast/tbdiff/master/git-tbdiff.py"

    # distribution (histograms)
    script_py_install distribution "https://raw.githubusercontent.com/philovivero/distribution/master/distribution.py"

    # autoenv
    test -d ~/.local/autoenv || git clone "https://github.com/kennethreitz/autoenv.git" ~/.local/autoenv
    test -f ~/.bashrc.d/autoenv.sh || \
        ln -s ~/.local/autoenv/activate.sh ~/.bashrc.d/autoenv.sh

    # less.vim "m"
    if test ! -x ~/bin/m; then
        curl -skSL https://raw.githubusercontent.com/jhermann/less.vim/master/m >~/bin/m
        chmod a+x ~/bin/m
    fi

    # Hack font
    if test ! -f ~/.fonts/Hack-Regular.ttf; then
        curl -sL -o /tmp/hack-ttf.zip "https://github.com/chrissimpkins/Hack/releases/download/v2.010/Hack-v2_010-ttf.zip"
        mkdir -p ~/.fonts
        ( cd ~/.fonts && unzip -j -o /tmp/hack-ttf.zip )
    fi

    # Manual intervention needed?
    test -d ~/.local/lib/yed-current || echo "WARN: for yEd, you need to download the 'Java' ZIP file to /tmp," \
        "from http://www.yworks.com/en/products_download.php"

    echo
    echo "*** ALL OK ***"
}


main
