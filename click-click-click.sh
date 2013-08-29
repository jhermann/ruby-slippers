#! /bin/bash

DRY=
#DRY=:

root=$(cd $(dirname "$0") && pwd)
linkbase="$root/home"

( cd "$linkbase" && find . -type f ) | while read file; do
    file="${file:2}"
    case "$file" in
        *~ | *.swp | *.tmp) echo "*** Ignoring $file" ; continue ;;
    esac

    dstdir=$(dirname ~/"$file")
    test -d "$dstdir" || $DRY mkdir -p "$dstdir"
    if test -h ~/"$file"; then
        test $(readlink ~/"$file") = "$linkbase/$file" || echo ~/"$file" "<==" "$linkbase/$file"
        $DRY ln -nfs "$linkbase/$file" ~/"$file"
    elif test -f ~/"$file"; then
        echo
        diff -U1 ~/"$file" "$linkbase/$file"
        echo rm ~/"$file" "# to get this file out of the way"
        echo
    else
        echo ~/"$file" "<++" "$linkbase/$file"
        $DRY ln -s "$linkbase/$file" ~/"$file"
    fi
done
