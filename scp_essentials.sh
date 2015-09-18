#! /bin/bash
#
# Copy essential configs to target host via scp

FILES=(
    .bash_aliases .bash_completion
    .env .screenrc .hgrc .nodeenvrc .vimrc
    .gitignore_global .gitconfig
    .ansible.cfg .cookiecutterrc .invoke.yaml .pylintrc
    .bashrc.d/aliases.sh .bashrc.d/bash4.sh .bashrc.d/basics.sh
    .bashrc.d/git.sh .bashrc.d/python.sh
    bin/diffb bin/findall bin/grepall bin/txa
)
# .bashrc.d .local .config .bash_completion.d

target=${1:?"You need to provide a '[user@]targethost' argument!"}
basedir=$(command cd $(dirname "$0") && pwd)

for name in ${FILES[@]}; do
    test "$(dirname "$name")" = '.' || ssh $target "mkdir -p $(dirname $name)"
    scp "$basedir/home/$name" $target:$name
done
