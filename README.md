# AI CLI Installer v3.1.1

A robust bash script that installs AI-powered developer tools with a single command. No configuration needed.

## Quick Start

```bash
curl -fsSL https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh | bash
```

> **Source**: View the installer script at [gist.github.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4](https://gist.github.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4)

## What You Get

| Tool | Package | Command | System Requirements | Description |
|------|---------|---------|---------------------|-------------|
| **Claude Code** | `@anthropic-ai/claude-code` | `claude` | Works everywhere | AI assistant that can understand codebases and run commands |
| **OpenAI Codex** | `@openai/codex` | `codex` | Ubuntu 24.04+ or GLIBC 2.39+ | Lightweight coding agent for your terminal |

## Features

✅ **Safe by Default** - User-local installation (`~/.npm-global`), no sudo needed  
✅ **macOS Compatible** - Works with the default Bash 3.2 on macOS  
✅ **Version Manager Friendly** - Works perfectly with mise, nvm, asdf  
✅ **Multi-Shell Support** - Auto-configures bash, zsh, and fish  
✅ **Idempotent** - Run it multiple times safely  
✅ **Smart Updates** - Updates existing installations automatically  

## System Requirements

- **Node.js** ≥ 18.x ([nodejs.org](https://nodejs.org))
- **npm** (comes with Node.js)
- **bash** ≥ 3.2 (works with macOS default bash)
- **Operating System**:
  - **Claude**: Any Linux/macOS with bash
  - **Codex**: Ubuntu 24.04+, Fedora 40+, or any system with GLIBC 2.39+

## Usage

```bash
ai_cli_installer [OPTIONS]

OPTIONS:
    -p, --packages LIST    Comma-separated list (claude, codex)
                          Default: both tools
    -g, --global          Install globally (requires sudo)
                          Default: user-local installation
    -d, --dry-run         Preview what will be installed
    -l, --list            List available packages
    -v, --version         Show installer version
    -h, --help            Show this help message
```

### Examples

```bash
# Install both tools (default, recommended)
curl -fsSL https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh | bash

# Install only Claude (for older systems)
curl -fsSL https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh | bash -s -- -p claude

# Install globally (not recommended)
curl -fsSL https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh | bash -s -- --global

# Preview installation
curl -fsSL https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh | bash -s -- --dry-run
```

## For DevContainers

```dockerfile
# For both tools (requires newer base image)
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh | bash

# For Debian 12 or older Ubuntu (Claude only)
FROM debian:12
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh | bash -s -- -p claude
```

## After Installation

The installer will tell you if you need to reload your shell:

```bash
source ~/.bashrc  # or ~/.zshrc for zsh users
```

Verify installation:
```bash
claude --version && codex --version && echo "✅ Both AI tools ready!"
```

## Troubleshooting

### GLIBC Version Error
If you see:
```
libc.so.6: version `GLIBC_2.39' not found
```

This means Codex requires a newer system. Options:
- Upgrade to Ubuntu 24.04+ or equivalent
- Use Claude only: `curl -fsSL https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh | bash -s -- -p claude`
- Check your GLIBC version: `ldd --version`

### Command Not Found
- Reload your shell: `source ~/.bashrc`
- Check PATH: `echo $PATH | grep npm-global`
- Verify installation location: `ls ~/.npm-global/bin/`

### Using Version Managers
The installer works seamlessly with mise, nvm, asdf, etc. It defaults to user-local installation to avoid conflicts.

## Manual Installation

To review the script before running:

```bash
# Download and inspect
curl -o ai_cli_installer.sh https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh
less ai_cli_installer.sh

# Run manually
chmod +x ai_cli_installer.sh
./ai_cli_installer.sh --help
```

## Uninstall

```bash
# Remove the tools
npm uninstall -g @anthropic-ai/claude-code @openai/codex

# Remove PATH entry from your shell RC file
# Edit ~/.bashrc, ~/.zshrc, or ~/.config/fish/config.fish
```

## Security Notes

- The script is ~250 lines of readable bash
- No external dependencies beyond Node.js/npm
- All operations are logged to stdout
- Use `--dry-run` to preview changes
- Defaults to user-local installation (no sudo)

## Learn More

- **Claude Code**: [github.com/anthropics/claude-code](https://github.com/anthropics/claude-code)
- **OpenAI Codex**: [github.com/openai/codex](https://github.com/openai/codex)

## License

MIT

---

*Created by [@usrbinkat](https://github.com/usrbinkat)*