if test -d ~/bin; then
    # Make sure ~/bin is in PATH exactly ONCE, in front of everything else
    PATH="$HOME/bin:$(tr : \\n <<<"$PATH" | egrep -v '^$' | egrep -v '^'"$HOME/bin"'$' | tr \\n :)"
    PATH="${PATH%:}"
    export PATH
fi
