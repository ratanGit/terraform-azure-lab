locals {
  ###############################################################################
  # IDENTITY & PROJECT METADATA
  # Defines the naming convention and global tagging strategy.
  ###############################################################################
  environment  = var.environment

# 1. Author Logic
  # If var.author is "ratan mohapatra", this gets "ratan"
  first_name = lower(split(" ", trimspace(var.author))[0])

  # 2. Project Logic (The Safety Fix)
  # We check if there is a space. If yes, take the second word. If no, use the whole thing.
  project_raw   = contains(split(" ", var.project), " ") ? split(" ", var.project)[1] : var.project
  project_short = lower(substr(local.project_raw, 0, 4))

  # 3. Name Prefix: "ratan-guac"
  name_prefix = "${local.first_name}-${local.project_short}"

  # 4. Tags and Naming
  common_tags = {
    Project     = var.project
    Owner       = var.author
    Environment = var.environment # Fixed the "nt" typo here
    Purpose     = "Remote-Access-Gateway"
    ManagedBy   = "Terraform"
    Location    = "Ottawa"  
  }

  # Fixed the "primitive-typed value" error
  # Since name_prefix is a local, call it directly:

  

###############################################################################
# NETWORK ABSTRACTION & FLATTENING
###############################################################################

  vnet_name = "${local.name_prefix}-vnet"

  # Derive enriched subnet objects from simple CIDR map
  subnets = {
    for subnet_type, cidr in var.vnet_cidr["Lab"].subnets :
    subnet_type => {
      name = "${local.name_prefix}-snet-${subnet_type}"
      cidr = cidr
      type = subnet_type
    }
  }

  # Classify subnets
  public_subnets = {
    for k, v in local.subnets : k => v if v.type == "public"
  }

  private_subnets = {
    for k, v in local.subnets : k => v if v.type == "private"
  }
  nat_gateway_name   = "${local.name_prefix}-nat-gw"
  nat_public_ip_name = "${local.name_prefix}-nat-pip"
}