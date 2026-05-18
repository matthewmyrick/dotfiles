#!/usr/bin/env zsh
# Kubernetes networking helpers — AWS/EKS aware.
# Functions: knet, kaws, knodes, ksvc, kning, knetpol, kep

# --- Detect EKS cluster + region from current context --------------------
# EKS contexts use ARNs: arn:aws:eks:<region>:<account>:cluster/<name>
_keks_cluster() {
  local ctx
  ctx=$(kubectl config current-context 2>/dev/null) || return 1
  [[ "$ctx" == arn:aws:eks:* ]] || return 1
  echo "$ctx" | awk -F/ '{print $NF}'
}

_keks_region() {
  local ctx
  ctx=$(kubectl config current-context 2>/dev/null) || return 1
  [[ "$ctx" == arn:aws:eks:* ]] || return 1
  echo "$ctx" | awk -F: '{print $4}'
}

# Internal: print a header line in bold. Uses ANSI-C quoting so the escape
# character is baked in at parse time — avoids printf-implementation issues.
_kn_hdr() {
  print -- $'\e[1m'"$1"$'\e[0m'
}

# Internal: dim text helper
_kn_dim() {
  print -- $'\e[2m'"$1"$'\e[0m'
}

# =========================================================================
# knet — at-a-glance networking overview
# =========================================================================
knet() {
  local cluster region ns
  cluster=$(_keks_cluster)
  region=$(_keks_region)
  ns=$(kubectl config view --minify -o 'jsonpath={..namespace}' 2>/dev/null)
  [[ -z "$ns" ]] && ns="default"

  _kn_hdr "where"
  printf "  cluster:    %s\n" "${cluster:-(non-EKS context)}"
  printf "  region:     %s\n" "${region:-n/a}"
  printf "  namespace:  %s\n" "$ns"
  echo

  # Nodes
  local nodes_total nodes_ready
  nodes_total=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
  nodes_ready=$(kubectl get nodes --no-headers 2>/dev/null | awk '$2=="Ready"' | wc -l | tr -d ' ')
  _kn_hdr "nodes"
  printf "  ready:      %s / %s\n" "$nodes_ready" "$nodes_total"
  echo

  # Services — current ns + all-ns breakdown
  _kn_hdr "services"
  local svc_json_ns svc_json_all
  svc_json_ns=$(kubectl get svc -o json 2>/dev/null)
  svc_json_all=$(kubectl get svc -A -o json 2>/dev/null)
  if [[ -n "$svc_json_ns" ]]; then
    local n_total n_lb n_np n_cip a_total a_lb a_np a_cip
    n_total=$(echo "$svc_json_ns"  | jq '.items | length')
    n_lb=$(echo    "$svc_json_ns"  | jq '[.items[] | select(.spec.type=="LoadBalancer")] | length')
    n_np=$(echo    "$svc_json_ns"  | jq '[.items[] | select(.spec.type=="NodePort")]     | length')
    n_cip=$(echo   "$svc_json_ns"  | jq '[.items[] | select(.spec.type=="ClusterIP")]    | length')
    a_total=$(echo "$svc_json_all" | jq '.items | length')
    a_lb=$(echo    "$svc_json_all" | jq '[.items[] | select(.spec.type=="LoadBalancer")] | length')
    a_np=$(echo    "$svc_json_all" | jq '[.items[] | select(.spec.type=="NodePort")]     | length')
    a_cip=$(echo   "$svc_json_all" | jq '[.items[] | select(.spec.type=="ClusterIP")]    | length')
    printf "  current ns:  %s  (LB=%s · NodePort=%s · ClusterIP=%s)\n" "$n_total" "$n_lb" "$n_np" "$n_cip"
    printf "  all ns:      %s  (LB=%s · NodePort=%s · ClusterIP=%s)\n" "$a_total" "$a_lb" "$a_np" "$a_cip"
  fi
  echo

  # Ingresses
  local ing_ns ing_all
  ing_ns=$(kubectl get ingress --no-headers 2>/dev/null | wc -l | tr -d ' ')
  ing_all=$(kubectl get ingress -A --no-headers 2>/dev/null | wc -l | tr -d ' ')
  _kn_hdr "ingresses"
  printf "  current ns:  %s\n" "$ing_ns"
  printf "  all ns:      %s\n" "$ing_all"
  echo

  # Network policies
  local np_ns np_all
  np_ns=$(kubectl get netpol --no-headers 2>/dev/null | wc -l | tr -d ' ')
  np_all=$(kubectl get netpol -A --no-headers 2>/dev/null | wc -l | tr -d ' ')
  _kn_hdr "network policies"
  printf "  current ns:  %s\n" "$np_ns"
  printf "  all ns:      %s\n" "$np_all"
  [[ "$np_ns" == "0" ]] && _kn_dim "  (no policies in this ns — all traffic to/from these pods is allowed)"
  echo

  # Warning events in current ns
  _kn_hdr "recent warnings (current ns)"
  local warns
  warns=$(kubectl events --types=Warning 2>/dev/null \
    | awk 'NR>1 {print}' \
    | head -5)
  if [[ -z "$warns" ]]; then
    print -- $'\e[32m'"  clean"$'\e[0m'
  else
    echo "$warns" | sed 's/^/  /'
  fi
}

