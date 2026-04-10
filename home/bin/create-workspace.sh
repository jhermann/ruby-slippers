#!/usr/bin/env bash
#
# Create a VS Code workspace file (.code-workspace) for the current git repo.
# The file is placed at the repo root, named after the repository directory.
#
set -euo pipefail

git_root=$(git rev-parse --show-toplevel)
name=$(basename "$git_root")
outfile="${git_root}/${name}.code-workspace"

if [[ -e "$outfile" ]]; then
    echo "⚠️ INFO: workspace file already exists, skipping: $outfile"
    exit 0
fi

cat > "$outfile" <<EOF
{
    "folders": [
        {
            "path": "."
        }
    ],
    "settings": {}
}
EOF

echo "ℹ️ Created: $outfile"
