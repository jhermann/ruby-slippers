# Debian / Ubuntu Ruby

#export GEM_HOME="$HOME/.local/gems"
# ln -nfs .local/gems ~/.gem

gem() {
    if [[ "$1" == "install" ]]; then
        shift
        command gem install --user-install "$@"
    else
        command gem "$@"
    fi
}


if builtin hash ruby 2>/dev/null; then
    gem_user_dir="$(ruby -r rubygems -e 'puts Gem.user_dir')"
    test -d "$gem_user_dir/bin" || mkdir -p "$gem_user_dir/bin"
    prependpathvar PATH "$(realpath $gem_user_dir)/bin"
    unset gem_user_dir
fi
