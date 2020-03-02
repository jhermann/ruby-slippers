# Linuxbrew environment
if test -d /home/linuxbrew/.linuxbrew; then
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv | sed s#/var/#/#g)
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    if test -d $HOME/perl5/lib/perl5; then
        eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"
    fi
fi
