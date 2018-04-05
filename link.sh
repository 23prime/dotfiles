#!/bin/bash -u

DOT_DIR="${HOME}/dotfiles"

echo "link home directory dotfiles"
cd ${DOT_DIR}
for f in .??*
do
    [ "$f" = ".git" ] && continue
    [ "$f" = ".gitignore" ] && continue
    ln -snfv ${DOT_DIR}/${f} ${HOME}/${f}
done

echo "link .config directory dotfiles"
cd ${DOT_DIR}
for file in `find . -maxdepth 1 -type f`; do
    ln -sf ${DOT_DIR}/${file} ${HOME}/${file}
done

echo "linked dotfiles complete!"
