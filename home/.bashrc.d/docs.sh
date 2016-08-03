md2rst() {
    local file="${1:-README.md}"
    pandoc --from markdown --to rst --toc --reference-links -o ${file/.md/.rst} ${file}
    test \! -d .git || git add ${file/.md/.rst}
}
