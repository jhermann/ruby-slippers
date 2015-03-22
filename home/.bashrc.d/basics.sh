#
# Basic preferences
#

umask 0027
export EDITOR=vi
grep :~/bin: <<<":$PATH:" >/dev/null || export PATH=~/bin:"$PATH"

export AUTOSSH_MAXSTART=666
export AUTOSSH_PORT=61443

case "$TERM" in
    xterm*) TERM=xterm-256color ;;
esac

# Helpers
imgur() {
    for i in "$@";do
        curl -# -F "image"=@"$i" -F "key"="4907fcd89e761c6b07eeb8292d5a9b2a" http://imgur.com/api/upload.xml | \
            grep -Eo '<[a-z_]+>http[^<]+'|sed 's/^<.\|_./\U&/g;s/_/ /;s/<\(.*\)>/\x1B[0;34m\1:\x1B[0m /'
    done
}

isodate() {
    date +'%Y-%m-%d'
}

isotime() {
    date +'%Y-%m-%dT%H:%M:%S%:z'
}

hgrep() {
    history | egrep "$@"
}
