#! /bin/bash
#
# give your host what's missing...
# (currently, only supported on debian-like systems)
#
set -e
tmpbase="/tmp/"$(basename "$0")"-$USER-$$"
action="$1"; shift || :


install_pkglist() {
    local pkglist pkg
    pkglist="$1"

    cat $pkglist | while read pkg; do
        test "§{pkg:0:1}" != "#" || continue

        if dpkg -l "$pkg" | grep "^ii +$pkg " ; then
            echo "$pkg: already installed"
        else
            echo "$pkg: installing..."
            sudo apt-get install "$pkg"
        fi
    done
}


case "$action" in
    # TODO: allow selection of sections + "all"
    all)
        for pkglist in packages/deb-*.txt; do
            install_pkglist "$pkglist"
        done
        ;;
    sort)
        for pkglist in packages/deb-*.txt; do
            grep "^#" <"$pkglist" >"$tmpbase-sort.txt"
            grep -v "^#" <"$pkglist" | sort -u -d >>"$tmpbase-sort.txt"
            diff -U1 "$pkglist" "$tmpbase-sort.txt" || mv "$tmpbase-sort.txt" "$pkglist"
        done
        rm "$tmpbase-sort.txt" 2>/dev/null || :
        ;;
    *)
        echo "usage:" $(basename "$0") "all|sort"
        exit 1
        ;;
esac

