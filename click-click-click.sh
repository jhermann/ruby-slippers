#! /bin/bash
#
# Link version-controlled home skeleton into user account.
#

DRY=
test "$1" = "-n" && DRY=:

set -e

root=$(cd $(dirname "$0") && pwd)
linkbase="$root/home"

( cd "$linkbase" && find . -type f ) | while read file; do
    # omit "./"
    file="${file:2}"

    # skip (editor) junk
    case "$file" in
        *~ | *.swp | *.tmp) echo "*** Ignoring $file" ; continue ;;
    esac

    # try to link file
    dstdir=$(dirname ~/"$file")
    test -d "$dstdir" || $DRY mkdir -p "$dstdir"
    if test -h ~/"$file"; then
        # symlinked
        test $(readlink ~/"$file") = "$linkbase/$file" || echo ~/"$file" "=->" "$linkbase/$file"
        $DRY ln -nfs "$linkbase/$file" ~/"$file"
    elif test -f ~/"$file"; then
        # conflict
        echo
        diff -U1 ~/"$file" "$linkbase/$file"
        echo rm ~/"$file" "# to get this file out of the way"
        echo
    else
        # missing
        echo ~/"$file" "+->" "$linkbase/$file"
        $DRY ln -s "$linkbase/$file" ~/"$file"
    fi
done
