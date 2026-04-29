#!/bin/bash

echo "☸️  Installing Kubernetes CLI tools..."

# --- Prerequisite: Homebrew ------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  echo "❌ Homebrew not found. Install Homebrew first: ./install.sh --install brew"
  exit 1
fi

# --- kubectl --------------------------------------------------------------
if ! command -v kubectl >/dev/null 2>&1; then
  echo "📦 Installing kubectl..."
  brew install kubectl
else
  echo "✅ kubectl already installed ($(kubectl version --client --output=yaml 2>/dev/null | grep gitVersion | head -1 | awk '{print $2}'))"
fi

# --- kubecolor (color-coded kubectl wrapper) ------------------------------
if ! command -v kubecolor >/dev/null 2>&1; then
  echo "📦 Installing kubecolor..."
  brew install kubecolor
else
  echo "✅ kubecolor already installed"
fi

# --- kubectx + kubens (cluster/namespace switchers) -----------------------
if ! command -v kubectx >/dev/null 2>&1; then
  echo "📦 Installing kubectx (kubectx + kubens)..."
  brew install kubectx
else
  echo "✅ kubectx/kubens already installed"
fi

# --- stern (multi-pod log tailing) ----------------------------------------
if ! command -v stern >/dev/null 2>&1; then
  echo "📦 Installing stern..."
  brew install stern
else
  echo "✅ stern already installed"
fi

# --- k9s (terminal UI for k8s) --------------------------------------------
if ! command -v k9s >/dev/null 2>&1; then
  echo "📦 Installing k9s..."
  brew install k9s
else
  echo "✅ k9s already installed"
fi

# --- Krew (kubectl plugin manager) ----------------------------------------
KREW_ROOT="${KREW_ROOT:-$HOME/.krew}"
if [ ! -x "$KREW_ROOT/bin/kubectl-krew" ]; then
  echo "📦 Installing krew (kubectl plugin manager)..."
  (
    set -e
    tmp_dir="$(mktemp -d)"
    cd "$tmp_dir"
    OS="$(uname | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
    KREW="krew-${OS}_${ARCH}"
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
    tar zxf "${KREW}.tar.gz"
    "./${KREW}" install krew
    rm -rf "$tmp_dir"
  ) || {
    echo "❌ Error installing krew"
    exit 1
  }
  echo "✅ krew installed to $KREW_ROOT"
else
  echo "✅ krew already installed at $KREW_ROOT"
  # Keep the krew index up to date when it's already there
  "$KREW_ROOT/bin/kubectl-krew" update >/dev/null 2>&1 || true
fi

# Ensure krew is on PATH for the rest of this script
export PATH="$KREW_ROOT/bin:$PATH"

# --- Krew plugins ---------------------------------------------------------
echo ""
echo "🔌 Installing krew plugins..."

KREW_PLUGINS=(
  ctx            # kubectx (also available as standalone)
  ns             # kubens (also available as standalone)
  neat           # strip noise from YAML output
  tree           # visual hierarchy of k8s resources
  access-matrix  # who-can-do-what RBAC table
)

for plugin in "${KREW_PLUGINS[@]}"; do
  if kubectl krew list 2>/dev/null | grep -q "^${plugin}$"; then
    echo "  🔌 ${plugin} already installed, checking for updates..."
    kubectl krew upgrade "$plugin" 2>/dev/null || echo "    ✓ ${plugin} is up to date"
  else
    echo "  🔌 Installing ${plugin}..."
    kubectl krew install "$plugin" || echo "    ⚠️  Failed to install ${plugin}"
  fi
done

echo ""
echo "🎉 Kubernetes tools installation completed!"
echo ""
echo "📋 Next Steps:"
echo "  1. Restart your shell or run: source ~/.zshrc"
echo "  2. (Optional) Set a default context:"
echo "       kubectl config get-contexts"
echo "       kubectl config use-context <context-name>"
echo "  3. Don't bind a default namespace yet — use 'kubens <ns>' or 'kubectl -n <ns>'"
echo "     when you're ready."
echo ""
echo "💡 Available commands:"
echo "  k / kubectl     - kubectl (color-coded via kubecolor)"
echo "  kubectx / kctx  - switch clusters (also: kubectl ctx)"
echo "  kubens  / kns   - switch namespaces (also: kubectl ns)"
echo "  k9s             - terminal UI dashboard"
echo "  stern <prefix>  - tail logs across pods"
echo "  kubectl neat    - clean up YAML output"
echo "  kubectl tree <kind>/<name>   - visualize resource hierarchy"
echo "  kubectl access-matrix        - RBAC who-can-do-what table"
echo "  kubectl krew upgrade         - update all krew plugins"
echo ""
