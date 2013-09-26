# ![Logo](https://raw.github.com/jhermann/ruby-slippers/master/doc/_static/ruby-slippers-logo.png) ruby-slippers

There's no place like home…

```sh
mkdir -p "$HOME/src/github"
cd "$HOME/src/github"
git clone "https://github.com/jhermann/ruby-slippers.git"
cd "ruby-slippers"
./click-click-click.sh -n
```

To bless your machine with about 1GiB of (DEB-)packaged goodness…

```sh
./tinmans-heart.sh all
```

Doing this increases the chances tremendously that your scripts
and CI jobs work the same on every machine (like, not fail ☺).

Finally, to install some tools local to your account:

```sh
./scarecrows-brain.sh
```

Most notably you'll get code quality (`pylint`, `flake8`) and productivity tools
(`bpython`, and the incredibly useful `http` from [httpie](http://httpie.org/)).
The Python tools are installed into a dedicated Python *virtualenv* (`~/.pyvenv/ruby-slippers`),
and then symlinked into `~/bin`.


## References

* [GitHub ❤ ~/](http://dotfiles.github.io/)
* [Keep your dotfiles fresh](https://github.com/freshshell/fresh)
