#
# Go related stuff
#

export GOPATH=$HOME/lib/gocode

export GIMME_VERSION_PREFIX="$HOME/.local/gimme/versions"
export GIMME_ENV_PREFIX="$HOME/.local/gimme/envs"

export GOVERSION=1.5.1
if test -d ~/.gimme/versions/go${GOVERSION}.*; then
    unset GOOS
    unset GOARCH
    export GOROOT="$HOME/.gimme/versions/go${GOVERSION}.linux.amd64"
    export GIMME_ENV="$HOME/.gimme/envs/go${GOVERSION}.env"

    grep ":$HOME/.gimme/versions/go${GOVERSION}.linux.amd64/bin:" <<<":$PATH:" >/dev/null \
        || export PATH="$HOME/.gimme/versions/go${GOVERSION}.linux.amd64/bin:${PATH}"
fi
