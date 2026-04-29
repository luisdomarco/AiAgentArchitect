#!/usr/bin/env bash
#
# AiAgentArchitect Lite — Bootstrap installer
#
# Detects OS and package manager, ensures required dependencies are present
# (offering to install missing ones), then hands off to the interactive
# wizard at scripts/install.mjs.
#
# Usage:
#   bash install.sh [--yes] [--no-deps] [--help]
#
# Or via curl:
#   curl -fsSL https://raw.githubusercontent.com/USER/AiAgentArchitect-v3/main/install.sh | bash -s -- --yes
#
# Flags are forwarded to scripts/install.mjs after dependency bootstrap.

set -euo pipefail

# --- Argument parsing -------------------------------------------------------

YES=false
NO_DEPS=false
SHOW_HELP=false
WIZARD_PASSTHROUGH=()

for arg in "$@"; do
    case "$arg" in
        --yes|-y)
            YES=true
            WIZARD_PASSTHROUGH+=("--yes")
            ;;
        --no-deps)
            NO_DEPS=true
            ;;
        --help|-h)
            SHOW_HELP=true
            ;;
        *)
            WIZARD_PASSTHROUGH+=("$arg")
            ;;
    esac
done

if $SHOW_HELP; then
    cat <<'EOF'
AiAgentArchitect Lite — Bootstrap installer

Usage: bash install.sh [OPTIONS] [-- WIZARD_FLAGS]

Options handled by this script:
  --yes, -y       Accept all prompts automatically (for CI / unattended runs)
  --no-deps       Skip dependency bootstrap (assume deps are already present)
  --help, -h      Show this message

Any other flags are forwarded to scripts/install.mjs (the interactive wizard).
See "node scripts/install.mjs --help" for wizard-specific flags.

Examples:
  bash install.sh                          # interactive
  bash install.sh --yes                    # accept all prompts
  bash install.sh --no-deps                # skip dep bootstrap
  bash install.sh --layers=qa,memory       # forward to wizard
EOF
    exit 0
fi

# --- Color helpers ----------------------------------------------------------

if [ -t 1 ] && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
    BOLD=$(tput bold); RED=$(tput setaf 1); GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3); BLUE=$(tput setaf 4); DIM=$(tput dim); RESET=$(tput sgr0)
else
    BOLD=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; DIM=""; RESET=""
fi

info()  { printf "${BLUE}i${RESET}  %s\n" "$*"; }
ok()    { printf "${GREEN}+${RESET}  %s\n" "$*"; }
warn()  { printf "${YELLOW}!${RESET}  %s\n" "$*" >&2; }
err()   { printf "${RED}x${RESET}  %s\n" "$*" >&2; }
title() { printf "\n${BOLD}== %s ==${RESET}\n" "$*"; }

# --- Interactivity check ----------------------------------------------------

INTERACTIVE=true
if [ ! -t 0 ]; then
    INTERACTIVE=false
    if ! $YES && ! $NO_DEPS; then
        err "Non-interactive run detected (no TTY on stdin)."
        err "Either pass --yes or use --no-deps. Examples:"
        err "  curl ... | bash -s -- --yes"
        err "  curl ... | bash -s -- --no-deps"
        exit 1
    fi
fi

# Try to attach /dev/tty for prompts even when piped (curl | bash).
TTY_FD="/dev/tty"
if ! [ -r "$TTY_FD" ] || ! [ -w "$TTY_FD" ]; then
    TTY_FD=""
    if ! $YES && ! $NO_DEPS; then
        err "Cannot read from /dev/tty for interactive prompts. Re-run with --yes."
        exit 1
    fi
fi

# --- ask y/n/skip -----------------------------------------------------------