# =========================================================================
# kaws — EKS/VPC details for current context
# =========================================================================
kaws() {
  command -v aws >/dev/null 2>&1 || { echo "aws CLI not installed" >&2; return 1; }
  local cluster region
  cluster=$(_keks_cluster) || { echo "current context is not an EKS cluster" >&2; return 1; }
  region=$(_keks_region)

  _kn_hdr "EKS cluster"
  aws eks describe-cluster --name "$cluster" --region "$region" \
    --query 'cluster.{name:name,status:status,version:version,vpc:resourcesVpcConfig.vpcId,publicAccess:resourcesVpcConfig.endpointPublicAccess,privateAccess:resourcesVpcConfig.endpointPrivateAccess,clusterSG:resourcesVpcConfig.clusterSecurityGroupId}' \
    --output table 2>/dev/null
  echo

  # Pull subnet IDs from cluster config, then describe them
  local subnet_ids
  subnet_ids=$(aws eks describe-cluster --name "$cluster" --region "$region" \
    --query 'cluster.resourcesVpcConfig.subnetIds' --output text 2>/dev/null)
  if [[ -n "$subnet_ids" ]]; then
    _kn_hdr "subnets (from EKS config)"
    aws ec2 describe-subnets --region "$region" --subnet-ids ${=subnet_ids} \
      --query 'Subnets[].{id:SubnetId,cidr:CidrBlock,az:AvailabilityZone,public:MapPublicIpOnLaunch,name:Tags[?Key==`Name`]|[0].Value}' \
      --output table 2>/dev/null
    echo
  fi

  # Security groups attached to the cluster
  local sg_ids
  sg_ids=$(aws eks describe-cluster --name "$cluster" --region "$region" \
    --query 'cluster.resourcesVpcConfig.securityGroupIds' --output text 2>/dev/null)
  local cluster_sg
  cluster_sg=$(aws eks describe-cluster --name "$cluster" --region "$region" \
    --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text 2>/dev/null)
  local all_sgs="$sg_ids $cluster_sg"
  if [[ -n "$(echo $all_sgs | tr -d ' ')" ]]; then
    _kn_hdr "security groups"
    aws ec2 describe-security-groups --region "$region" --group-ids ${=all_sgs} \
      --query 'SecurityGroups[].{id:GroupId,name:GroupName,desc:Description}' \
      --output table 2>/dev/null
  fi
}

