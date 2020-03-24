if test -n "$SYSTEMROOT" -a -n "$WINDIR"; then
    # git bash (MingW) environment
    export PS1="${PS1%%\$ *}\$ "

    alias xdg-open=start

    test -n "$SSH_AGENT_PID" || eval $(ssh-agent)
    ##ssh-add ~/.ssh/github
fi
