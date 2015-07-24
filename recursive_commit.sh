#!/bin/zsh

: ' recursive_commit.sh - AtoZUniversal - Created by Alex Gray on 6/2/15.
		
		1. Source Prezto.
'

[[ $1 =~ ^-{1,3}($|h$|help)$ ]] && cat <<DOCUMENTATION

Blah blah blah.
---------------------------------------------------------------
The command-line ...

DOCUMENTATION

[ -s "${PREZTOINIT=${ZDOTDIR:-$HOME}/.zprezto/init.zsh}" ] && . "$PREZTOINIT"

echo "$FX[blink]$BG[blue] $(figlet -f univers $(git reponame)) $BG[none]"

set -e

[[ "$@" =~ "--dry-run" ]] && DRY=1

GITROOT="$(git root)"
ROOT="$(basename $(pwd))"
ALLMODS="$(git submodules)"

doACP() {

  set -x     #  echo "\n\nmoving to $1\n";
  cd "$1"
  git status; # git diff;
  read s
  git diff
  echo "\n\nACP message for $(basename $GITROOT) submodule $(git reponame)?" # ${1/$GITROOT/}?\n"

  read acp

	[[ -n "$acp" ]] || return 1
  [[ -e $DRY ]] && echo "now we commit with message " && exit 0
	git acp "$acp" 
}

echo <<EOF 
        url: $FG[red] $ROOT     				  $FX[none]
git root is: $FG[red] $GITROOT   					$FX[none]
 submodules: $FG[blue] $ALLMODS 					$FX[none]
  dirtymods: $FG[yellow] $(git dirtysubs) $FX[none]
EOF

read z

for x in $(git dirtysubs); { doACP "${GITROOT}/$x" }

doACP "$GITROOT"

#CMD='if git dirty; then echo "$(pwd) is dirty"; fi'

#git submodule --quiet foreach --recursive $CMD


#  if git dirty; then \
#    echo "$(pwd) is dirty"; \  # doACP "ACP message for $(basename $GITROOT) submodule $x?"
#  else \
#    echo "submodule $x IS NOT dirty!" \
#  fi

#done

#  cd "$GITROOT/$x"
#for x in $(git modules); do



#cd "$GITROOT"
#doACP "\n\n\n ACP for main Repo, at $GITROOT"