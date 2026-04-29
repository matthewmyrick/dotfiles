#!/usr/bin/env zsh
# Kubernetes shell wiring
# - krew on PATH
# - kubecolor as default kubectl wrapper
# - kubectl completion (extended to k and kubecolor)
# - fzf-powered interactive pickers for pods/containers/resources

# --- krew on PATH ---------------------------------------------------------
if [[ -d "${KREW_ROOT:-$HOME/.krew}/bin" ]]; then
  if [[ ":$PATH:" != *":${KREW_ROOT:-$HOME/.krew}/bin:"* ]]; then
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  fi
fi

# --- kubecolor: color-coded kubectl --------------------------------------
if command -v kubecolor >/dev/null 2>&1; then
  alias kubectl="kubecolor"
  export KUBECOLOR_OBJ_FRESHNESS="${KUBECOLOR_OBJ_FRESHNESS:-1}"
fi

# --- kubectl completion ---------------------------------------------------
if command -v kubectl >/dev/null 2>&1; then
  _kubectl_completion_cache="${HOME}/.cache/kubectl-completion.zsh"
  if [[ ! -f "$_kubectl_completion_cache" || ! -s "$_kubectl_completion_cache" ]]; then
    mkdir -p "$(dirname "$_kubectl_completion_cache")"
    kubectl completion zsh > "$_kubectl_completion_cache" 2>/dev/null
  fi
  [[ -s "$_kubectl_completion_cache" ]] && source "$_kubectl_completion_cache"
  unset _kubectl_completion_cache

  if typeset -f __start_kubectl >/dev/null 2>&1; then
    compdef __start_kubectl k
    command -v kubecolor >/dev/null 2>&1 && compdef __start_kubectl kubecolor
  fi
fi

# Drop any aliases that we replace with smart functions below. zsh expands
# aliases before function lookup, so a leftover alias would shadow the fn.
unalias kl klf kex kdp ktree 2>/dev/null

# --- Where am I -----------------------------------------------------------
kwhere() {
  local ctx ns
  ctx="$(kubectl config current-context 2>/dev/null)"
  ns="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
  [[ -z "$ctx" ]] && { echo "no current kubectl context"; return 1; }
  [[ -z "$ns" ]] && ns="(unset — defaults to 'default')"
  echo "context:   $ctx"
  echo "namespace: $ns"
}

# =========================================================================
# Interactive pickers (fzf-based)
# =========================================================================

# _kpick_pod — fzf over pods in current namespace, returns pod name only.
# Preview pane shows describe output for the highlighted pod.
_kpick_pod() {
  command -v fzf >/dev/null 2>&1 || { echo "fzf not installed" >&2; return 1; }
  local list
  list=$(kubectl get pods --no-headers 2>/dev/null) || return 1
  [[ -z "$list" ]] && { echo "no pods in $(kubectl config view --minify -o 'jsonpath={..namespace}')" >&2; return 1; }
  local header="NAME                                READY   STATUS      RESTARTS   AGE"
  echo "$list" | fzf \
    --prompt="pod > " \
    --height=60% --border --ansi \
    --header="$header" \
    --preview 'kubectl describe pod {1} 2>&1 | head -60' \
    --preview-window='right:60%:wrap' \
    | awk '{print $1}'
}

# _kpick_container <pod> — return container name. If pod has 1 container,
# auto-pick. If multiple, fzf. Empty pod arg → returns nothing.
_kpick_container() {
  local pod="$1"
  [[ -z "$pod" ]] && return 1
  local containers
  containers=$(kubectl get pod "$pod" \
    -o jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}' 2>/dev/null)
  [[ -z "$containers" ]] && return 1
  local count
  count=$(echo "$containers" | grep -c .)
  if [[ "$count" -le 1 ]]; then
    echo "$containers" | head -1
    return 0
  fi
  command -v fzf >/dev/null 2>&1 || { echo "$containers" | head -1; return 0; }
  echo "$containers" | fzf --prompt="container ($pod) > " --height=40% --border
}

# _kpick_resource — fzf over the common workload kinds in this namespace.
# Returns "kind/name" suitable for `kubectl tree`, `describe`, etc.
_kpick_resource() {
  command -v fzf >/dev/null 2>&1 || { echo "fzf not installed" >&2; return 1; }
  local list
  list=$(kubectl get deployments,statefulsets,daemonsets,jobs,cronjobs,services,pods \
    --no-headers 2>/dev/null) || return 1
  [[ -z "$list" ]] && { echo "no resources" >&2; return 1; }
  echo "$list" | fzf \
    --prompt="resource > " \
    --height=60% --border --ansi \
    --preview 'kubectl describe {1} 2>&1 | head -60' \
    --preview-window='right:60%:wrap' \
    | awk '{print $1}'
}

# =========================================================================
# Smart wrappers — interactive when called with no args, passthrough otherwise
# =========================================================================

