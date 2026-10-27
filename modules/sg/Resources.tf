# =====================================================
# Locals Variables
locals {
  # lower characters , and remove spaces
  Compagne_Name = lower(trimspace(var.Compagne_Name))
  Environment = lower(trimspace(var.Environment))
  SG_Name = lower(trimspace(var.SG_Name))
  ManagedBy = "terraform"
}

# =====================================================
#  Security Group
resource "aws_security_group" "SG" {
  name        = local.SG_Name
  vpc_id      = var.VPC_id

  tags = {
    Name = local.SG_Name
    Environment = local.Environment
    Compagne_Name = local.Compagne_Name
    ManagedBy = local.ManagedBy
  }
}

resource "aws_vpc_security_group_ingress_rule" "Inbound_Rules" {
  security_group_id = aws_security_group.SG.id
  count = length(var.Inbound)

  referenced_security_group_id = var.Inbound[count.index].sg_source
  cidr_ipv4         = var.Inbound[count.index].sg_source == null ? var.Inbound[count.index].cidr_block : null

  from_port         = var.Inbound[count.index].port
  to_port           = var.Inbound[count.index].port
  ip_protocol       = var.Inbound[count.index].ip_protocol
  tags = {
    Name = "${local.SG_Name}_ingress_${count.index}"
    Environment = local.Environment
    Compagne_Name = local.Compagne_Name
    ManagedBy = local.ManagedBy
  }
}


resource "aws_vpc_security_group_egress_rule" "Outbound_Rules" {
  security_group_id = aws_security_group.SG.id
  count = length(var.Outbound)
  cidr_ipv4         = var.Outbound[count.index].cidr_block
  ip_protocol       = var.Outbound[count.index].ip_protocol
  tags = {
    Name = "${local.SG_Name}_egress_${count.index}"
    Environment = local.Environment
    Compagne_Name = local.Compagne_Name
    ManagedBy = local.ManagedBy
  }
}