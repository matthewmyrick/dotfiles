# ============================================================================
# OPTIMIZED ZSH CONFIGURATION
# ============================================================================
# This configuration uses lazy loading and modular organization for fast startup
# Most functions are loaded only when first used to minimize shell startup time

# --- EARLY RETURN FOR NON-INTERACTIVE SHELLS ---
# Removed to ensure functions load properly
# [[ $- != *i* ]] && return

# --- PERFORMANCE PROFILING (Optional) ---
# Uncomment the following line to profile shell startup time
zmodload zsh/zprof

# --- ASCII LOGO ---
# Display ASCII art on terminal startup
cat << 'EOF'
⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⣿⣿⣶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠙⢿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠈⠻⠿⠿⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⠛⠿⣷⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⢿⣷⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⣿⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⢶⡖⢲⡶⢦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⢠⡞⠉⠀⣸⠁⠀⣿⠀⠈⢳⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣷⣄⡀⠀⠀⠀⢀⡟⠀⠀⠀⡿⠀⠀⢸⡀⠀⠀⢻⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠻⢿⣦⣄⣀⣸⠁⠀⢀⣠⡧⠀⠀⢸⣇⣀⡀⢸⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⡀⠈⢻⣍⠁⠀⠀⠀⢉⣽⠋⢸⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣽⡇⣀⣀⣟⡷⣄⣀⣴⣟⣡⣴⣿⣻⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣷⠘⠻⣿⡿⠿⠻⢿⣿⣿⣹⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣆⠀⠈⠀⣀⢀⡈⠀⢀⣾⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠏⠀⠙⢷⣄⠀⠉⠉⢁⣠⣾⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⡿⢷⣤⡀⠀⠀⠀⠀⠀⠀⢀⣴⠋⠁⠀⠀⠀⠀⠛⢿⡶⡶⢿⣿⣿⣿⣿⡏⠉⢹⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣷⣆⢿⢻⣦⠀⠀⠀⠀⠀⣾⠁⠀⠀⠀⠀⠀⢀⣠⡴⠛⢠⣾⣿⣿⣿⢻⣧⣴⣿⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣯⡆⠈⠻⣷⣄⠀⠀⠀⣿⠀⢠⡄⠀⢀⣴⠟⠁⠀⣠⣿⣿⣿⣿⣿⡟⠀⠉⠉⠙⠿⣿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣰⣿⣷⣠⠀⠀⢸⠈⢻⣷⣄⠀⣿⣴⠟⠀⢀⡿⠁⠀⣠⣾⣿⣿⣳⣿⣿⡿⠀⠀⢀⡀⠀⠀⠈⠛⢿⣷⣶⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⣛⣷⣦⡄⢶⣾⣿⣿⣿⠏⠉⠀⠀⢸⣅⣤⠾⠋⣠⣿⣽⣿⣿⣿⣀⣤⣾⡟⠛⠳⢦⣤⣀⠀⠹⣿⣿⣿⣿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⡶⠿⢿⣿⣿⣿⣿⣶⣼⣿⣿⡟⠀⠀⠀⠀⣿⣽⠆⢀⣴⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⢾⣿⣇⠀⠀⠙⠿⣿⣿⣿⣷⣦⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⣿⡅⠀⠘⣻⢁⣈⣥⡿⠿⠿⠿⣿⡇⠀⠀⠀⢠⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣟⣿⣿⣿⣿⡇⠀⠰⣿⣿⣿⣦⠀⠀⠀⠈⠛⢿⣿⣿⣿⣷⣤⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⡷⠀⣰⣿⡿⠟⠁⠀⠀⣠⣾⣿⠃⠀⠀⣣⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⢟⣿⣿⣿⡟⣿⡇⠀⠀⠘⣿⣿⣿⣧⠀⠀⠀⠀⠀⠉⠻⢿⣿⣿⣿⣶⣄⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣸⣿⣷⡾⠿⠋⠀⠀⢀⣠⣾⣿⣾⢏⠀⠀⠰⣿⡅⢀⣩⣿⠟⢛⣿⣿⣿⣿⣿⣿⣿⠟⠀⣿⣿⡆⠀⠀⠹⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣿⣿⣷⡄
⠀⠀⠀⠀⠀⠀⠀⡿⠛⠉⠀⠀⢀⣤⣶⣟⣋⠉⠀⡿⢸⡄⠀⠀⣿⣿⠛⠉⢀⣠⣿⣿⣿⣿⣿⣿⣿⣅⠀⠀⣿⢻⡇⠀⠀⠀⢿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠁
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⠿⢿⣿⣿⣸⡇⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠉⠀⠀⣿⣸⣿⠀⢰⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⠿⠉⠀⠘⢻⣿⢻⣿⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⣷⣄⠀⣿⣿⣷⣼⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⡟⠀⠀⠀⢀⣿⡟⢸⡿⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠉⠉⠁⠀⠀⢙⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⣸⣿⠶⣾⡇⣼⠟⠁⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣇⣤⠰⣾⣿⣯⡴⢃⣷⠿⣧⠀⢿⣿⣿⣿⣿⣿⣿⡟⠀⢀⣀⠀⠀⢹⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣙⣿⡿⠾⣿⠇⠉⣶⡞⠁⠀⠘⢧⡀⠙⢿⣿⣿⣿⡿⠀⠀⠀⠈⠙⠀⢸⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣡⣾⡿⢀⣠⠞⢻⣤⠉⢡⣤⡹⣦⡈⠈⠻⠟⠙⠛⠓⠦⠤⠄⠀⣸⣿⠛⣛⡛⠻⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠿⣿⡏⣠⣿⡏⣠⠏⠉⢷⡈⣟⠛⠾⠿⠇⠀⠀⠀⠀⠀⠀⠐⠷⠶⠟⠛⠛⠛⠛⠻⠟⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡛⠛⢻⡿⡾⠋⠀⠀⠈⠷⣿⡤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF

