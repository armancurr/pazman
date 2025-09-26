#!/bin/bash

set -e

DOMAIN="https://pazman.vercel.app"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Installing Pazman...${NC}"

SHELL_CONFIG=""
if [[ -n "$ZSH_VERSION" ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
    echo -e "${YELLOW}Detected Zsh, will update .zshrc${NC}"
elif [[ -n "$BASH_VERSION" ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
    echo -e "${YELLOW}Detected Bash, will update .bashrc${NC}"
else
    echo -e "${RED}Error: Unsupported shell (only Bash/Zsh supported).${NC}"
    exit 1
fi

if [[ "$HOME" == "/c/Users/"* || "$HOME" == "/home/"* ]]; then
    BIN_DIR="$HOME/bin"
else
    BIN_DIR="$HOME/.local/bin"
    if [[ ! -d "$BIN_DIR" ]]; then
        BIN_DIR="$HOME/bin"
    fi
fi

mkdir -p "$BIN_DIR"
echo -e "${GREEN}Created/verified bin directory: $BIN_DIR${NC}"

PAZMAN_URL="$DOMAIN/pazman"
curl -fsSL "$PAZMAN_URL" -o "$BIN_DIR/pazman"

if [[ ! -f "$BIN_DIR/pazman" ]]; then
    echo -e "${RED}Error: Failed to download pazman script from $PAZMAN_URL.${NC}"
    exit 1
fi

chmod +x "$BIN_DIR/pazman"
echo -e "${GREEN}Downloaded and made executable: $BIN_DIR/pazman${NC}"

if ! grep -q "$BIN_DIR" "$SHELL_CONFIG" 2>/dev/null; then
    echo "" >> "$SHELL_CONFIG"
    echo "# Pazman - added by installer" >> "$SHELL_CONFIG"
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$SHELL_CONFIG"
    fi
    echo "alias pm=\"pazman\"" >> "$SHELL_CONFIG"
    echo -e "${GREEN}Added PATH and alias to $SHELL_CONFIG${NC}"
else
    echo -e "${YELLOW}PATH entry already exists in $SHELL_CONFIG${NC}"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo ""
echo "To use Pazman:"
echo "- Restart your terminal or run: source $SHELL_CONFIG"
echo "- Test with: pazman help"

if [[ $- == *i* ]]; then
    source "$SHELL_CONFIG" 2>/dev/null || true
    echo -e "${GREEN}Reloaded your shell config.${NC}"
fi