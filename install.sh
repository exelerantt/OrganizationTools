#!/bin/bash

# 1. Create a hidden folder to hold all your tools files
echo "Creating installation directory..."
INSTALL_DIR="$HOME/.gh-org-tools"
mkdir -p "$INSTALL_DIR"

# 2. List out all your separate files
FILES=(
    "customterminal.bash"
    "githubtools.bash"
    "misctools.bash"
    "organizationfunctions.bash"
)

# 3. Download each file into the hidden folder from your repo
echo "Downloading your separate tool files..."
for file in "${FILES[@]}"; do
    echo "  -> Downloading $file..."
    curl -sL "https://githubusercontent.com" -o "$INSTALL_DIR/$file"
done

# 4. Figure out if the user is running Bash or Zsh
if [ -n "$ZSH_VERSION" ]; then
    RC_FILE="$HOME/.zshrc"
    echo "Detected Zsh terminal."
elif [ -n "$BASH_VERSION" ]; then
    RC_FILE="$HOME/.bashrc"
    echo "Detected Bash terminal."
else
    # Fallback to checking the current shell name if the script runs as an executable
    CURRENT_SHELL=$(basename "$SHELL")
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        RC_FILE="$HOME/.zshrc"
        echo "Detected Zsh terminal."
    else
        RC_FILE="$HOME/.bashrc"
        echo "Defaulting to Bash terminal."
    fi
fi

# 5. This line tells the terminal to load every file ending in .bash
LOAD_CMD="for f in \$HOME/.gh-org-tools/*.bash; do [ -f \"\$f\" ] && source \"\$f\"; done"

if [ -f "$RC_FILE" ] && grep -Fq "$LOAD_CMD" "$RC_FILE"; then
    echo "Tools are already installed and updated!"
else
    echo "Adding tools to your terminal profile ($RC_FILE)..."
    echo "" >> "$RC_FILE"
    echo "# Load All GitHub Organization Tools" >> "$RC_FILE"
    echo "$LOAD_CMD" >> "$RC_FILE"
    echo "Done! Restart your terminal or run 'source $RC_FILE' to start using your tools."
fi
