# README

Duplicity, the built-in backup utility on Ubuntu, doesn't support adding wildcards or directory names to ignore when running backups - only full directory paths. Additionally, to set these programatically via `gsettings` requires some specific formatting and escaping.

Enter `deja-dirs`, a simple bash utility for matching and generating lists of directories to be added to Duplicity via gsettings.

For a basic invocation, simply call `deja-dirs` with the name of the directory to exclude:

```
~/ > cd workdir
~/workdir/ > deja-dirs node_modules
'project1/node_modules', 'project2/front-end/js/node_modules'
~/workdir/ >
```

The `deja-dirs` utility has the following options:

- `-b` allows you to set the base directory that file discovery happens from. When `-b` is not set, the default is the current working directory.
- `-c` allows you to specify a file that must be contained in the directory for it to match. For example, to match PHP `vendor` directories you could specify `-c autoload.php`.

To create a script that you can use to manually or automatically update the list of excluded directories in Duplicity, you first need to get your current exclude list. You can do this with:

```
~/ > gsettings get org.gnome.DejaDup exclude-list
['/home/bk/Downloads', '/home/bk/.cache']
```

With these directories added to some patterns I want to match, I could have a script like this:

```bash
#! /bin/bash

set -o errexit -o nounset -o pipefail

EXCLDIRS="['$HOME/Downloads', '$HOME/.cache'"
EXCLDIRS+=", "
EXCLDIRS+="$(deja-dirs "Cache" -b "$HOME/.config")"
EXCLDIRS+=", "
EXCLDIRS+="$(deja-dirs "CacheStorage" -b "$HOME/.config")"
EXCLDIRS+=", "
EXCLDIRS+="$(deja-dirs "vendor" -c "autoload.php" -b "$HOME/workspace")"
EXCLDIRS+=", "
EXCLDIRS+="$(deja-dirs "node_modules" -b "$HOME/workspace")"
EXCLDIRS+="]"

echo "${EXCLDIRS}"
echo

read -p "Set exclude-list to the above directories? (y/n) > " C

if [[ ! "${C}" = "y" ]]
then
  echo "Aborting" 1>&2
  exit 1
fi

gsettings set org.gnome.DejaDup exclude-list "${EXCLDIRS}"
```

Without the confirmation dialog, this could be automated on a cronjob to automatically update your exclude list as you add or remove files from your machine.