# kl — kubectl logs (one shot). No args: pick pod, auto-pick container.
kl() {
  if [[ $# -gt 0 ]]; then
    kubectl logs "$@"
    return
  fi
  local pod container
  pod=$(_kpick_pod) || return 1
  [[ -z "$pod" ]] && return 1
  container=$(_kpick_container "$pod") || return 1
  echo "📜 kubectl logs $pod -c $container"
  kubectl logs "$pod" -c "$container"
}

# klf — kubectl logs -f. No args: picker; with args: passthrough.
klf() {
  if [[ $# -gt 0 ]]; then
    kubectl logs -f "$@"
    return
  fi
  local pod container
  pod=$(_kpick_pod) || return 1
  [[ -z "$pod" ]] && return 1
  container=$(_kpick_container "$pod") || return 1
  echo "📜 kubectl logs -f $pod -c $container  (Ctrl-C to stop)"
  kubectl logs -f "$pod" -c "$container"
}

# kex — kubectl exec -it into a pod. Tries bash, falls back to sh.
kex() {
  if [[ $# -gt 0 ]]; then
    kubectl exec -it "$@"
    return
  fi
  local pod container
  pod=$(_kpick_pod) || return 1
  [[ -z "$pod" ]] && return 1
  container=$(_kpick_container "$pod") || return 1
  echo "🔧 kubectl exec -it $pod -c $container -- (bash|sh)"
  kubectl exec -it "$pod" -c "$container" -- \
    sh -c 'command -v bash >/dev/null && exec bash || exec sh'
}

# kdp — describe pod. No args: picker; with args: passthrough.
kdp() {
  if [[ $# -gt 0 ]]; then
    kubectl describe pod "$@"
    return
  fi
  local pod
  pod=$(_kpick_pod) || return 1
  [[ -z "$pod" ]] && return 1
  echo "📋 kubectl describe pod $pod"
  kubectl describe pod "$pod"
}

# ktree — visualize a resource. No args: picker over workloads; with args: passthrough.
ktree() {
  if [[ $# -gt 0 ]]; then
    kubectl tree "$@"
    return
  fi
  local resource
  resource=$(_kpick_resource) || return 1
  [[ -z "$resource" ]] && return 1
  echo "🌳 kubectl tree $resource"
  kubectl tree "$resource"
}

# =========================================================================
# Events
# =========================================================================
# `kubectl events` sorts by lastTimestamp by default (newer kubectl).
# `--types Warning` filters to non-Normal events.

# keerr — warning/error events in current namespace.
keerr() {
  kubectl events --types=Warning "$@"
}

# keerra — warning/error events across all namespaces.
keerra() {
  kubectl events -A --types=Warning "$@"
}

# =========================================================================
# khelp — one-screen reference
# =========================================================================
khelp() {
  local b=$'\e[1m' d=$'\e[2m' c=$'\e[36m' g=$'\e[32m' r=$'\e[0m'

  print -r -- "${b}where am I${r}"
  printf "  %-10s ${d}%-32s${r} ${c}%s${r}\n" \
    "kw"      "kwhere"                          "current context + ns" \
    "kctx"    "kubectx [name]"                  "list / switch clusters" \
    "kns"     "kubens [name]"                   "list / switch namespaces"

  print
  print -r -- "${b}get / inspect${r}"
  printf "  %-10s ${d}%-32s${r} ${c}%s${r}\n" \
    "k"       "kubectl"                         "k get pods -A" \
    "kgp"     "kubectl get pods"                "kgp -o wide" \
    "kga"     "kubectl get all -A"              "everything, all namespaces" \
    "kneat"   "kubectl neat"                    "k get pod foo -o yaml | kneat"
  print -r -- "  ${g}interactive (no args ⇒ fzf picker):${r}"
  printf "  %-10s ${d}%-32s${r} ${c}%s${r}\n" \
    "kdp"     "kubectl describe pod"            "kdp ⇒ pick pod" \
    "ktree"   "kubectl tree"                    "ktree ⇒ pick workload"

  print
  print -r -- "${b}logs / exec${r}  ${g}(no args ⇒ pick pod, auto-pick container if 1)${r}"
  printf "  %-10s ${d}%-32s${r} ${c}%s${r}\n" \
    "kl"      "kubectl logs"                    "kl ⇒ pick" \
    "klf"     "kubectl logs -f"                 "klf ⇒ pick + tail" \
    "kex"     "kubectl exec -it"                "kex ⇒ pick + bash/sh" \
    "stern"   "stern <prefix>"                  "stern my-app- (multi-pod tail)"

  print
  print -r -- "${b}events${r}"
  printf "  %-10s ${d}%-32s${r} ${c}%s${r}\n" \
    "ke"      "kubectl events"                  "current ns" \
    "kew"     "kubectl events --watch"          "live tail" \
    "kea"     "kubectl events -A"               "all namespaces" \
    "keerr"   "kubectl events --types=Warning"  "current ns, warnings only" \
    "keerra"  "kubectl events -A --types=Warn." "all namespaces, warnings only"

  print
  print -r -- "${b}apply / change${r}"
  printf "  %-10s ${d}%-32s${r} ${c}%s${r}\n" \
    "ka"      "kubectl apply -f . -R"           "apply every yaml here, recursive"

  print
  print -r -- "${b}plugins / ui${r}"
  printf "  %-10s ${d}%-32s${r} ${c}%s${r}\n" \
    "k9s"     "k9s"                             "terminal dashboard" \
    "kkup"    "kubectl krew upgrade"            "update all krew plugins" \
    "kh"      "khelp"                           "this card"
}
alias kh='khelp'