ask() {
    local prompt="$1"
    local default="${2:-Y}"
    if $YES; then
        printf "%s [auto-yes]\n" "$prompt"
        return 0
    fi
    local hint
    case "$default" in Y|y) hint="[Y/n/skip]" ;; N|n) hint="[y/N/skip]" ;; *) hint="[y/n/skip]" ;; esac
    while true; do
        local ans=""
        if [ -n "$TTY_FD" ]; then
            read -r -p "$prompt $hint: " ans <"$TTY_FD" || true
        else
            read -r -p "$prompt $hint: " ans || true
        fi
        ans="${ans:-$default}"
        case "$ans" in
            Y|y|yes)  return 0 ;;
            N|n|no)   return 1 ;;
            S|s|skip) return 2 ;;
            *) printf "Please answer y, n, or skip.\n" ;;
        esac
    done
}

# --- OS + package manager detection -----------------------------------------

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then echo "wsl"; else echo "linux"; fi
            ;;
        *) echo "unknown" ;;
    esac
}

detect_pkg_mgr() {
    if command -v brew    >/dev/null 2>&1; then echo "brew";   return; fi
    if command -v apt-get >/dev/null 2>&1; then echo "apt";    return; fi
    if command -v dnf     >/dev/null 2>&1; then echo "dnf";    return; fi
    if command -v pacman  >/dev/null 2>&1; then echo "pacman"; return; fi
    echo "none"
}

install_cmd_for() {
    local mgr="$1" pkg="$2"
    case "$mgr" in
        brew)   echo "brew install $pkg" ;;
        apt)    echo "sudo apt-get update && sudo apt-get install -y $pkg" ;;
        dnf)    echo "sudo dnf install -y $pkg" ;;
        pacman) echo "sudo pacman -Sy --noconfirm $pkg" ;;
        *)      echo "" ;;
    esac
}

# --- Version comparison -----------------------------------------------------

ver_ge() {
    [ "$(printf "%s\n%s\n" "$1" "$2" | sort -V | tail -n 1)" = "$1" ]
}

# --- Dependency checks ------------------------------------------------------

check_git()    { command -v git    >/dev/null 2>&1; }
check_fswatch() { command -v fswatch >/dev/null 2>&1; }
check_gh()     { command -v gh     >/dev/null 2>&1; }

check_node_v20() {
    command -v node >/dev/null 2>&1 || return 1
    local v
    v=$(node -v 2>/dev/null | sed 's/^v//')
    ver_ge "$v" "20.0.0"
}

check_python_310() {
    command -v python3 >/dev/null 2>&1 || return 1
    local v
    v=$(python3 -c "import sys; print('.'.join(map(str, sys.version_info[:3])))" 2>/dev/null) || return 1
    ver_ge "$v" "3.10.0"
}

# --- Generic dep installer --------------------------------------------------

ensure_dep() {
    local name="$1" check_func="$2" pkg_name="$3"
    local optional="${4:-false}"

    if "$check_func"; then
        ok "$name present"
        return 0
    fi

    warn "$name not found or below required version"
    local cmd_str
    cmd_str=$(install_cmd_for "$PKG_MGR" "$pkg_name")
    if [ -z "$cmd_str" ]; then
        err "No supported package manager detected. Install $name manually and re-run."
        $optional && return 0 || return 1
    fi

    info "Proposed install command: ${DIM}$cmd_str${RESET}"

    set +e
    ask "Install $name now?" "Y"
    local ans=$?
    set -e

    case $ans in
        0)
            eval "$cmd_str" || { err "Install failed for $name"; return 1; }
            if "$check_func"; then
                ok "$name installed"
                return 0
            fi
            err "$name still not satisfied after install"
            return 1
            ;;
        2)
            warn "Skipped $name. Install manually if you need it."
            $optional && return 0 || return 1
            ;;
        *)
            err "Aborted: $name is required"
            $optional && return 0 || return 1
            ;;
    esac
}

# --- Node.js install (special: nvm vs package manager) ----------------------