# =========================================================================
# knodes — nodes with subnet, AZ, instance type, internal IP
# =========================================================================
knodes() {
  local region
  region=$(_keks_region)

  # Pull node info from kubectl (works without aws)
  _kn_hdr "nodes"
  kubectl get nodes -o json 2>/dev/null | jq -r '
    .items[]
    | [
        .metadata.name,
        (.status.addresses[] | select(.type=="InternalIP") | .address),
        (.metadata.labels["topology.kubernetes.io/zone"] // "?"),
        (.metadata.labels["node.kubernetes.io/instance-type"] // "?"),
        (.metadata.labels["beta.kubernetes.io/instance-type"] // "?")
      ]
    | @tsv
  ' | awk -F'\t' 'BEGIN {
      printf "  %-45s %-15s %-12s %-12s\n", "NAME", "INTERNAL-IP", "AZ", "TYPE"
    }
    {
      type = ($4 != "?") ? $4 : $5
      printf "  %-45s %-15s %-12s %-12s\n", $1, $2, $3, type
    }'

  # If on EKS + aws CLI, augment with subnet IDs by matching IP → ENI
  if [[ -n "$region" ]] && command -v aws >/dev/null 2>&1; then
    echo
    _kn_hdr "subnet placement (EC2)"
    local node_ips
    node_ips=$(kubectl get nodes -o jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address}{"\n"}{end}' 2>/dev/null \
      | tr '\n' ' ')
    [[ -n "$node_ips" ]] && aws ec2 describe-instances --region "$region" \
      --filters "Name=private-ip-address,Values=$(echo $node_ips | tr ' ' ',')" \
      --query 'Reservations[].Instances[].{ip:PrivateIpAddress,subnet:SubnetId,az:Placement.AvailabilityZone,type:InstanceType,id:InstanceId}' \
      --output table 2>/dev/null
  fi
}

# =========================================================================
# ksvc — services with endpoints + LB DNS
# =========================================================================
ksvc() {
  if [[ $# -gt 0 ]]; then
    kubectl get svc "$@"
    return
  fi
  _kn_hdr "services (current ns)"
  kubectl get svc -o wide 2>/dev/null
  echo
  # Endpoints — which pods back which service
  _kn_hdr "endpoints"
  kubectl get endpoints 2>/dev/null
}

# =========================================================================
# kning — ingresses
# =========================================================================
kning() {
  if [[ $# -gt 0 ]]; then
    kubectl get ingress "$@"
    return
  fi
  _kn_hdr "ingresses (current ns)"
  kubectl get ingress -o wide 2>/dev/null
  echo
  _kn_hdr "ingress classes"
  kubectl get ingressclass 2>/dev/null
}

# =========================================================================
# knetpol — fzf network policy picker → describe
# =========================================================================
knetpol() {
  if [[ $# -gt 0 ]]; then
    kubectl describe netpol "$@"
    return
  fi
  command -v fzf >/dev/null 2>&1 || { kubectl get netpol; return; }
  local list
  list=$(kubectl get netpol --no-headers 2>/dev/null) || return 1
  if [[ -z "$list" ]]; then
    echo "no network policies in current namespace"
    echo "(this means pods are unrestricted — all traffic allowed)"
    return 0
  fi
  local selected
  selected=$(echo "$list" | fzf \
    --prompt="netpol > " \
    --height=60% --border --ansi \
    --preview 'kubectl describe netpol {1} 2>&1' \
    --preview-window='right:65%:wrap' \
    | awk '{print $1}')
  [[ -z "$selected" ]] && return 1
  kubectl describe netpol "$selected"
}

# =========================================================================
# kep — endpoints picker (which pods back this service)
# =========================================================================
kep() {
  if [[ $# -gt 0 ]]; then
    kubectl get endpoints "$@"
    return
  fi
  command -v fzf >/dev/null 2>&1 || { kubectl get endpoints; return; }
  local svc
  svc=$(kubectl get svc --no-headers 2>/dev/null \
    | fzf --prompt="service > " --height=50% --border \
          --preview 'kubectl describe svc {1} 2>&1' \
          --preview-window='right:60%:wrap' \
    | awk '{print $1}')
  [[ -z "$svc" ]] && return 1
  echo
  _kn_hdr "service: $svc"
  kubectl describe svc "$svc"
  echo
  _kn_hdr "backing endpoints"
  kubectl get endpoints "$svc" -o wide
}
