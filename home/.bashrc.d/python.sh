#
# Python related stuff
#

alias click-click-click='source ~/.pyvenv/ruby-slippers/bin/activate'
alias pyzen="python -c 'import this'"
alias pypi="pip install -i https://pypi.python.org/simple"

# Make pydoc work in virtualenvs, and also alias the system pydoc
alias pydoc="python -c 'import pydoc; pydoc.cli()'"
alias spydoc="command pydoc"

# Activate "pipsi" installs
if test -d ~/.local/bin && grep -v ":$HOME/.local/bin:" <<<":$PATH:" >/dev/null; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Activate "miniconda3" installs
CONDA_HOME="$HOME/.local/miniconda3"
if test -d "$CONDA_HOME"; then
    alias conda="$CONDA_HOME/bin/conda"
    alias conda-env="$CONDA_HOME/bin/conda-env"
    alias conda-activate="source $CONDA_HOME/bin/activate"
    alias conda-deactivate="source $CONDA_HOME/bin/deactivate"

    #if grep -v ":$CONDA_HOME/bin:" <<<":$PATH:" >/dev/null; then
    #    export PATH="$CONDA_HOME/bin:$PATH"
    #fi
fi

# devpi
local_devpi() {
    devpi use http://localhost:3141/
    devpi login local
    devpi use local/dev
}