# --- ZSH CORE CONFIGURATION ---
autoload -Uz compinit
compinit -C  # -C flag skips security check for faster startup
zstyle ':completion:*' rehash true
setopt prompt_subst

# --- TERMINAL CONFIGURATION ---
# Set terminal type to xterm-256color for better color support
export TERM=xterm-256color

# --- HOMEBREW CONFIGURATION ---
# Detect Homebrew prefix (Intel -> /usr/local, Apple Silicon -> /opt/homebrew)
: ${HOMEBREW_PREFIX:=/opt/homebrew}
[[ -x /usr/local/bin/brew ]] && HOMEBREW_PREFIX=/usr/local

# --- ZSH PLUGINS (Minimal, Fast Loading) ---
# zsh-autosuggestions (load before syntax-highlighting)
if [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# fzf keybindings (lightweight, no subshells)
if [ -f "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]; then
  source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
fi

# zsh-syntax-highlighting MUST be loaded last among plugins
if [ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# --- PATH CONFIGURATION ---
# Add paths only if they exist and aren't already in PATH
_add_to_path_if_exists() {
    local dir="$1"
    if [[ -d "$dir" ]] && [[ ":$PATH:" != *":$dir:"* ]]; then
        export PATH="$PATH:$dir"
    fi
}

# Go binaries
if command -v go &>/dev/null; then
    _add_to_path_if_exists "$(go env GOPATH)/bin"
fi

# --- Lazy nvm loader ---
export NVM_DIR="$HOME/.nvm"

# Load nvm only when actually needed
nvm()  { unset -f nvm;  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; nvm "$@"; }

# Auto-use .nvmrc only when you run node/npm/npx (not on shell start)
__nvm_auto_use() {
  typeset -f nvm >/dev/null || { unset -f nvm node npm npx claude; . "$NVM_DIR/nvm.sh"; }
  if [ -f .nvmrc ]; then nvm use --silent >/dev/null 2>&1 || true; fi
}
node() { __nvm_auto_use; command node "$@"; }
npm()  { __nvm_auto_use; command npm  "$@"; }
npx()  { __nvm_auto_use; command npx  "$@"; }
claude() { 
  typeset -f nvm >/dev/null || { [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; }
  if [ -f .nvmrc ]; then nvm use --silent >/dev/null 2>&1 || true; fi
  local node_version=$(nvm current)
  "$NVM_DIR/versions/node/$node_version/bin/claude" "$@"
}
_add_to_path_if_exists "$(brew --prefix 2>/dev/null)/bin"

# Rancher Desktop (if installed)
_add_to_path_if_exists "$HOME/.rd/bin"

# --- ALIASES ---
# Load aliases from separate file
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# --- MODULAR SHELL FUNCTIONS ---
# Load the shell module system with lazy loading
# Functions are only loaded when first called, optimizing startup time
source "$HOME/GitHub/matthewmyrick/dotfiles/scripts/shell/loader.sh"

# --- OPTIMIZATION TIPS ---
# 
# The shell configuration has been optimized for fast startup:
# 
# 1. LAZY LOADING: Most functions are loaded only when first used
#    - Type a command like 'ff' or 'ghc' and it loads automatically
#    - Use 'shell_modules' to see all available modules
#    - Use 'shell_load <module>' to force load a module
#    - Use 'shell_loaded' to see what's currently loaded
# 
# 2. CONDITIONAL LOADING: Terminal-specific features load only when needed
#    - Warp terminal features only load in Warp
#    - Git functions for prompt are lightweight and always loaded
# 
# 3. STARTUP PROFILING: Enable profiling to measure startup time
#    - Uncomment 'zmodload zsh/zprof' at the top
#    - Run 'zprof' after shell starts to see timing breakdown
#    - Or use 'zprofile_on' and 'zprofile_off' for formatted output
# 
# 4. MODULE ORGANIZATION:
#    - profiling/  : Performance monitoring tools
#    - git/        : Git utilities and GitHub integration
#    - navigation/ : File/directory finders (ff, ffn, fch)
#    - utilities/  : General utilities (k_port, brewf, etc.)
#    - network/    : API and network tools
#    - prompt/     : Custom prompt configuration
# 
# 5. MANUAL OVERRIDES:
#    - To disable lazy loading for specific functions, edit loader.sh
#    - To enable curl JSON detection globally, uncomment the alias in loader.sh
#    - To disable telemetry for Python, don't use the python_telemetry alias

# --- SAFETY: Ensure shell modules are loaded ---
# This ensures functions are available even if there was an error above
if ! type shell_loaded &>/dev/null; then
    source "$HOME/GitHub/matthewmyrick/dotfiles/scripts/shell/loader.sh"
fi

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# --- END OF CONFIGURATION ---
# Profile results (if enabled)
zprof
