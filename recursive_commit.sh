#!/bin/zsh

#  recursive_commit.sh
#  AtoZUniversal
#
#  Created by Alex Gray on 6/2/15.
#  Copyright (c) 2015 Alex Gray. All rights reserved.

set -e

GITROOT="$(git root)"

doACP() {

  set -x
#  echo "\n\nmoving to $1\n";
  cd "$1"
  git status; # git diff;
  read s
  git diff
  echo "\n\nACP message for $(basename $GITROOT) submodule $(git reponame)?" # ${1/$GITROOT/}?\n"

  read acp
  [[ -n "$acp" ]] && git acp "$acp"
}

echo "git root is:\n\n$GITROOT\n\ndirtymods are:\n\n$(git dirtysubs)."

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