if grep Microsoft /proc/version >/dev/null 2>&1; then
    # Running on WSL (v1)
    alias dpkg-buildpackage="command dpkg-buildpackage -r'fakeroot --faked faked-tcp'"
    alias code="/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft_VS_Code/bin/code"
    alias xdg-open=wslview

    export DISPLAY=:0
    export LIBGL_ALWAYS_INDIRECT=1
    export BROWSER=wslview  # "$HOME/.local/bin/firefox"

    test -n "$SSH_AGENT_PID" || eval $(ssh-agent)
    ##ssh-add ~/.ssh/github
elif test -n "$SYSTEMROOT" -a -n "$WINDIR"; then
    # git bash (MingW) environment
    export PATH=$(tr : \\n <<<"$PATH" | grep -v Oracle/Java | grep -v Local/Microsoft/WindowsApps | tr \\n :)
    export PATH="${PATH%:}"
    ##echo "$PATH" | tr \;\: \\n\\n

    export PS1="${PS1%%\$ *}\$ "
    export BROWSER="/c/ProgramData Files (x86)/Mozilla Firefox/firefox.exe"
    #export BROWSER=$(cygpath -w "$BROWSER")
    #export BROWSER="$BROWSER;$HOME/AppData/Local/Google/Chrome/Application/chrome.exe"
    export LANG=en_US.UTF-8
    export PYTHONIOENCODING=UTF-8
    export PYTHONUTF8=1
    export PYTHONPYCACHEPREFIX="$HOME/.local/cache/pycache"
    export GG_BROWSER=start
    export PATH="$HOME/.local/bin:$PATH"

    cdw() {
        local dir=$(cygpath -u "$1")
        cd "$dir"
    }

    alias xdg-open=start
    alias docker="winpty docker.exe"
    alias python3="winpty py -3"
    alias python3.6="winpty py -3.6"
    alias python3.7="winpty py -3.7"
    alias python3.8="winpty py -3.8"
    alias python=python3
    alias identify="magick identify"
    alias convert="magick convert"
    alias mogrify="magick mogrify"
    alias montage="magick montage"

    test -d "$PYTHONPYCACHEPREFIX" || unset PYTHONPYCACHEPREFIX
    chcp.com 65001 >/dev/null  # use UTF-8 codepage
    test -n "$SSH_AGENT_PID" || eval $(ssh-agent)
    ##ssh-add ~/.ssh/github
fi
