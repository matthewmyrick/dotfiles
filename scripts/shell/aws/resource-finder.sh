#!/usr/bin/env zsh
# AWS Resource Finder
# Interactive AWS resource discovery with connection details

# Lazy load guard
[[ -n "${_AWS_RESOURCE_FINDER_LOADED}" ]] && return
_AWS_RESOURCE_FINDER_LOADED=1

# Color definitions
_AWS_RED='\033[0;31m'
_AWS_GREEN='\033[0;32m'
_AWS_YELLOW='\033[1;33m'
_AWS_BLUE='\033[0;34m'
_AWS_PURPLE='\033[0;35m'
_AWS_CYAN='\033[0;36m'
_AWS_WHITE='\033[1;37m'
_AWS_BOLD='\033[1m'
_AWS_NC='\033[0m' # No Color

# Main AWS resource finder function - AWS Private Resource finder
apr() {
    # Check if AWS CLI is installed
    if ! command -v aws >/dev/null 2>&1; then
        echo -e "${_AWS_RED}AWS CLI is not installed. Please install it first.${_AWS_NC}"
        return 1
    fi

    # Check if AWS is configured
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        echo -e "${_AWS_RED}AWS CLI is not configured or credentials are invalid.${_AWS_NC}"
        echo -e "${_AWS_YELLOW}Run 'aws configure' to set up your credentials.${_AWS_NC}"
        return 1
    fi

    # Select resource type
    local selected_type=$(echo -e "Database\nEC2\nCluster" | fzf --prompt="Select resource type: " --height=10)

    # Log the resource type selection
    echo -e "${_AWS_BOLD}${_AWS_BLUE}Selected resource type: ${_AWS_CYAN}$selected_type${_AWS_NC}"

    # Handle the selection
    case "$selected_type" in
    "Database")
        _awsf_database
        ;;
    "EC2")
        _awsf_ec2
        ;;
    "Cluster")
        _awsf_cluster
        ;;
    *)
        echo -e "${_AWS_RED}No selection made${_AWS_NC}"
        return 1
        ;;
    esac
}

# Handle RDS database discovery
_awsf_database() {
    echo -e "${_AWS_YELLOW}Fetching databases...${_AWS_NC}"
    local databases=$(aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier' --output text | tr '\t' '\n')
    
    if [[ -z "$databases" ]]; then
        echo -e "${_AWS_RED}No databases found in this region.${_AWS_NC}"
        return 1
    fi
    
    local selected_db=$(echo "$databases" | fzf --prompt="Select database: " --height=10)
    
    if [[ -z "$selected_db" ]]; then
        echo -e "${_AWS_RED}No database selected.${_AWS_NC}"
        return 1
    fi
    
    echo -e "${_AWS_BOLD}${_AWS_GREEN}Selected resource: ${_AWS_WHITE}$selected_db${_AWS_NC}"

    # Get database details
    local db_info=$(aws rds describe-db-instances --db-instance-identifier "$selected_db" --query 'DBInstances[0].[DBSubnetGroup.VpcId,Engine,MasterUsername,DBName,Endpoint.Port]' --output text)
    local vpc_id engine username db_name port
    read -r vpc_id engine username db_name port <<<"$db_info"

    # Get the private IP by finding the RDS network interface in this VPC
    local private_ip=$(aws ec2 describe-network-interfaces --filters "Name=description,Values=RDSNetworkInterface" "Name=vpc-id,Values=$vpc_id" --query 'NetworkInterfaces[0].PrivateIpAddress' --output text)

    echo -e "${_AWS_BOLD}${_AWS_PURPLE}Private IP: ${_AWS_WHITE}$private_ip${_AWS_NC}"

    # Generate connection string based on database engine
    case "$engine" in
    "postgres")
        echo -e "${_AWS_BOLD}${_AWS_GREEN}psql \"postgresql://$username:${_AWS_RED}<PASS>${_AWS_GREEN}@$private_ip:$port/${_AWS_RED}<DATABASE>${_AWS_GREEN}\"${_AWS_NC}"
        # Get list of databases
        echo ""
        echo -e "${_AWS_BOLD}${_AWS_CYAN}Available databases:${_AWS_NC}"
        if [ "$db_name" != "None" ] && [ -n "$db_name" ]; then
            echo -e "  ${_AWS_YELLOW}- $db_name ${_AWS_WHITE}(initial database)${_AWS_NC}"
        fi
        echo -e "  ${_AWS_YELLOW}- postgres ${_AWS_WHITE}(default)${_AWS_NC}"
        echo -e "  ${_AWS_YELLOW}- template1${_AWS_NC}"
        ;;
    "mysql")
        echo -e "${_AWS_BOLD}${_AWS_GREEN}mysql -h $private_ip -P $port -u $username -p ${_AWS_RED}<DATABASE>${_AWS_NC}"
        echo ""
        echo -e "${_AWS_BOLD}${_AWS_CYAN}Available databases:${_AWS_NC}"
        if [ "$db_name" != "None" ] && [ -n "$db_name" ]; then
            echo -e "  ${_AWS_YELLOW}- $db_name ${_AWS_WHITE}(initial database)${_AWS_NC}"
        fi
        echo -e "  ${_AWS_YELLOW}- mysql ${_AWS_WHITE}(system)${_AWS_NC}"
        echo -e "  ${_AWS_YELLOW}- information_schema ${_AWS_WHITE}(system)${_AWS_NC}"
        echo -e "  ${_AWS_YELLOW}- performance_schema ${_AWS_WHITE}(system)${_AWS_NC}"
        ;;
    "mariadb")
        echo -e "${_AWS_BOLD}${_AWS_GREEN}mysql -h $private_ip -P $port -u $username -p ${_AWS_RED}<DATABASE>${_AWS_NC}"
        echo ""
        echo -e "${_AWS_BOLD}${_AWS_CYAN}Available databases:${_AWS_NC}"
        if [ "$db_name" != "None" ] && [ -n "$db_name" ]; then
            echo -e "  ${_AWS_YELLOW}- $db_name ${_AWS_WHITE}(initial database)${_AWS_NC}"
        fi
        echo -e "  ${_AWS_YELLOW}- mysql ${_AWS_WHITE}(system)${_AWS_NC}"
        echo -e "  ${_AWS_YELLOW}- information_schema ${_AWS_WHITE}(system)${_AWS_NC}"
        echo -e "  ${_AWS_YELLOW}- performance_schema ${_AWS_WHITE}(system)${_AWS_NC}"
        ;;
    *)
        echo -e "${_AWS_RED}Connection string for $engine not implemented${_AWS_NC}"
        ;;
    esac
}

