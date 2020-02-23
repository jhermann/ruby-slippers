# Show current git branch in prompt, unless it's "master"
#
# Based on https://ttboj.wordpress.com/2013/10/10/show-current-git-branch-in-ps1-when-branch-is-not-master/
if test "$(type -t __git_ps1)" = "function" ; then
    test -z "$PS1_NO_GIT" && export PS1_NO_GIT="$PS1" || export PS1="$PS1_NO_GIT"
    branch_on_demand='echo -e " \e[32m"$(__git_ps1 "%s")"\e[0m"'
    branch_on_demand='$([ "$(__git_ps1 %s)" != "" -a "$(__git_ps1 %s)" != "master" ] && '"$branch_on_demand"' || :)'
    PS1="${PS1%%\\\$ }$branch_on_demand\$ "
    unset branch_on_demand
fi

export GITHUB_USER=jhermann
export GG_BROWSER=firefox

github_clone_fork() {
    local upstream="${1:?You need to provide an upstream repo name (user/name) as the 1st arg}"
    local user="${upstream%/*}"
    local repo="${upstream#*/}"

    git clone "git@github.com-jh:jhermann/$repo.git"
    cd "$repo"
    git remote add upstream "https://github.com/$upstream.git"
    git-config-jhermann
    git remote update # test repos
}
