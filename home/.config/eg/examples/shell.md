# bash Tips & Tricks

## Useful Commands

Recursively find all lines that contain Unicode characters (non-ASCII ones).

    grep -nRP "[^\x00-\x7F]" src
