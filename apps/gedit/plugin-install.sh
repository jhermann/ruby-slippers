#! /bin/bash
set -e
PLUGIN_DIR="$HOME/.local/share/gedit/plugins"

get_github_commit() {
    local target user repo sha1 pluginsrc
    target="$1"; shift
    user="$1"; shift
    repo="$1"; shift
    sha1="$1"; shift
    pluginsrc="$1"; shift

    test -f "${workdir}/${sha1}.zip" || \
        wget "https://github.com/${user}/${repo}/archive/${sha1}.zip" -O "${workdir}/${sha1}.zip"
    unzip -j "${workdir}/${sha1}.zip" "${repo}-${sha1}/${pluginsrc}/*" -d "$target"
}

compile_schema() {
    local schema
    schema="$1"; shift

    schema_dir="/usr/share/glib-2.0/schemas"
    test -f "$schema_dir/$schema" || { \
        echo "Compiling schema $schema..."; \
        sudo bash -c "cp $PLUGIN_DIR/$schema $schema_dir; glib-compile-schemas $schema_dir"; }
}

workdir=$(dirname "$0")/".cache"
test -d "$PLUGIN_DIR" || mkdir -p "$PLUGIN_DIR"
test -d "$workdir" || mkdir "$workdir"

get_github_commit "$PLUGIN_DIR" \
    dtrebbien gedit-trim-trailing-whitespace-before-saving-plugin d0a761f55b825a33c0ffe9b0f38651d6b975c5a5 src
compile_schema "org.gnome.gedit.plugins.trimtrailingws.gschema.xml"

ls -lrt "$PLUGIN_DIR"/*.plugin
