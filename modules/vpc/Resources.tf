
# =====================================================
# Locals Variables
locals {
  # lower characters , and remove spaces
  Compagne_Name = lower(trimspace(var.Compagne_Name))
  Environment = lower(trimspace(var.Environment))
  VPC_Name = lower(trimspace(var.VPC_Name))
  ManagedBy = "terraform"
}


# =====================================================
# The main Vpc 
resource "aws_vpc" "main" {
  cidr_block = var.VPC_CIDR
  tags = {
    Name = local.VPC_Name
    Compagne = local.Compagne_Name
    Environment = local.Environment
    ManagedBy = local.ManagedBy
  }
}

# =====================================================
# Private Subnets :
resource "aws_subnet" "Private_Subnets" {
  count = length(var.Private_Subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.Private_Subnets[count.index].cidr
  availability_zone = var.Private_Subnets[count.index].az
  tags = {
    Name = "private_subnet_${count.index}"
    Compagne_Name = local.Compagne_Name
    Environment = local.Environment
    ManagedBy = local.ManagedBy
  }
}

# =====================================================
# Public Subnets :
resource "aws_subnet" "Public_Subnets" {
  count = length(var.Public_Subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.Public_Subnets[count.index].cidr
  availability_zone = var.Public_Subnets[count.index].az
  tags = {
    Name = "public_subnet_${count.index}"
    Compagne_Name = local.Compagne_Name
    Environment = local.Environment
    ManagedBy = local.ManagedBy
  }
}

# ======================================================
# Private && Nat Rout Table ======================
resource "aws_route_table_association" "Private_rout_table_association" {
  count = length(aws_subnet.Private_Subnets)
  subnet_id      = aws_subnet.Private_Subnets[count.index].id
  route_table_id = var.Private_Subnets[count.index].use_nat_gwy == true ? aws_route_table.NateGWY_rout_table.id : aws_route_table.Private_rout_table.id
}

resource "aws_route_table" "Private_rout_table" {
  vpc_id = aws_vpc.main.id
  # local forwarding is automatic
  tags = {
    Name = "Private_rout_table"
    Compagne_Name = local.Compagne_Name
    Environment = local.Environment
    ManagedBy = local.ManagedBy
  }
}

resource "aws_route_table" "NateGWY_rout_table" {
  vpc_id = aws_vpc.main.id
  # local forwarding is automatic
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat_gwy.id
  }
  tags = {
    Name = "NateGWY_rout_table"
    Compagne_Name = local.Compagne_Name
    Environment = local.Environment
    ManagedBy = local.ManagedBy
  }
}

# Nat Gwy ======================
resource "aws_eip" "Nat_gwy_ip" {
  domain   = "vpc"
}
resource "aws_nat_gateway" "Nat_gwy" { 
  allocation_id = aws_eip.Nat_gwy_ip.id
  subnet_id     = aws_subnet.Public_Subnets[0].id

  tags = {
    Name = "${local.VPC_Name}-Nat_GWY"
    Compagne_Name = local.Compagne_Name
    Environment = local.Environment
    ManagedBy = local.ManagedBy
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}


# ======================================================
# public Rout Table ======================
resource "aws_route_table_association" "Public_rout_table_association" {
  count = length(aws_subnet.Public_Subnets)
  subnet_id      = aws_subnet.Public_Subnets[count.index].id
  route_table_id = aws_route_table.Public_rout_table.id
}
resource "aws_route_table" "Public_rout_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  # local forwarding is automatic
  tags = {
    Name = "Public_rout_table"
    Compagne_Name = local.Compagne_Name
    Environment = local.Environment
    ManagedBy = local.ManagedBy
  }
}
# Internet Gwy ======================
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW"
    Compagne_Name = local.Compagne_Name
    Environment = local.Environment
    ManagedBy = local.ManagedBy
  }
}