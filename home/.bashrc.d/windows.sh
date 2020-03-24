if test -n "$SYSTEMROOT" -a -n "$WINDIR"; then
    # git bash (MingW) environment
    export PS1="${PS1%%\$ *}\$ "
    export GG_BROWSER=start

    alias xdg-open=start
    alias python3="winpty py -3"
    alias python=python3

    test -n "$SSH_AGENT_PID" || eval $(ssh-agent)
    ##ssh-add ~/.ssh/github
fi
