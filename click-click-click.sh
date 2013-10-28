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

root="$(cd "$(dirname "$0")" && pwd)"
linkbase="$root/home"

( cd "$linkbase" && find . -type f $names ) | sort | while read file; do
    # omit "./"
    file="${file:2}"

    # skip (editor) junk
    case "$file" in
        *~ | *.swp | *.tmp) echo "*** Ignoring $file" ; continue ;;
    esac

    # try to link file
    target="${file}"
    if test "${target:0:4}" = "bin/"; then
        target="${target%.py}"
        target="${target%.sh}"
    fi

    dstdir=$(dirname ~/"$target")
    test -d "$dstdir" || $DRY mkdir -p "$dstdir"
    if test -h ~/"$target"; then
        # symlinked
        test $(readlink ~/"$target") = "$linkbase/$file" || echo ~/"$target" "=->" "$linkbase/$file"
        $DRY $LN_F "$linkbase/$file" ~/"$target"
    elif test -f ~/"$target"; then
        # conflict
        diff -b -U1 ~/"$target" "$linkbase/$file" || \
            { echo; echo rm ~/"$target" "# to get this file out of the way"; echo; }
    else
        # missing
        echo ~/"$target" "+->" "$linkbase/$file"
        $DRY $LN "$linkbase/$file" ~/"$target"
    fi
done
