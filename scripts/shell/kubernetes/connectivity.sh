#!/usr/bin/env zsh
# Kubernetes connectivity deep-dive helpers.
# Functions: kcidrs, kports, kconn, ksvcconn, kpolexp
# These complement knet (summary) with the "what can talk to what" detail.

# =========================================================================
# kcidrs — k8s-centric IP layout, with AWS subnets joined to node/pod usage.
# Answers: where do my pod IPs come from, where do my service IPs come from,
# which AWS subnets are actually being used by my workloads?
# =========================================================================
kcidrs() {
  # --- 1. KUBERNETES VIEW ----------------------------------------------
  _kn_hdr "kubernetes — service network (cluster-internal IPs)"
  local svc_ip dns_ip
  svc_ip=$(kubectl get svc kubernetes -n default -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
  dns_ip=$(kubectl get svc -n kube-system -l k8s-app=kube-dns -o jsonpath='{.items[0].spec.clusterIP}' 2>/dev/null)
  if [[ -n "$svc_ip" ]]; then
    printf "  kubernetes API svc:  %s\n" "$svc_ip"
    [[ -n "$dns_ip" ]] && printf "  cluster DNS svc:     %s\n" "$dns_ip"
    local svc_prefix
    svc_prefix=$(echo "$svc_ip" | awk -F. '{print $1"."$2}')
    _kn_dim "  service CIDR is approximately ${svc_prefix}.0.0/16 (containing both IPs above)"
  else
    _kn_dim "  could not read kubernetes svc — check kubectl access"
  fi
  echo

  _kn_hdr "kubernetes — pod IP source"
  local pod_cidr
  pod_cidr=$(kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}' 2>/dev/null)
  if [[ -n "$pod_cidr" ]]; then
    printf "  per-node pod CIDR: %s (other nodes have similar)\n" "$pod_cidr"
    _kn_dim "  → using a CNI like Flannel/Calico — each node carves a /24 from a cluster CIDR"
  else
    _kn_dim "  no per-node podCIDR set → AWS VPC CNI is in use"
    _kn_dim "  → pods get real VPC IPs from the same subnets as their node (see joined table below)"
  fi
  echo

  # --- 2. AWS VIEW (joined to k8s usage) -------------------------------
  local cluster region
  cluster=$(_keks_cluster)
  region=$(_keks_region)
  if [[ -z "$cluster" ]] || ! command -v aws >/dev/null 2>&1; then
    return 0
  fi

  local vpc_id
  vpc_id=$(aws eks describe-cluster --name "$cluster" --region "$region" \
    --query 'cluster.resourcesVpcConfig.vpcId' --output text 2>/dev/null)
  [[ -z "$vpc_id" || "$vpc_id" == "None" ]] && return 0

  local vpc_cidr
  vpc_cidr=$(aws ec2 describe-vpcs --vpc-ids "$vpc_id" --region "$region" \
    --query 'Vpcs[0].CidrBlock' --output text 2>/dev/null)
  _kn_hdr "AWS — VPC layer"
  printf "  vpc:        %s\n" "$vpc_id"
  printf "  vpc CIDR:   %s\n" "$vpc_cidr"
  echo

  # Build node → subnet map with a single AWS call
  local node_ips
  node_ips=$(kubectl get nodes -o jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address},{end}' 2>/dev/null | sed 's/,$//')

  local node_subnet_data=""
  if [[ -n "$node_ips" ]]; then
    node_subnet_data=$(aws ec2 describe-instances --region "$region" \
      --filters "Name=private-ip-address,Values=$node_ips" \
      --query 'Reservations[].Instances[].[PrivateIpAddress,SubnetId]' \
      --output text 2>/dev/null)
  fi

  # Build node-name → subnet-id (so we can attribute pods to subnets via their node)
  local pod_node_data
  pod_node_data=$(kubectl get pods -A -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}' 2>/dev/null | grep -v '^$')

  # Get the kubectl node-name → IP map
  local node_name_ip
  node_name_ip=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.addresses[?(@.type=="InternalIP")].address}{"\n"}{end}' 2>/dev/null)

  # Compose: name<TAB>subnet for each node, then pods-per-subnet via node membership
  local subnet_node_count subnet_pod_count
  subnet_node_count=$(echo "$node_subnet_data" | awk -F'\t' 'NF==2 {c[$2]++} END {for (s in c) print s"\t"c[s]}')

  # node IP → subnet
  # Then for each pod's nodeName, lookup IP, then subnet, then count
  subnet_pod_count=$(awk -F'\t' '
    BEGIN { OFS="\t" }
    NR==FNR && NF==2 { ip2subnet[$1]=$2; next }            # node_subnet_data
    FILENAME==ARGV[2] && NF==2 { name2ip[$1]=$2; next }    # node_name_ip
    FILENAME==ARGV[3] {                                     # pod_node_data (one node per line)
      ip = name2ip[$1]
      if (ip == "") next
      sn = ip2subnet[ip]
      if (sn == "") next
      counts[sn]++
    }
    END { for (s in counts) print s, counts[s] }
  ' \
    <(echo "$node_subnet_data") \
    <(echo "$node_name_ip") \
    <(echo "$pod_node_data"))

  # Pull subnet metadata, then join with the counts above
  _kn_hdr "AWS — subnets, with k8s usage joined in"
  printf "  %-26s %-17s %-12s %-7s %-9s %-7s %s\n" \
    "NAME" "CIDR" "AZ" "PUBLIC" "FREE-IPS" "NODES" "PODS"

  aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --region "$region" \
    --query 'Subnets[].[SubnetId,CidrBlock,AvailabilityZone,MapPublicIpOnLaunch,AvailableIpAddressCount,Tags[?Key==`Name`]|[0].Value]' \
    --output text 2>/dev/null \
    | while IFS=$'\t' read -r sid cidr az pub free name; do
        local nodes pods
        nodes=$(echo "$subnet_node_count" | awk -F'\t' -v s="$sid" '$1==s {print $2}')
        pods=$(echo "$subnet_pod_count"  | awk -F'\t' -v s="$sid" '$1==s {print $2}')
        printf "  %-26s %-17s %-12s %-7s %-9s %-7s %s\n" \
          "${name:-$sid}" "$cidr" "$az" "$pub" "$free" "${nodes:-0}" "${pods:-0}"
      done

  echo
  _kn_dim "  PODS column counts pods running on nodes in that subnet (VPC CNI: pod IPs come from these CIDRs)."
}

# =========================================================================
# kports — every exposed port across the cluster
# =========================================================================
kports() {
  _kn_hdr "all service ports (cluster-wide)"
  printf "  %-22s %-32s %-13s %-16s %-16s %s\n" "NAMESPACE" "NAME" "TYPE" "CLUSTER-IP" "PORT" "TARGET"
  kubectl get svc -A -o json 2>/dev/null | jq -r '
    .items[]
    | .metadata.namespace as $ns
    | .metadata.name as $name
    | .spec.type as $type
    | (.spec.clusterIP // "-") as $cip
    | (.spec.ports // [])[]
    | [$ns, $name, $type, $cip,
       "\(.port)/\(.protocol // "TCP")",
       "→ \(.targetPort)\(if .nodePort then " (NodePort:\(.nodePort))" else "" end)"]
    | @tsv
  ' 2>/dev/null \
    | awk -F'\t' '{ printf "  %-22s %-32s %-13s %-16s %-16s %s\n", $1, $2, $3, $4, $5, $6 }'
}

# =========================================================================
# kconn — full connectivity report for one pod
# (no args ⇒ fzf picker; with arg ⇒ that pod)
# =========================================================================
kconn() {
  local pod
  if [[ $# -gt 0 ]]; then
    pod="$1"
  else
    pod=$(_kpick_pod) || return 1
  fi
  [[ -z "$pod" ]] && return 1

  local pod_json
  pod_json=$(kubectl get pod "$pod" -o json 2>/dev/null) || {
    echo "pod not found: $pod" >&2; return 1
  }

  local pod_ns
  pod_ns=$(echo "$pod_json" | jq -r '.metadata.namespace')
  local pod_labels_json
  pod_labels_json=$(echo "$pod_json" | jq '.metadata.labels // {}')

  # --- Identity ---
  _kn_hdr "POD"
  echo "$pod_json" | jq -r '
    "  name:      \(.metadata.name)",
    "  namespace: \(.metadata.namespace)",
    "  ip:        \(.status.podIP // "(pending)")",
    "  node:      \(.spec.nodeName // "?")",
    "  node ip:   \(.status.hostIP // "?")",
    "  phase:     \(.status.phase)"
  '
  echo

  # --- Labels (used for selectors below) ---
  _kn_hdr "LABELS  (these determine what selects/applies to this pod)"
  echo "$pod_json" | jq -r '
    if (.metadata.labels // {} | length) > 0 then
      .metadata.labels | to_entries | map("  \(.key)=\(.value)") | .[]
    else
      "  (no labels)"
    end
  '
  echo

  # --- Declared container ports ---
  _kn_hdr "DECLARED PORTS  (what the containers listen on)"
  local has_ports
  has_ports=$(echo "$pod_json" | jq '[.spec.containers[].ports // [] | length] | add // 0')
  if [[ "$has_ports" == "0" ]]; then
    _kn_dim "  (no ports declared on any container)"
  else
    echo "$pod_json" | jq -r '
      .spec.containers[] |
      if (.ports // []) | length == 0 then
        "  \(.name): (no ports)"
      else
        "  \(.name):",
        (.ports[] | "    \(.containerPort)/\(.protocol // "TCP")\(if .name then "  (\(.name))" else "" end)")
      end
    '
  fi
  echo

  # --- Services that match this pod's labels ---
  _kn_hdr "SERVICES ROUTING TO THIS POD"
  local matching_svcs
  matching_svcs=$(kubectl get svc -A -o json 2>/dev/null | jq -r --argjson plabels "$pod_labels_json" '
    .items[]
    | select(.spec.selector != null and (.spec.selector | length > 0))
    | select(.spec.selector | to_entries | all(.value == ($plabels[.key] // null)))
    | "  \(.metadata.namespace)/\(.metadata.name)",
      "    type:       \(.spec.type)",
      "    cluster-ip: \(.spec.clusterIP // "-")",
      "    ports:      \([.spec.ports[]? | "\(.port)/\(.protocol // "TCP") → \(.targetPort)"] | join(", "))",
      ""
  ')
  if [[ -z "$matching_svcs" ]]; then
    _kn_dim "  (no services match this pod's labels — pod is not addressable via service)"
  else
    echo "$matching_svcs"
  fi

  # --- Network policies applying to this pod ---
  _kn_hdr "NETWORK POLICIES APPLYING TO THIS POD"
  local matching_np
  matching_np=$(kubectl get netpol -n "$pod_ns" -o json 2>/dev/null | jq -r --argjson plabels "$pod_labels_json" '
    .items[]
    | select(
        ((.spec.podSelector.matchLabels // {}) | length == 0)
        or ((.spec.podSelector.matchLabels // {}) | to_entries | all(.value == ($plabels[.key] // null)))
      )
    | "  \(.metadata.name)  [types: \((.spec.policyTypes // ["Ingress"]) | join(","))]"
  ')
  if [[ -z "$matching_np" ]]; then
    _kn_dim "  (no policies — pod has unrestricted in/out connectivity at the netpol layer)"
    _kn_dim "  (NB: AWS security groups still apply at the VPC layer)"
  else
    echo "$matching_np"
    echo
    _kn_dim "  → run 'kpolexp <policy-name>' to see exactly what each one allows/blocks"
  fi
}

# =========================================================================
# ksvcconn — connectivity report for a service
# =========================================================================
ksvcconn() {
  local svc
  if [[ $# -gt 0 ]]; then
    svc="$1"
  else
    command -v fzf >/dev/null 2>&1 || { echo "install fzf or pass a service name" >&2; return 1; }
    svc=$(kubectl get svc --no-headers 2>/dev/null \
      | fzf --prompt="service > " --height=50% --border \
            --preview 'kubectl describe svc {1} 2>&1' \
            --preview-window='right:60%:wrap' \
      | awk '{print $1}')
    [[ -z "$svc" ]] && return 1
  fi

  local svc_json
  svc_json=$(kubectl get svc "$svc" -o json 2>/dev/null) || {
    echo "service not found: $svc" >&2; return 1
  }

  _kn_hdr "SERVICE: $svc"
  echo "$svc_json" | jq -r '
    "  type:        \(.spec.type)",
    "  cluster-ip:  \(.spec.clusterIP // "-")",
    "  external:    \(.status.loadBalancer.ingress[0].hostname // .status.loadBalancer.ingress[0].ip // "(none)")",
    "  selector:    \(.spec.selector // {} | to_entries | map("\(.key)=\(.value)") | join(", ") | if . == "" then "(no selector — manual endpoints)" else . end)"
  '
  echo

  _kn_hdr "PORTS"
  echo "$svc_json" | jq -r '
    (.spec.ports // [])[] |
    "  \(.port)/\(.protocol // "TCP")\(if .name then " [\(.name)]" else "" end) → targetPort \(.targetPort)\(if .nodePort then " (NodePort: \(.nodePort))" else "" end)"
  '
  echo

  _kn_hdr "BACKING ENDPOINTS  (the actual pod IPs traffic lands on)"
  kubectl get endpoints "$svc" -o json 2>/dev/null | jq -r '
    if (.subsets // []) | length == 0 then
      "  (no ready endpoints — service has nothing to route to)"
    else
      .subsets[] |
      "  ports: \([.ports[]? | "\(.port)/\(.protocol // "TCP")"] | join(", "))",
      (.addresses // [] | if length == 0 then "  (no ready addresses)" else (.[] | "    \(.ip)  \(.targetRef.name // "?")") end)
    end
  '
}

# =========================================================================
# kpolexp — explain a network policy in plain language
# =========================================================================
kpolexp() {
  local name ns
  if [[ $# -gt 0 ]]; then
    name="$1"
    ns="${2:-$(kubectl config view --minify -o 'jsonpath={..namespace}' 2>/dev/null)}"
  else
    command -v fzf >/dev/null 2>&1 || { echo "install fzf or pass a netpol name" >&2; return 1; }
    local picked
    picked=$(kubectl get netpol -A --no-headers 2>/dev/null \
      | fzf --prompt="netpol > " --height=50% --border \
            --preview 'kubectl describe netpol -n {1} {2} 2>&1' \
            --preview-window='right:65%:wrap')
    [[ -z "$picked" ]] && return 1
    ns=$(echo "$picked" | awk '{print $1}')
    name=$(echo "$picked" | awk '{print $2}')
  fi
  [[ -z "$ns" ]] && ns=default

  local pol
  pol=$(kubectl get netpol "$name" -n "$ns" -o json 2>/dev/null) || {
    echo "netpol not found: $ns/$name" >&2; return 1
  }

  _kn_hdr "$ns/$name"

  echo "$pol" | jq -r '
    "",
    "  applies to pods matching:",
    (.spec.podSelector.matchLabels // {}
      | if length == 0 then "    (all pods in this namespace)"
        else (to_entries | map("    \(.key)=\(.value)") | join("\n"))
        end),
    "",
    "  policy types: \((.spec.policyTypes // ["Ingress"]) | join(", "))"
  '

  # INGRESS
  if echo "$pol" | jq -e '.spec.ingress' >/dev/null 2>&1; then
    print -- ""
    print -- $'\e[1m'"  INGRESS  (incoming traffic to these pods)"$'\e[0m'
    local ing_n
    ing_n=$(echo "$pol" | jq '.spec.ingress | length')
    if [[ "$ing_n" == "0" ]]; then
      _kn_dim "    (rules empty — all incoming blocked)"
    else
      echo "$pol" | jq -r '
        .spec.ingress[] |
        "    rule:",
        (.from // [] |
          if length == 0 then "      from: ANYWHERE (0.0.0.0/0)"
          else (.[] |
            (if .podSelector then "      from pods: \((.podSelector.matchLabels // {}) | to_entries | map("\(.key)=\(.value)") | join(",") | if . == "" then "ALL" else . end)" else empty end),
            (if .namespaceSelector then "      from ns:   \((.namespaceSelector.matchLabels // {}) | to_entries | map("\(.key)=\(.value)") | join(",") | if . == "" then "ALL" else . end)" else empty end),
            (if .ipBlock then "      from cidr: \(.ipBlock.cidr)\(if .ipBlock.except then " (except: \(.ipBlock.except | join(", ")))" else "" end)" else empty end)
          )
        end),
        (.ports // [] |
          if length == 0 then "      on ports:  ANY"
          else (.[] | "      on port:   \(.port)/\(.protocol // "TCP")")
          end),
        ""
      '
    fi
  fi

  # EGRESS
  if echo "$pol" | jq -e '.spec.egress' >/dev/null 2>&1; then
    print -- $'\e[1m'"  EGRESS  (outgoing traffic from these pods)"$'\e[0m'
    local eg_n
    eg_n=$(echo "$pol" | jq '.spec.egress | length')
    if [[ "$eg_n" == "0" ]]; then
      _kn_dim "    (rules empty — all outgoing blocked)"
    else
      echo "$pol" | jq -r '
        .spec.egress[] |
        "    rule:",
        (.to // [] |
          if length == 0 then "      to: ANYWHERE (0.0.0.0/0)"
          else (.[] |
            (if .podSelector then "      to pods:   \((.podSelector.matchLabels // {}) | to_entries | map("\(.key)=\(.value)") | join(",") | if . == "" then "ALL" else . end)" else empty end),
            (if .namespaceSelector then "      to ns:     \((.namespaceSelector.matchLabels // {}) | to_entries | map("\(.key)=\(.value)") | join(",") | if . == "" then "ALL" else . end)" else empty end),
            (if .ipBlock then "      to cidr:   \(.ipBlock.cidr)\(if .ipBlock.except then " (except: \(.ipBlock.except | join(", ")))" else "" end)" else empty end)
          )
        end),
        (.ports // [] |
          if length == 0 then "      on ports:  ANY"
          else (.[] | "      on port:   \(.port)/\(.protocol // "TCP")")
          end),
        ""
      '
    fi
  fi

  # If only Ingress is in policyTypes, egress is unrestricted (and vice versa)
  local types
  types=$(echo "$pol" | jq -r '(.spec.policyTypes // ["Ingress"]) | join(",")')
  if [[ "$types" == "Ingress" ]]; then
    _kn_dim "  (egress is NOT in policyTypes → unrestricted outbound)"
  elif [[ "$types" == "Egress" ]]; then
    _kn_dim "  (ingress is NOT in policyTypes → unrestricted inbound)"
  fi
}