# Handle EC2 instance discovery
_awsf_ec2() {
    echo -e "${_AWS_YELLOW}Fetching EC2 instances...${_AWS_NC}"
    local instances=$(aws ec2 describe-instances --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0],InstanceId]' --output text | awk '{print ($1 == "None" || $1 == "") ? $2 : $1}')
    
    if [[ -z "$instances" ]]; then
        echo -e "${_AWS_RED}No EC2 instances found in this region.${_AWS_NC}"
        return 1
    fi
    
    local selected_instance=$(echo "$instances" | fzf --prompt="Select EC2 instance: " --height=10)
    
    if [[ -z "$selected_instance" ]]; then
        echo -e "${_AWS_RED}No instance selected.${_AWS_NC}"
        return 1
    fi
    
    echo -e "${_AWS_BOLD}${_AWS_GREEN}Selected resource: ${_AWS_WHITE}$selected_instance${_AWS_NC}"

    # Get instance details - check if it's a name or instance ID
    local instance_info
    if [[ $selected_instance == i-* ]]; then
        # It's an instance ID
        instance_info=$(aws ec2 describe-instances --instance-ids "$selected_instance" --query 'Reservations[0].Instances[0].[PrivateIpAddress,PublicIpAddress,KeyName,Tags[?Key==`Name`].Value | [0]]' --output text)
    else
        # It's a name tag, find by name
        instance_info=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$selected_instance" --query 'Reservations[0].Instances[0].[PrivateIpAddress,PublicIpAddress,KeyName,InstanceId]' --output text)
    fi

    local private_ip public_ip key_name instance_id
    read -r private_ip public_ip key_name instance_id <<<"$instance_info"

    echo -e "${_AWS_BOLD}${_AWS_PURPLE}Private IP: ${_AWS_WHITE}$private_ip${_AWS_NC}"
    if [ "$public_ip" != "None" ] && [ -n "$public_ip" ]; then
        echo -e "${_AWS_BOLD}${_AWS_PURPLE}Public IP: ${_AWS_WHITE}$public_ip${_AWS_NC}"
    fi

    # Generate SSH connection strings
    echo ""
    echo -e "${_AWS_BOLD}${_AWS_CYAN}SSH connections:${_AWS_NC}"
    if [ "$public_ip" != "None" ] && [ -n "$public_ip" ]; then
        echo -e "  ${_AWS_BOLD}${_AWS_GREEN}ssh -i ~/.ssh/${_AWS_RED}<KEY>${_AWS_GREEN} ${_AWS_RED}<USER>${_AWS_GREEN}@$public_ip${_AWS_NC}"
    fi
    echo -e "  ${_AWS_BOLD}${_AWS_GREEN}ssh -i ~/.ssh/${_AWS_RED}<KEY>${_AWS_GREEN} ${_AWS_RED}<USER>${_AWS_GREEN}@$private_ip${_AWS_NC}"

    # Show common users and key info
    echo ""
    echo -e "${_AWS_BOLD}${_AWS_CYAN}Common users:${_AWS_NC}"
    echo -e "  ${_AWS_YELLOW}- ec2-user ${_AWS_WHITE}(Amazon Linux, RHEL)${_AWS_NC}"
    echo -e "  ${_AWS_YELLOW}- ubuntu ${_AWS_WHITE}(Ubuntu)${_AWS_NC}"
    echo -e "  ${_AWS_YELLOW}- admin ${_AWS_WHITE}(Debian)${_AWS_NC}"
    echo -e "  ${_AWS_YELLOW}- centos ${_AWS_WHITE}(CentOS)${_AWS_NC}"

    if [ "$key_name" != "None" ] && [ -n "$key_name" ]; then
        echo ""
        echo -e "${_AWS_BOLD}${_AWS_PURPLE}Key pair: ${_AWS_WHITE}$key_name${_AWS_NC}"
        echo -e "${_AWS_YELLOW}Make sure your private key is at: ${_AWS_WHITE}~/.ssh/$key_name.pem${_AWS_NC}"
    fi
}

