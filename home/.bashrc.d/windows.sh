if test -n "$SYSTEMROOT" -a -n "$WINDIR"; then
    # git bash (MingW) environment
    export PS1="${PS1%%\$ *}\$ "
    export LANG=en_US.UTF-8
    export GG_BROWSER=start
    prependpathvar PATH "$HOME/.local/bin"

    alias xdg-open=start
    alias python3="winpty py -3"
    alias python=python3

    chcp.com 65001 >/dev/null  # use UTF-8 codepage
    test -n "$SSH_AGENT_PID" || eval $(ssh-agent)
    ##ssh-add ~/.ssh/github
fi