install_node() {
    if check_node_v20; then
        ok "Node.js $(node -v) present (>=20)"
        return 0
    fi

    title "Node.js >=20 is required for the interactive wizard"
    info "Two installation options:"
    info "  1) Per-user via ${BOLD}nvm${RESET} (recommended; isolated; no sudo)"
    info "  2) System-wide via ${BOLD}${PKG_MGR}${RESET} (requires sudo on Linux)"

    set +e
    ask "Use nvm (option 1)?" "Y"
    local ans=$?
    set -e

    case $ans in
        0)
            if [ ! -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]; then
                info "Installing nvm from official script (v0.39.7)..."
                curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
            fi
            export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
            # shellcheck source=/dev/null
            [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
            nvm install 20
            nvm use 20
            ;;
        1)
            local cmd_str
            cmd_str=$(install_cmd_for "$PKG_MGR" "node@20")
            [ -z "$cmd_str" ] && cmd_str=$(install_cmd_for "$PKG_MGR" "nodejs")
            info "Running: ${DIM}$cmd_str${RESET}"
            eval "$cmd_str"
            ;;
        *)
            err "Skipped Node.js install — interactive wizard cannot run."
            return 1
            ;;
    esac

    if check_node_v20; then
        ok "Node.js $(node -v) installed"
        return 0
    fi
    err "Node.js still not satisfied after install"
    return 1
}

# --- Fallback when Node is unavailable --------------------------------------

fallback_bash_install() {
    title "Bash fallback (no Node.js available)"
    warn "Cannot run the interactive wizard. Writing minimal config/manifest.yaml with safe defaults."

    local script_dir manifest now sha
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    manifest="$script_dir/config/manifest.yaml"
    now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    sha="unknown"
    if [ -d "$script_dir/.git" ] && command -v git >/dev/null 2>&1; then
        sha=$(cd "$script_dir" && git rev-parse HEAD 2>/dev/null || echo "unknown")
    fi

    mkdir -p "$script_dir/config"
    cat > "$manifest" <<EOF
# Generated by install.sh fallback (no Node.js available).
# Edit manually or re-run install.sh after installing Node.js to use the wizard.
aiagent_architect_version: 3.0.0-alpha
installed_at: $now
last_modified: $now
commit_sha: $sha
platforms:
  - antigravity
layers_root:
  qa:             { enabled: true, version: 1.0.0, embedded_at: $now }
  memory:         { enabled: true, version: 1.0.0, embedded_at: $now }
  context-ledger: { enabled: true, version: 1.0.0, embedded_at: $now }
layers_subsystem_defaults:
  qa:             { enabled: true }
  memory:         { enabled: true }
  context-ledger: { enabled: true }
EOF

    ok "Fallback manifest written to $manifest"
    info "To enable claude-code or codex platforms, install Node.js and re-run:"
    info "  bash install.sh"
}

# --- Main -------------------------------------------------------------------

main() {
    title "AiAgentArchitect Lite — Bootstrap"

    OS=$(detect_os)
    PKG_MGR=$(detect_pkg_mgr)
    info "OS: $OS"
    info "Package manager: $PKG_MGR"

    if $NO_DEPS; then
        warn "--no-deps: skipping dependency checks"
    else
        title "Step 1/2 — Checking dependencies"

        ensure_dep "Git"          check_git         "git"      "false" || exit 1

        local node_ok=true
        install_node || node_ok=false

        ensure_dep "Python 3.10+" check_python_310  "python3"  "true"  || true
        ensure_dep "fswatch"      check_fswatch     "fswatch"  "true"  || true
        ensure_dep "GitHub CLI"   check_gh          "gh"       "true"  || true

        if ! $node_ok; then
            fallback_bash_install
            exit 0
        fi
    fi

    title "Step 2/2 — Launching interactive wizard"
    local script_dir installer
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    installer="$script_dir/scripts/install.mjs"
    if [ ! -f "$installer" ]; then
        err "Wizard not found at $installer"
        err "Make sure you cloned the full repository and didn't only download install.sh."
        exit 1
    fi

    info "Running: node $installer ${WIZARD_PASSTHROUGH[*]:-}"
    if [ ${#WIZARD_PASSTHROUGH[@]} -eq 0 ]; then
        exec node "$installer"
    else
        exec node "$installer" "${WIZARD_PASSTHROUGH[@]}"
    fi
}

main "$@"
