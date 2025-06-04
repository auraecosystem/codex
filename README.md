# Claude Code Installation Script

A simple, idempotent bash script to install Node.js v23, Yarn, and Claude Code on Ubuntu/Debian systems.

## Quick Install

Using the shortened URL:
```bash
curl -fsSL https://bit.ly/install-claude-code-on-ubuntu | bash
```

Or using the direct GitHub Gist URL:
```bash
curl -fsSL https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/install-claude.sh | bash
```

## What Gets Installed

- **Node.js v23** - Latest version from NodeSource repository
- **npm** - Comes with Node.js
- **Yarn** - Installed globally via npm
- **Claude Code** - Anthropic's AI coding assistant CLI tool

## Features

✅ **Idempotent** - Safe to run multiple times without causing issues  
✅ **Smart Detection** - Skips already installed components  
✅ **User-friendly** - Color-coded output shows progress and status  
✅ **Non-root npm** - Configures npm to install global packages in your home directory  

## Prerequisites

- Ubuntu or Debian-based Linux distribution
- `sudo` access for system package installation
- `curl` installed (usually pre-installed)

## Manual Installation

If you prefer to review the script first:
```bash
# Download the script
curl -fsSL https://bit.ly/install-claude-code-on-ubuntu -o install-claude.sh

# Review the contents
cat install-claude.sh

# Make executable and run
chmod +x install-claude.sh
./install-claude.sh
```

## What the Script Does

1. Adds NodeSource repository for Node.js v23
2. Installs Node.js and npm from the official repository
3. Installs Yarn globally
4. Configures npm to install global packages in `~/.npm-global`
5. Updates your PATH in `~/.bashrc`
6. Installs Claude Code CLI tool
7. Checks for updates if tools are already installed

## After Installation

You may need to reload your shell configuration:
```bash
source ~/.bashrc
```

Then verify the installation:
```bash
node --version    # Should show v23.x.x
claude-code --version
```

## Troubleshooting

If `claude-code` command is not found after installation:
1. Run `source ~/.bashrc` or open a new terminal
2. Check that `~/.npm-global/bin` is in your PATH: `echo $PATH`
3. Manually add to PATH if needed: `export PATH=~/.npm-global/bin:$PATH`

## Source Code

View the full script in this gist or at the direct URL above.