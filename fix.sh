#!/bin/sh
# fix.sh -- kills stuck git, pulls latest rabix_v9.sh, runs it
# Run this instead of rabix_v9.sh: sh fix.sh

# 1. Kill any stuck git processes
kill $(pgrep -f 'git') 2>/dev/null
sleep 1

# 2. Pull latest script from GitHub
cd "$HOME/rabix-toolkit" || { echo "ERROR: ~/rabix-toolkit not found"; exit 1; }
git pull -q 2>/dev/null || echo "Warning: git pull failed -- running local version"

# 3. Run the installer
sh rabix_v9.sh
