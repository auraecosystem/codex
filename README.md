# AI CLI Installer v3.2.0

Bash script for installing AI-powered command-line development tools.

## Quick Start

```bash
curl -fsSL https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh | bash
```

Source: [gist.github.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4](https://gist.github.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4#file-ai-tools-sh)

## Available Tools

| Tool | Package | Command | Requirements | Key Features |
|------|---------|---------|--------------|--------------|
| **Claude Code** | `@anthropic-ai/claude-code` | `claude` | Node.js 18+<br>macOS 10.15+, Ubuntu 20.04+/Debian 10+, Windows via WSL | Terminal-based AI agent with codebase understanding, file operations, git integration |
| **OpenAI Codex** | `@openai/codex` | `codex` | Node.js 22+<br>Ubuntu 20.04+/Debian 10+, Windows via WSL2<br>GLIBC 2.39+ | Sandboxed code execution, interactive REPL, multi-provider support |
| **Gemini CLI** | `@google/gemini-cli` | `gemini` | Node.js 18+<br>macOS/Linux/WSL | 1M+ token context, multimodal input, Google Search grounding, MCP server support |

## Installation Features

- User-local installation to `~/.npm-global` directory
- Compatible with bash 3.2+ (including macOS default)
- Automatic PATH configuration for bash, zsh, and fish shells
- Idempotent execution
- Automatic updates for existing installations

## System Requirements

- Node.js 18+ (22+ for Codex)
- npm (included with Node.js)
- bash 3.2+
- Operating system compatibility varies by tool (see table above)

## Usage

```bash
ai_cli_installer [OPTIONS]

OPTIONS:
    -p, --packages LIST   Comma-separated list (eg: "claude,codex,gemini" )
                          Default: all three tools
    -g, --global          Install globally (requires sudo)
                          Default: user-local installation
    -d, --dry-run         Preview what will be installed
    -l, --list            List available packages
    -v, --version         Show installer version
    -h, --help            Show this help message
```

### Examples

Set the installer URL as an environment variable:

```bash
export AI_INSTALLER="https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh"
```

Installation commands:

```bash
# Install all three tools (default)
curl -fsSL $AI_INSTALLER | bash

# Install specific tools
curl -fsSL $AI_INSTALLER | bash -s -- -p claude
curl -fsSL $AI_INSTALLER | bash -s -- -p claude,gemini

# Global installation
curl -fsSL $AI_INSTALLER | bash -s -- --global

# Preview installation
curl -fsSL $AI_INSTALLER | bash -s -- --dry-run

# List available packages
curl -fsSL $AI_INSTALLER | bash -s -- --list

# Show version
curl -fsSL $AI_INSTALLER | bash -s -- --version

# Display help
curl -fsSL $AI_INSTALLER | bash -s -- --help
```

## Docker Installation

Standard installation:

```dockerfile
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh | bash
```

For older base images (Claude and Gemini only):

```dockerfile
FROM debian:12
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh | bash -s -- -p claude,gemini
```

Using Docker build arguments:

```dockerfile
ARG AI_INSTALLER=https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL ${AI_INSTALLER} | bash
```

## Post-Installation

Reload your shell configuration:

```bash
source ~/.bashrc  # or ~/.zshrc for zsh users
```

Verify installations:

```bash
claude --version
codex --version
gemini --version
```

## Tool Capabilities

### Claude Code
Claude Code embeds Claude Opus 4 directly in your terminal, achieving 72.5% on SWE-bench benchmarks. It maps and explains entire codebases in seconds using agentic search to understand project structure and dependencies without manual context selection. The tool supports extended thinking with tool use for up to 7 hours of autonomous code execution. Project-specific guidance through CLAUDE.md files enables customized workflows, while the /init command generates comprehensive project documentation. Git integration handles the entire workflow from reading issues to submitting pull requests, all from your terminal.

### OpenAI Codex
Platform-specific sandboxing uses Apple Seatbelt (sandbox-exec) on macOS for read-only jailing with writable roots limited to $PWD, $TMPDIR, and ~/.codex. Linux sandboxing leverages Docker containers with custom iptables/ipset firewalls that deny all egress except the OpenAI API. Multi-provider support includes OpenAI, Gemini, OpenRouter, Ollama, Azure, and any OpenAI-compatible API endpoint. AGENTS.md files provide layered project documentation that merges from ~/.codex/AGENTS.md, repository root, and current directory. The TypeScript implementation uses ink and React for interactive terminal UI, with Rust bindings for native performance.

### Gemini CLI
Gemini 1.5 models achieve near-perfect recall on long-context retrieval tasks across modalities, processing millions of tokens including multiple documents and hours of video/audio. Extended context windows handle 1M tokens for comprehensive codebase analysis, large datasets, or extensive documentation that exceeds other models' limits. Multimodal capabilities enable app generation from PDFs or sketches, combining visual understanding with code generation. MCP server implementations expose Gemini's capabilities as standard protocol tools, allowing integration with other AI systems and custom workflows. Built-in Google Search grounding provides real-time information retrieval for current APIs, documentation, and technical solutions.

## Troubleshooting

### GLIBC Version Error

For systems showing `libc.so.6: version 'GLIBC_2.39' not found`:

- Check your version: `ldd --version`
- Install Claude and Gemini only: `curl -fsSL $AI_INSTALLER | bash -s -- -p claude,gemini`
- Upgrade to Ubuntu 24.04+ or equivalent

### Command Not Found

After installation:

- Reload shell configuration: `source ~/.bashrc`
- Verify PATH: `echo $PATH | grep npm-global`
- Check installation: `ls ~/.npm-global/bin/`

## Manual Installation

```bash
# Set installer URL
export AI_INSTALLER="https://gist.githubusercontent.com/usrbinkat/e36f12cd0d8c0f98decc80b092c447f4/raw/ai-tools.sh"

# Download script
curl -o ai_cli_installer.sh $AI_INSTALLER

# Review contents
less ai_cli_installer.sh

# Execute
chmod +x ai_cli_installer.sh
./ai_cli_installer.sh --help
```

## Uninstallation

Remove packages:

```bash
npm uninstall -g @anthropic-ai/claude-code @openai/codex @google/gemini-cli
```

Remove PATH configuration from your shell RC file (`~/.bashrc`, `~/.zshrc`, or `~/.config/fish/config.fish`).

## Documentation

- **Claude Code**: [Documentation](https://docs.anthropic.com/en/docs/claude-code/overview) | [GitHub](https://github.com/anthropics/claude-code)
- **OpenAI Codex**: [GitHub](https://github.com/openai/codex)
- **Gemini CLI**: [GitHub](https://github.com/google-gemini/gemini-cli)

## Security

- No external dependencies beyond Node.js and npm
- User-local installation by default
- All operations logged to stdout
- Dry-run mode for installation preview

## License

MIT

---

*Created by [@usrbinkat](https://github.com/usrbinkat)*