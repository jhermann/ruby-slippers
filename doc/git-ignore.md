## (Temporarily) Ignoring Changed Files

`git update-index` offers the `--assume-unchanged` option to tell git that it should, well, assume the files provided with that option are unchanged. This excludes that file from being considered for `git commit -a`, `git add .`, and so on.

Practical uses are ignoring local changes to files that should never be committed, like changing the version / distro in a `debian/changelog`, or adding git status information to an in-development version number stored in build configuration files.

Any upstream changes on such files cause a merge conflict that must be manually resolved. Also note you can always *explicitly* add such files to a change set.

To help with daily usage, add these to the `[alias]` section of your `~/.gitconfig`:

    ignore = update-index --assume-unchanged
    unignore = update-index --no-assume-unchanged

To list the files marked as unchanged, put this script into `~/bin/git-ignored`:

    #! /usr/bin/env bash
    # Show "assumed unchanged" files in the current repo
    repo=$(git rev-parse --show-toplevel)
    test -z "$1" || { repo="$1"; shift; }
    git ls-files -v "$@" "$repo" | grep "^[a-z]"

The final result is this:

> ![git-ignore.gif](https://raw.githubusercontent.com/jhermann/ruby-slippers/master/doc/_static/git-ignore.gif)
