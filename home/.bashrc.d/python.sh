#
# Python related stuff
#
RUBY_SLIPPERS_VENV="$HOME/.local/virtualenvs/ruby-slippers"
test -d "$RUBY_SLIPPERS_VENV" \
    || RUBY_SLIPPERS_VENV="$HOME/.pyvenv/ruby-slippers"

export VIRTUALENV_NO_DOWNLOAD=1

alias click-click-click='source $RUBY_SLIPPERS_VENV/bin/activate'
alias pyzen="python -c 'import this'"
alias pypi="pip install -i https://pypi.python.org/simple"
alias pip="python3 -m pip"
alias pip2="python2 -m pip"
alias pip3="python3 -m pip"

# Make pydoc work in virtualenvs, and also alias the system pydoc
alias pydoc="python3 -m pydoc"
alias pydoc2="python2 -m pydoc"
alias pydoc3="python3 -m pydoc"
alias spydoc="command pydoc"

# Activate "~/.local/bin" binaries
if test -d ~/.local/bin && ! grep ":$HOME/.local/bin:" <<<":$PATH:" >/dev/null; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Activate "/opt/pyenv/bin" binaries (low prio)
if test -d /opt/pyenv/bin && ! grep ":/opt/pyenv/bin:" <<<":$PATH:" >/dev/null; then
    export PATH="$PATH:/opt/pyenv/bin"
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
