#!/usr/bin/env bash
# ai_cli_installer - Installer for AI CLI tools
# Version: 2.2.0

set -euo pipefail

###############################################################################
## Constants
###############################################################################
readonly SCRIPT_VERSION="2.2.0"
readonly SCRIPT_NAME="$(basename "$0")"

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Package definitions
declare -A PACKAGES=(
    ["claude-code"]="@anthropic-ai/claude-code"
    ["codex"]="@openai/codex"
)

###############################################################################
## Output Functions
###############################################################################
info()    { printf "${BLUE}[INFO]${NC} %s\n" "$*"; }
warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$*" >&2; }
error()   { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; }
success() { printf "${GREEN}[✓]${NC} %s\n" "$*"; }

###############################################################################
## Help & Version
###############################################################################
show_version() {
    echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
}

show_help() {
    cat <<EOF
${SCRIPT_NAME} - Install AI CLI tools

USAGE:
    ${SCRIPT_NAME} [OPTIONS]

OPTIONS:
    -p, --packages LIST    Comma-separated list of packages to install
                          Available: ${!PACKAGES[@]}
                          Default: all available packages
    -u, --user            Force user-local installation
    -d, --dry-run         Show what would be done without making changes
    -l, --list            List available packages
    -v, --version         Show version information
    -h, --help            Show this help message

EXAMPLES:
    ${SCRIPT_NAME}                    # Install all available tools
    ${SCRIPT_NAME} -p claude-code     # Install only Claude Code
    ${SCRIPT_NAME} --dry-run          # Preview changes

EOF
}

###############################################################################
## Utility Functions
###############################################################################
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

detect_shell() {
    basename "$SHELL"
}

get_shell_rc() {
    local shell_name="$1"
    case "$shell_name" in
        bash) echo "${HOME}/.bashrc" ;;
        zsh)  echo "${HOME}/.zshrc" ;;
        fish) echo "${HOME}/.config/fish/config.fish" ;;
        *)    echo "" ;;
    esac
}

add_to_path() {
    local npm_bin="$1"
    local shell_name=$(detect_shell)
    local rc_file=$(get_shell_rc "$shell_name")
    
    if [[ -z "$rc_file" ]]; then
        warn "Unsupported shell: $shell_name. Please add $npm_bin to PATH manually."
        return 1
    fi
    
    local export_line
    case "$shell_name" in
        fish) 
            # Use fish_user_paths for proper persistence
            export_line="set -U fish_user_paths $npm_bin \$fish_user_paths" 
            ;;
        *)    
            export_line="export PATH=\"$npm_bin:\$PATH\"" 
            ;;
    esac
    
    # Check if PATH entry already exists
    if [[ -f "$rc_file" ]] && grep -qF "$npm_bin" "$rc_file" 2>/dev/null; then
        info "PATH already configured in $rc_file"
    else
        echo "" >> "$rc_file"
        echo "# Added by ${SCRIPT_NAME} on $(date)" >> "$rc_file"
        echo "$export_line" >> "$rc_file"
        info "Added $npm_bin to PATH in $rc_file"
    fi
    
    # Export for current session (with duplication guard)
    if [[ ":$PATH:" != *":$npm_bin:"* ]]; then
        export PATH="$npm_bin:$PATH"
    fi
}

check_node_version() {
    if ! command_exists node; then
        error "Node.js is not installed. Please install Node.js 18 or higher."
        return 1
    fi
    
    # Try node -p first, fallback to version string parsing
    local major_version=$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null \
                          || node --version | sed 's/v//' | cut -d. -f1)
    
    if [[ "$major_version" -lt 18 ]]; then
        error "Node.js 18 or higher required. Found: v$(node --version | sed 's/v//')"
        return 1
    fi
    
    info "Node.js version: $(node --version)"
    return 0
}

###############################################################################
## Main Installation Logic
###############################################################################
setup_npm_prefix() {
    local force_user="$1"
    local install_global=true
    local npm_cmd="npm"
    local npm_prefix=""
    
    if [[ "$force_user" == "true" ]]; then
        install_global=false
    elif [[ $EUID -eq 0 ]]; then
        npm_cmd="npm"
    elif command_exists sudo && sudo -n true 2>/dev/null; then
        npm_cmd="sudo npm"
    else
        warn "No root access available. Using user-local installation."
        install_global=false
    fi
    
    if [[ "$install_global" == "false" ]]; then
        npm_prefix="${HOME}/.npm-global"
        mkdir -p "${npm_prefix}/lib" "${npm_prefix}/bin"
        npm config --global set prefix "${npm_prefix}"
        add_to_path "${npm_prefix}/bin"
        info "Configured npm for user-local installation"
    fi
    
    # Return command and prefix
    echo "${npm_cmd}|${npm_prefix}"
}

install_package() {
    local package_key="$1"
    local npm_package="$2"
    local npm_cmd="$3"
    local dry_run="$4"
    
    if [[ "$dry_run" == "true" ]]; then
        info "[DRY RUN] Would install: $npm_package"
        return 0
    fi
    
    if command_exists "$package_key"; then
        info "Updating $package_key..."
        $npm_cmd update -g "$npm_package"
    else
        info "Installing $package_key..."
        $npm_cmd install -g "$npm_package"
    fi
    
    if command_exists "$package_key"; then
        success "$package_key installed successfully"
    else
        error "Failed to install $package_key"
        return 1
    fi
}

###############################################################################
## Main Function
###############################################################################
main() {
    local packages_to_install=""
    local force_user=false
    local dry_run=false
    local list_packages=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--packages)
                [[ -z "${2:-}" ]] && { error "--packages requires an argument"; exit 1; }
                packages_to_install="$2"
                shift 2
                ;;
            -u|--user)
                force_user=true
                shift
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -l|--list)
                list_packages=true
                shift
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # List packages if requested
    if [[ "$list_packages" == "true" ]]; then
        echo "Available packages:"
        for pkg in "${!PACKAGES[@]}"; do
            echo "  - $pkg (${PACKAGES[$pkg]})"
        done
        exit 0
    fi
    
    # Check prerequisites
    check_node_version || exit 1
    
    if ! command_exists npm; then
        error "npm is not installed"
        exit 1
    fi
    info "npm version: $(npm --version)"
    
    # Setup npm prefix
    IFS='|' read -r npm_cmd npm_prefix <<< "$(setup_npm_prefix "$force_user")"
    
    # Determine packages to install
    if [[ -z "$packages_to_install" ]]; then
        packages_to_install=$(IFS=,; echo "${!PACKAGES[*]}")
    fi
    
    # Install packages
    IFS=',' read -ra requested_packages <<< "$packages_to_install"
    local failed=0
    
    for pkg in "${requested_packages[@]}"; do
        pkg=$(echo "$pkg" | tr -d ' ')  # Trim whitespace
        
        if [[ -z "${PACKAGES[$pkg]:-}" ]]; then
            warn "Unknown package: $pkg"
            continue
        fi
        
        if ! install_package "$pkg" "${PACKAGES[$pkg]}" "$npm_cmd" "$dry_run"; then
            ((failed++))
        fi
    done
    
    # Summary
    echo
    if [[ $failed -eq 0 ]]; then
        success "All installations completed successfully!"
        
        # Check if PATH needs to be reloaded
        if [[ -n "$npm_prefix" ]]; then
            local shell_name=$(detect_shell)
            local rc_file=$(get_shell_rc "$shell_name")
            if [[ -n "$rc_file" ]]; then
                warn "Restart your shell or run: source $rc_file"
            fi
        fi
    else
        error "$failed package(s) failed to install."
        exit 1
    fi
}

# Run main function
main "$@"