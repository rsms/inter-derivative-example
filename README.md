Note that "Lolcat" is used as an example font family name.

## Building

### First-time setup

```sh
$ git clone --recurse-submodules https://github.com/rsms/lolcat-inter.git
$ cd lolcat-inter
$ ./init.sh
```

### Build using make

`install` builds the variable font and install it to `~/Library/Fonts/Lolcat`:

```sh
$ make install
```

Other make targets:

- `all` build all font files
- `clean` remove all build product (start from scratch)
- `test` build all font files and run QA tests
- `var` build the variable font (quickest turn-around for testing)


## Upstream Inter

To mark a glyph as being customized, add `lolcat` to its tags.
Glyphs without this tag are overwritten by the `update-inter` scripts.

To update upstream Inter and apply changes:

1. Make sure to save & commit any outstanding changes to LolcatInter.glyphspackage
2. Run `./update-inter.sh`
3. Test and review any changes
4. Commit (e.g. `git commit -m 'Update Inter' -a`)
