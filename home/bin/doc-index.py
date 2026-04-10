#! /usr/bin/env python3
""" A tool that lists major folders within a tree of personal documents.

    The config in `~/.config/doc-index/config.yaml` specifies the root folder
    to index and an exclusion list for the automatic classification, consisting
    of folder names to ignore (glob patterns).

    The output is structured like that of `tree`.

    The tree is cached in `~/.cache/doc-index/tree-cache.yaml` to speed up subsequent runs.
    The cache is updated automatically when the tool is run, after a day has passed or
    when `--refresh` is specified.

    The `--create-config` option creates a default configuration file if it doesn't
    exist yet, and displays its full path and contents.

    The `--pick` option uses the Python `pick` library to allow the user to
    interactively select a folder from the tree, and prints the full path of
    the selected folder to stdout. This can be used in a shell script to open
    the folder in a file manager or terminal. If the user aborts the selection,
    the tool exits with a non-zero status code.

    Option `--fzf` (or `-f`) changed the output to print each selection as 
    `full path\tnormal display name` to be used with *fzf*'s `--with-nth=2`
    and `--delimiter='\t'` options.

    Walking the tree is stopped when one of these things is encountered (and the
    folder is not included in the output):

        - a year (YYYY) in the folder name
        - a folder that matches an exclusion pattern
        - a folder at depth 4 or more (to avoid going too deep into the tree)

    Files are not part of the tree, just folder names. The presence of files is only
    used to determine the type of a folder, but they are not printed in the output.

    Example use of `--fzf` in a shell script to change to the selected folder:

        alias go-doc='cd "$(doc-index -rf | fzf --layout=reverse --with-nth=2 --delimiter='"'\\t'"' | cut -f1)"'
"""

import os
import re
import sys
import glob
import json
import time
import argparse
from pathlib import Path
from datetime import datetime, timedelta


try:
    import yaml
except ImportError:
    print("⚡ Missing required module 'yaml'. Install it with:\n"
          "    python3 -m pip install --user pyyaml", file=sys.stderr)
    sys.exit(2)

try:
    from termcolor import colored
except ImportError:
    def colored(text, color=None):
        return text

try:
    from pick import pick
except ImportError:
    pick = None

CONFIG_PATH = os.path.expanduser("~/.config/doc-index/config.yaml")
CACHE_DIR = os.path.expanduser("~/.cache/doc-index/")
CACHE_FILE = os.path.join(CACHE_DIR, "tree-cache.yaml")
CACHE_AGE_DAYS = 1
MAX_DEPTH = 3

DEFAULT_CONFIG = {
    'root': os.path.expanduser('~/Documents'),
    'exclude': ['*.tmp', '*.bak', 'node_modules', '__pycache__'],
    'keywords': {
        'work': ['work', 'project', 'client'],
        'personal': ['personal', 'family', 'photos'],
        'financial': ['tax', 'invoice', 'bank', 'finance']
    }
}

def create_default_config():
    os.makedirs(os.path.dirname(CONFIG_PATH), exist_ok=True)
    if not os.path.exists(CONFIG_PATH):
        with open(CONFIG_PATH, 'w') as f:
            yaml.dump(DEFAULT_CONFIG, f)
    with open(CONFIG_PATH) as f:
        content = f.read()
    print(f"Default config at: {CONFIG_PATH}\n\n{content}")

def load_config():
    if not os.path.exists(CONFIG_PATH):
        print(f"⚡ Config not found. Run with --create-config to generate a default config.", file=sys.stderr)
        sys.exit(1)
    with open(CONFIG_PATH) as f:
        return yaml.safe_load(f)

def is_excluded(name, exclude_patterns):
    for pat in exclude_patterns:
        if glob.fnmatch.fnmatch(name, pat):
            return True
    return False

def classify_folder(name, files, keywords):
    for ktype, kwlist in keywords.items():
        for kw in kwlist:
            if kw.lower() in name.lower():
                return ktype
            for f in files:
                if kw.lower() in f.lower():
                    return ktype
    return 'other'

def has_year(name):
    # Match a 4-digit year between 1900 and 2099
    return re.search(r'(19|20)\d{2}', name) is not None

