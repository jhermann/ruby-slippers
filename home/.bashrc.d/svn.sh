# SVN helpers

__svn_co_trunk() { # take a trunk URL and checkout into a dir named after the project
    local svnurl prjname
    svnurl="$1"
    prjname="${svnurl%/}"
    prjname="${prjname%/*}"
    prjname="${prjname##*/}"
    svn co "$svnurl" "$prjname"
}
alias svn-co-trunk=__svn_co_trunk
