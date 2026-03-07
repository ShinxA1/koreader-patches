#!/bin/bash

# Define target paths
TARGET_DIR="$HOME/.config/koreader/patches"
ICONS_TARGET="$HOME/.config/koreader/icons"

# Ensure the directories exist
mkdir -p "$TARGET_DIR"
mkdir -p "$ICONS_TARGET"

# Enable nullglob so the array is empty if no matching files exist
shopt -s nullglob
LUA_FILES=(*.lua)

# Check if there are any .lua files in the current directory
if [ ${#LUA_FILES[@]} -eq 0 ]; then
    echo "❌ Error: No .lua files found in the current directory."
    exit 1
fi

# Copy all .lua files over (overwriting the old ones)
cp "${LUA_FILES[@]}" "$TARGET_DIR/"

echo "✅ Successfully pushed ${#LUA_FILES[@]} .lua file(s) to local KOReader patches!"

# Optional: List out what was copied for a nice visual confirmation
for file in "${LUA_FILES[@]}"; do
    echo "  - $file"
done

# Copy icons if the icons directory exists
if [ -d "icons" ]; then
    SVG_FILES=(icons/*.svg)
    if [ ${#SVG_FILES[@]} -gt 0 ]; then
        cp "${SVG_FILES[@]}" "$ICONS_TARGET/"
        echo "✅ Copied ${#SVG_FILES[@]} icon(s) to KOReader icons!"
    fi
fi

pkill -f koreader
koreader
