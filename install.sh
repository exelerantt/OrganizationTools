#!/bin/bash

# 1. Create a hidden folder to hold all your tools files
echo "Creating installation directory..."
INSTALL_DIR="$HOME/.gh-org-tools"
mkdir -p "$INSTALL_DIR"

# 2. List out all your new files so the script can download them one by one
FILES=(
    "customterminal.bash"
    "githubtools.bash"
    "misctools.bash"
    "organizationfunctions.bash"
)

# 3. Download each file into the hidden folder
# REMEMBER: Change 'YOUR_USERNAME' and 'YOUR_REPO' to your actual GitHub info!
echo "Downloading your separate tool files..."
for file in "${FILES[@]}"; do
    echo "  -> Downloading $file..."
    curl -sL "https://githubusercontent.com" -o "$INSTALL_DIR/$file"
done

# 4. Tell your terminal to load EVERY file inside that hidden folder
BASH_RC="$HOME/.bashrc"

# This line tells bash to run through the folder and load any file ending in .bash
LOAD_CMD="for f in \$HOME/.gh-org-tools/*.bash; do [ -f \"\$f\" ] && source \"\$f\"; done"

if ! grep -Fq "$LOAD_CMD" "$BASH_RC"; then
    echo "Adding tools to your terminal profile..."
    echo "" >> "$BASH_RC"
    echo "# Load All GitHub Organization Tools" >> "$BASH_RC"
    echo "$LOAD_CMD" >> "$BASH_RC"
    echo "Done! Restart your terminal or run 'source ~/.bashrc' to start using it."
else
    echo "Tools are already installed and updated!"
fi
