if test -n "$SYSTEMROOT" -a -n "$WINDIR"; then
    # git bash (MingW) environment
    export PATH=$(tr : \\n <<<"$PATH" | grep -v Oracle/Java | grep -v Local/Microsoft/WindowsApps | tr \\n :)
    export PATH="${PATH%:}"
    ##echo "$PATH" | tr \;\: \\n\\n

    export PS1="${PS1%%\$ *}\$ "
    export LANG=en_US.UTF-8
    export PYTHONIOENCODING=UTF-8
    export PYTHONUTF8=1
    export PYTHONPYCACHEPREFIX="$HOME/.local/cache/pycache"
    export GG_BROWSER=start
    export PATH="$HOME/.local/bin:$PATH"

    alias xdg-open=start
    alias python3="winpty py -3"
    alias python=python3

    test -d "$PYTHONPYCACHEPREFIX" || unset PYTHONPYCACHEPREFIX
    chcp.com 65001 >/dev/null  # use UTF-8 codepage
    test -n "$SSH_AGENT_PID" || eval $(ssh-agent)
    ##ssh-add ~/.ssh/github
fi
