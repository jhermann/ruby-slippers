#! /bin/bash
#
# install platform-independant tools into $HOME
#
set -e
scriptdir="$(command cd "$(dirname "$0")" && pwd)"
snake="$(command which python3.6 | head -n1)"
#venvdir="${RUBY_SLIPPERS_VENV:-$HOME/.local/venvs/ruby-slippers}"
venv_base="$HOME/.local/share/dephell/venvs"
tmpbase="/tmp/$(basename "$0")-$USER-$$"
git_remote_hg_url="https://raw.github.com/felipec/git-remote-hg/master/git-remote-hg"
git_standup_url="https://raw.githubusercontent.com/kamranahmedse/git-standup/master/git-standup"


script_install() {
    local script="$1"
    local url="$2"
    if test ! -x ~/bin/"$script"; then
        wget "$url" -O ~/bin/"$script"
        chmod a+x ~/bin/"$script"
    fi
}

#script_py_install() {
#    local script="$1"
#    script_install "$@"

#    head -n1 <~/bin/"$script" | grep "$venvdir/bin/python" >/dev/null \
#        || sed -i,orig -re "1s:#!.*:#! $venvdir/bin/python:" ~/bin/"$script"
#}

install_others() {
    # Add venv's 'bash_completion.d', if existing
#    if ! grep '^_load_resource_dir '$(sed -re "s#$HOME#~#" <<<"$venvdir")'/bash_completion.d$' ~/.bash_completion >/dev/null; then
#        echo >>~/.bash_completion "_load_resource_dir "$(sed -re "s#$HOME#~#" <<<"$venvdir")"/bash_completion.d"
#    fi

    # Install pastee
#    if test ! -x ~/bin/pastee; then
#        curl -skSL "https://pastee.org/pastee.py" >~/bin/pastee
#        chmod a+x ~/bin/pastee
#    fi

    # Install yEd (if dowenloaded to /tmp)
    if test ! -d ~/.local/lib/yed-current -a -n "$(ls -1 /tmp/yEd-*.zip 2>/dev/null)"; then
        mkdir -p ~/.local/lib; cd ~/.local/lib
        unzip -xu "$(ls -1rt /tmp/yEd-*.zip | tail -n1)"
        ln -nfs $(ls -1rtd yed-[0-9]* | tail -n1) yed-current
    fi

    # Install git-remote-hg
#    if test ! -x ~/bin/git-remote-hg; then
#        { echo "#! $venvdir/bin/python"; curl -skSL "$git_remote_hg_url"; } > ~/bin/git-remote-hg
#        chmod +x ~/bin/git-remote-hg
#    fi

    # autorevision
    script_install autorevision "https://raw.githubusercontent.com/Autorevision/autorevision/master/autorevision.sh"

    # mkcast
    script_install mkcast "https://raw.githubusercontent.com/KeyboardFire/mkcast/master/mkcast"
    script_install newcast "https://raw.githubusercontent.com/KeyboardFire/mkcast/master/newcast"

    # git tbdiff
#    script_py_install git-tbdiff "https://raw.githubusercontent.com/trast/tbdiff/master/git-tbdiff.py"

    # distribution (histograms)
#    script_py_install distribution "https://raw.githubusercontent.com/philovivero/distribution/master/distribution.py"

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
}

progress() {
    echo -e "\r                                                                     "
    echo '>>>' "$@"
}

install_dephell() {
    if test ! -d "$venv_base/dephell"; then
        progress "Installing dephell"
        curl -L dephell.org/install | $snake
        $venv_base/dephell/bin/pip install -U pip setuptools wheel  # use current tooling
        $venv_base/dephell/bin/pip install "mistune<1"  # fix "m2r"
    fi
}

dephell_pip() {
    local name="${1:?You must provide a jail name}"; shift
    local venv=$(dephell jail show "$name" 2>/dev/null | awk -F'"' '/path/{print $4}')

    if test "$#" -eq 0; then
        echo "$venv/bin/pip"
    else
        $venv/bin/pip "$@"
    fi
}

tool_install() {
    local name="${1:?You must provide a name}"
    name="${name%%[[]*}"
    echo -n "Checking $name ..."
    if dephell jail list 2>/dev/null | grep -q '"'"$name"'": \['; then
        echo -e "\rAlready have $name                                               "
    else
        progress "Installing" "$name"
        dephell jail install "$@"
        echo
    fi
}

install_py_tools() {
    #tool_install "ansible"
    tool_install "bumpversion"
    tool_install "changelogs"
    tool_install "check-manifest"
    tool_install "clf"
    tool_install "cookiecutter"
    tool_install "dependency-check"
    tool_install "diffoscope"
    # ~/.local/share/dephell/venvs/diffoscope/bin/pip install -I libarchive-c==2.7
    tool_install "eg"
    tool_install "flake8"
    tool_install "flit"
    tool_install "howdoi"
    tool_install "httpie"
    tool_install "isort[pipfile,pyproject,requirements,xdg_home]"
    tool_install "markdown2"
    tool_install "nose"
    tool_install "oh-my-stars"
    tool_install "pawk"
    tool_install "pex"
    tool_install "pipenv"
    tool_install "pip-tools"
    tool_install "pylint"
    #PY2? tool_install "pypi-show-urls"
    #PY2? tool_install "pypirc"
    tool_install "pythonpy"
    tool_install "restview"
    tool_install "shiv"
    tool_install "sphinx"
    tool_install "starred"
    tool_install "tox"

    #tool_install "docutils >= 0.11"
    #tool_install "https://github.com/jhermann/nodeenv/archive/master.zip#egg=nodeenv"
    #pipsi_install_spec urbandicli "https://github.com/novel/py-urbandict/archive/master.zip#egg=urbandict";
    #    tools="$tools urbandicli"

    # add sphinx-autobuild to Sphinx jail
    if test ! -x ~/.local/bin/sphinx-autobuild; then
        dephell_pip sphinx install sphinx-autobuild
        ln -nfs "$(dephell_pip sphinx | sed -e s:bin/pip:bin/sphinx-autobuild:)" ~/.local/bin
    fi
}

main() {
    mkdir -p ~/bin ~/.local/bin

    install_dephell
    install_py_tools
    install_others

    echo
    echo "*** ALL OK ***"
}

main
