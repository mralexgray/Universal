#!/bin/sh

#  recursive_commit.sh
#  AtoZUniversal
#
#  Created by Alex Gray on 6/2/15.
#  Copyright (c) 2015 Alex Gray. All rights reserved.

GITROOT="$(git root)"

for x in $(git modules); do

  cd "$GITROOT/$x"
  if git dirty; then
    git status
    echo "ACP message for $(basename $GITROOT) submodule $x?"
    read acp
    [[ -n "$acp" ]] && git acp "$acp"
  else
    echo "submodule $x IS NOT dirty!"
  fi
done