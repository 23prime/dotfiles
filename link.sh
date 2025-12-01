#!/bin/bash
set -euo pipefail

# ========================================
# Dotfiles Symlink Manager
# ========================================

# Configuration
DOT_DIR="${DOT_DIR:-${HOME}/dotfiles}"
DRY_RUN="${DRY_RUN:-false}"
VERBOSE="${VERBOSE:-true}"

# Files and directories to exclude from linking
EXCLUDE_LIST=(
    ".git"
    ".gitignore"
    "README.md"
    "link.sh"
)

# Colors for output
if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    GREEN=''
    YELLOW=''
    RED=''
    BLUE=''
    NC=''
fi

# ========================================
# Functions
# ========================================

log_info() {
    if [[ "${VERBOSE}" == "true" ]]; then
        echo -e "${BLUE}[INFO]${NC} $*"
    fi
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_skip() {
    if [[ "${VERBOSE}" == "true" ]]; then
        echo -e "${YELLOW}[SKIP]${NC} $*"
    fi
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

is_excluded() {
    local item="$1"
    local basename_item
    basename_item=$(basename "$item")

    for exclude in "${EXCLUDE_LIST[@]}"; do
        if [[ "$basename_item" == "$exclude" ]]; then
            return 0
        fi
    done
    return 1
}

create_symlink() {
    local source="$1"
    local target="$2"

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "Would link: $source -> $target"
        return 0
    fi

    # Create parent directory if it doesn't exist
    local target_dir
    target_dir=$(dirname "$target")
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
        log_info "Created directory: $target_dir"
    fi

    # Create symlink
    if ln -snf "$source" "$target"; then
        log_success "Linked: $target -> $source"
        return 0
    else
        log_error "Failed to link: $source -> $target"
        return 1
    fi
}

link_dotfiles() {
    log_info "Linking dotfiles from $DOT_DIR to $HOME"

    local count=0
    local skipped=0
    local failed=0

    # Link dotfiles (files starting with .)
    for item in "$DOT_DIR"/.??*; do
        # Skip if item doesn't exist (e.g., no dotfiles found)
        [[ -e "$item" ]] || continue

        if is_excluded "$item"; then
            log_skip "Excluded: $(basename "$item")"
            ((skipped++))
            continue
        fi

        local basename_item
        basename_item=$(basename "$item")
        local target="${HOME}/${basename_item}"

        if create_symlink "$item" "$target"; then
            ((count++))
        else
            ((failed++))
        fi
    done

    # Link .config directory contents if it exists
    if [[ -d "$DOT_DIR/.config" ]]; then
        log_info "Linking .config directory contents"

        for item in "$DOT_DIR/.config"/*; do
            [[ -e "$item" ]] || continue

            local basename_item
            basename_item=$(basename "$item")
            local target="${HOME}/.config/${basename_item}"

            if create_symlink "$item" "$target"; then
                ((count++))
            else
                ((failed++))
            fi
        done
    fi

    # Summary
    echo ""
    echo "========================================"
    if [[ "${DRY_RUN}" == "true" ]]; then
        echo -e "${YELLOW}DRY RUN MODE - No changes made${NC}"
    fi
    echo "Total processed: $((count + skipped + failed))"
    echo "  - Linked: $count"
    echo "  - Skipped: $skipped"
    echo "  - Failed: $failed"
    echo "========================================"

    if [[ $failed -gt 0 ]]; then
        return 1
    fi
    return 0
}

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Link dotfiles from $DOT_DIR to home directory.

OPTIONS:
    -d, --dry-run       Show what would be done without making changes
    -q, --quiet         Suppress verbose output
    -h, --help          Show this help message

ENVIRONMENT VARIABLES:
    DOT_DIR            Source directory for dotfiles (default: \$HOME/dotfiles)
    DRY_RUN            Set to 'true' for dry-run mode (default: false)
    VERBOSE            Set to 'false' for quiet mode (default: true)

EXAMPLES:
    # Normal run
    $0

    # Dry run to see what would be linked
    $0 --dry-run

    # Use custom dotfiles directory
    DOT_DIR=~/mydotfiles $0

EOF
}

# ========================================
# Main
# ========================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dry-run)
                DRY_RUN="true"
                shift
                ;;
            -q|--quiet)
                VERBOSE="false"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Verify dotfiles directory exists
    if [[ ! -d "$DOT_DIR" ]]; then
        log_error "Dotfiles directory not found: $DOT_DIR"
        exit 1
    fi

    # Run linking
    if link_dotfiles; then
        log_success "Dotfiles linking completed successfully!"
        exit 0
    else
        log_error "Dotfiles linking completed with errors"
        exit 1
    fi
}

main "$@"
