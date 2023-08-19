# pandoc

## Useful Commands

Convert HTML fragment without CSS and other decorations into Markdown.

    pandoc --smart -f html -t markdown_github-raw_html INP.html -o OUT.md

Show start of EPUB as plain text (with some BBcode support).

    pandoc -f epub -t plain DOC.epub \
        | tr -s \\n | sed -re 's#_(.+?)_#[i]\1[/i]#g' \
        | head -n 99 | less
