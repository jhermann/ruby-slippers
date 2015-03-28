#! /bin/bash
#
# give your host what's missing...
# (currently, only supported on debian-like systems)
#
set -e
tmpbase="/tmp/$(basename "$0")-$USER-$$"

apt_install_yes=
continue_after_apt_errors=true
while test "${1:0:1}" = "-"; do
    case "$1" in
        -y | --yes) apt_install_yes="-y" ;;
        -E | --abort-on-errors) continue_after_apt_errors=false ;;
        *) echo "WARNING: Ignored unknown option '$1'" ;;
    esac
    shift
done

action="$1"; shift || :


install_pkglist() {
    local pkglist pkg
    pkglist="$1"

    cat "$pkglist" | while read pkg; do
        test -n "$pkg" -a "${pkg:0:1}" != "#" || { echo "$pkg"; continue; }

        if ( dpkg -l "$pkg" | egrep "^ii +$pkg " ) >/dev/null ; then
            echo "*** $pkg: already installed"
        else
            echo "+++ $pkg: installing..."
            sudo apt-get -q install $apt_install_yes "$pkg" </dev/tty || $continue_after_apt_errors
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
        echo "usage:" $(basename "$0") "[-y|--yes]" "[-E|--abort-on-errors]" "all|sort"
        exit 1
        ;;
esac
