#!/usr/bin/env bash
VERSION="$(git describe)";
FILES="main.lua version.lua ui/ map/ chars/ src/ fizzx/"
echo "return \"$VERSION\"" > version.lua
zip -r platformer.love $FILES
