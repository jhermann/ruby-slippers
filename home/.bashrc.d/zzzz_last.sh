if test -d ~/bin; then
    PATH="$HOME/bin:$(tr : \\n <<<"$PATH" | egrep -v '^$' | egrep -v '^'"$HOME/bin"'$' | tr \\n :)"
    PATH="${PATH%:}"
    export PATH
fi
