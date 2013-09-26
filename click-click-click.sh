#! /bin/bash
#
# Link version-controlled home skeleton into user account.
#

DRY=
test "$1" = "-n" && { DRY="echo WOULD call:"; shift; }

LN="ln -s"; LN_F="ln -nfs"
test "$1" = "-c" && { LN="cp -n"; LN_F="cp --backup numbered"; shift; }

names=""
test -n "$1" && { names="-iname *$1*"; shift; }

set -e

root=$(cd $(dirname "$0") && pwd)
linkbase="$root/home"

( cd "$linkbase" && find . -type f $names ) | while read file; do
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
        $DRY $LN_F "$linkbase/$file" ~/"$file"
    elif test -f ~/"$file"; then
        # conflict
        diff -b -U1 ~/"$file" "$linkbase/$file" || \
            { echo; echo rm ~/"$file" "# to get this file out of the way"; echo; }
    else
        # missing
        echo ~/"$file" "+->" "$linkbase/$file"
        $DRY $LN "$linkbase/$file" ~/"$file"
    fi
done