# Handle EKS cluster discovery
_awsf_cluster() {
    echo -e "${_AWS_YELLOW}Fetching EKS clusters...${_AWS_NC}"
    local clusters=$(aws eks list-clusters --query 'clusters[]' --output text | tr '\t' '\n')
    
    if [[ -z "$clusters" ]]; then
        echo -e "${_AWS_RED}No EKS clusters found in this region.${_AWS_NC}"
        return 1
    fi
    
    local selected_cluster=$(echo "$clusters" | fzf --prompt="Select EKS cluster: " --height=10)
    
    if [[ -z "$selected_cluster" ]]; then
        echo -e "${_AWS_RED}No cluster selected.${_AWS_NC}"
        return 1
    fi
    
    echo -e "${_AWS_BOLD}${_AWS_GREEN}Selected resource: ${_AWS_WHITE}$selected_cluster${_AWS_NC}"

    # Get cluster details
    local cluster_info=$(aws eks describe-cluster --name "$selected_cluster" --query 'cluster.[endpoint,status,version,platformVersion,resourcesVpcConfig.vpcId]' --output text)
    local endpoint status version platform_version vpc_id
    read -r endpoint status version platform_version vpc_id <<<"$cluster_info"

    # Extract the API server hostname for private IP lookup
    local hostname=$(echo "$endpoint" | sed 's|https://||' | cut -d'.' -f1)
    local region=$(aws configure get region 2>/dev/null || echo "us-east-1")

    # Get private IP from EKS network interfaces
    local private_ip=$(aws ec2 describe-network-interfaces --filters "Name=description,Values=*EKS*" "Name=vpc-id,Values=$vpc_id" --query 'NetworkInterfaces[0].PrivateIpAddress' --output text)

    echo -e "${_AWS_BOLD}${_AWS_PURPLE}Endpoint: ${_AWS_WHITE}$endpoint${_AWS_NC}"
    echo -e "${_AWS_BOLD}${_AWS_PURPLE}Status: ${_AWS_WHITE}$status${_AWS_NC}"
    echo -e "${_AWS_BOLD}${_AWS_PURPLE}Version: ${_AWS_WHITE}$version${_AWS_NC}"
    echo -e "${_AWS_BOLD}${_AWS_PURPLE}Private IP: ${_AWS_WHITE}$private_ip${_AWS_NC}"

    # Generate kubeconfig commands
    echo ""
    echo -e "${_AWS_BOLD}${_AWS_CYAN}Add to kubeconfig:${_AWS_NC}"
    echo -e "  ${_AWS_BOLD}${_AWS_GREEN}aws eks update-kubeconfig --region $region --name $selected_cluster${_AWS_NC}"

    echo ""
    echo -e "${_AWS_BOLD}${_AWS_CYAN}Update kubeconfig to use private IP instead of DNS:${_AWS_NC}"
    echo -e "  ${_AWS_BOLD}${_AWS_GREEN}kubectl config set-cluster arn:aws:eks:$region:*:cluster/$selected_cluster --server=https://$private_ip${_AWS_NC}"

    echo ""
    echo -e "${_AWS_BOLD}${_AWS_CYAN}Verify connection:${_AWS_NC}"
    echo -e "  ${_AWS_BOLD}${_AWS_GREEN}kubectl get nodes${_AWS_NC}"
    echo -e "  ${_AWS_BOLD}${_AWS_GREEN}kubectl get pods --all-namespaces${_AWS_NC}"

    echo ""
    echo -e "${_AWS_BOLD}${_AWS_CYAN}Cluster info:${_AWS_NC}"
    echo -e "  ${_AWS_BOLD}${_AWS_GREEN}kubectl cluster-info${_AWS_NC}"
    echo -e "  ${_AWS_BOLD}${_AWS_GREEN}kubectl config current-context${_AWS_NC}"

    echo ""
    echo -e "${_AWS_YELLOW}Note: EKS clusters use private endpoints within the VPC${_AWS_NC}"
    echo -e "${_AWS_YELLOW}Make sure you have network access to the VPC (via VPN, bastion, etc.)${_AWS_NC}"
}