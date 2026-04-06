locals {
  name_prefix = "lab"

  vnet_name = "${local.name_prefix}-vnet"

  subnets = {
    for k, v in var.subnets :
    k => {
      name = "${local.name_prefix}-subnet-${k}"
      cidr = v.cidr
      type = v.type
    }
  }

  public_subnets = {
    for k, v in local.subnets : k => v
    if v.type == "public"
  }

  private_subnets = {
    for k, v in local.subnets : k => v
    if v.type == "private"
  }

  nat_gateway_name   = "${local.name_prefix}-nat-gw"
  nat_public_ip_name = "${local.name_prefix}-nat-pip"
}