def scan_tree(root, exclude, keywords):
    tree = {}
    for dirpath, dirnames, filenames in os.walk(root):
        relpath = os.path.relpath(dirpath, root)
        if relpath == '.':
            relpath = ''
        # Calculate depth (root is depth 0)
        depth = 0 if not relpath else relpath.count(os.sep) + 1
        # Exclude dirs in-place, and also exclude any dir with a year in the name or at depth >= MAX_DEPTH
        dirnames[:] = [d for d in dirnames if not is_excluded(d, exclude) and not has_year(d) and (depth < MAX_DEPTH)]
        if is_excluded(os.path.basename(dirpath), exclude):
            continue
        # Exclude this folder if it has a year in the name or is at depth >= MAX_DEPTH
        if has_year(os.path.basename(dirpath)) or depth >= MAX_DEPTH:
            continue
        ktype = classify_folder(os.path.basename(dirpath), filenames, keywords)
        tree[relpath] = {
            'type': ktype,
            'files': filenames,  # files are still used for classification
            'dirs': dirnames
        }
    return tree

def save_cache(tree):
    os.makedirs(CACHE_DIR, exist_ok=True)
    with open(CACHE_FILE, 'w') as f:
        yaml.safe_dump({'tree': tree, 'timestamp': time.time()}, f)

def load_cache():
    if not os.path.exists(CACHE_FILE):
        return None
    with open(CACHE_FILE) as f:
        data = yaml.safe_load(f)
    return data

def cache_is_stale():
    if not os.path.exists(CACHE_FILE):
        return True
    with open(CACHE_FILE) as f:
        data = yaml.safe_load(f)
    age = time.time() - data.get('timestamp', 0)
    return age > CACHE_AGE_DAYS * 86400

def print_tree(tree, root, keywords):
    def print_branch(path, prefix='', is_last=True):
        node = tree.get(path)
        if not node:
            return

        name = os.path.basename(path) if path else os.path.basename(root)
        connector = '└── ' if is_last else '├── '
        if prefix == '':
            print(f"{name}/")
        else:
            print(f"{prefix}{connector}{name}/")
        # Only print subdirs, not files
        dirs = sorted(node['dirs'])
        for i, d in enumerate(dirs):
            subpath = os.path.join(path, d) if path else d
            is_last_dir = (i == len(dirs) - 1)
            print_branch(subpath, prefix + ('    ' if is_last else '│   '), is_last_dir)
    print_branch('')

def display_name(relpath, name):
    depth: int = relpath.count(os.sep) if relpath else 0
    return '    ' * depth + name.replace(os.sep, " > ")  # Show hierarchy with ' > '

def main():
    parser = argparse.ArgumentParser(description="List major folders in a document tree.")
    parser.add_argument('-f', '--fzf', action='store_true', help='Output each folder as fullpath<TAB>displayname for fzf integration')
    parser.add_argument('-p', '--pick', action='store_true', help='Interactively pick a folder from the tree')
    parser.add_argument('-r', '--refresh', action='store_true', help='Refresh the cache')
    parser.add_argument('--create-config', action='store_true', help='Create a default config file')
    args = parser.parse_args()

    if args.create_config:
        create_default_config()
        return

    config = load_config()
    root = str(Path(config['root']).expanduser())
    exclude = config.get('exclude', [])
    keywords = config.get('keywords', {})

    use_cache = not args.refresh and not cache_is_stale()
    if use_cache:
        data = load_cache()
        tree = data['tree']
    else:
        tree = scan_tree(root, exclude, keywords)
        save_cache(tree)

    if args.pick:
        if pick is None:
            print("⚡ The 'pick' library is required for --pick. Install with:\n"
                  "    python3 -m pip install --user pick", file=sys.stderr)
            sys.exit(2)
        # Gather all folder paths in the tree
        folder_paths = []
        for relpath in sorted(tree.keys()):
            fullpath = os.path.join(root, relpath) if relpath else root
            folder_paths.append((relpath, fullpath))

        # Show only non-root if more than one
        options = []
        option_map = []
        for relpath, _ in folder_paths:
            name = relpath or os.path.basename(root)
            colored_name = display_name(relpath, name)
            options.append(colored_name)
            option_map.append(name)

        title = "Select a folder:"
        try:
            option, idx = pick(options, title)
        except (KeyboardInterrupt, EOFError):
            sys.exit(1)
        print(folder_paths[idx][1])
        return

    if args.fzf:
        # Output each folder as 'fullpath<TAB>displayname' for fzf, using 'a > b > c' format
        for idx, relpath in enumerate(sorted(tree.keys())):
            if idx == 0 and relpath == '':
                continue  # Skip root if it's the first entry
            fullpath = os.path.join(root, relpath) if relpath else root
            display_name_str = display_name(relpath, relpath or os.path.basename(root))
            print(f"{fullpath}\t{display_name_str}")
        return

    print_tree(tree, root, keywords)

if __name__ == "__main__":
    main()
