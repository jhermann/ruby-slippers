#! /bin/bash
#
# Make a GIT user and empty repo
# cf. http://git-scm.com/book/en/Git-on-the-Server-Setting-Up-the-Server
#

GIT_REPO=${1:?Please provide a repository name as the first argument, and optionally an account name}
GIT_USER=${2:-git}
GIT_HOME=/var/lib/git/$GIT_USER

id $GIT_USER || \
    adduser --shell /usr/bin/git-shell --system --disabled-password \
        --home $GIT_HOME --gecos "$GIT_USER git repository account" $GIT_USER

as_git="su $GIT_USER -s /bin/bash -c"

$as_git "mkdir -p $GIT_HOME/.ssh"
$as_git "test -f $GIT_HOME/.ssh/authorized_keys || touch $GIT_HOME/.ssh/authorized_keys"
$as_git "mkdir -p $GIT_HOME/$GIT_REPO.git"
$as_git "cd $GIT_HOME/$GIT_REPO.git; test -e HEAD || git --bare init"

$as_git "mkdir -p $GIT_HOME/git-shell-commands"

cat >$GIT_HOME/git-shell-commands/no-interactive-login <<'EOF'
#!/bin/sh
echo
echo "You've successfully authenticated to '$USER@$(hostname -f)', but there"
echo "is no interactive shell access."
echo
echo "You can only push to or pull from these existing repositories:"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
for repo in *.git; do
    head="$repo/$(grep '^ref:' $repo/HEAD | cut -d' ' -f2-)"
    echo "$USER@$(hostname -f):$repo $(cat $head) $(stat -c '%y' $head)"
done
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
exit 128
EOF
chmod +x $GIT_HOME/git-shell-commands/no-interactive-login
chown $GIT_USER.$(id -gn $GIT_USER) $GIT_HOME/git-shell-commands/no-interactive-login

echo "Append allowed public keys to $GIT_HOME/.ssh/authorized_keys, e.g."
echo "    cat >>$GIT_HOME/.ssh/authorized_keys <~/.ssh/id_rsa.pub"
