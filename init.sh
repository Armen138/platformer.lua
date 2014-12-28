#!/usr/bin/env bash
VERSION="$(git describe)";
echo "return \"$VERSION\"" > version.lua
