locals {
  Compagne_Name = "ABDELBARI"
  Environment   = "dev"
  LB_Forwarding_Traffic = [
    # { listener_port = "80", forward_port = "80", protocol = "HTTP", Instances_ids =  module.Instances_module[*].Instance_id }
      { listener_port = "80", forward_port = "80", protocol = "HTTP", Instances_ids =  []}
  ]
}

# ===============================================
# Ec2 Resources

# module "Instances_module" {
#   source        = "../../modules/ec2"
#   count         = var.NodesCount
#   Compagne_Name = local.Compagne_Name
#   Environment   = local.Environment
#   Instance_Name = "app_tier_node_${count.index}"
#   Instance_Type = var.instance_types[terraform.workspace]
#   subnet_id     = module.vpc_module.Private_Subnets_IDS[count.index]
#   user_data     = file("${path.module}/user_data/Server${count.index + 1}.sc")
#   sg_ids        = [module.Instances_SG.SG_ID]
# }

module "Autoscaling_Group_module" {
  source = "../../modules/autoscaling_group"
  autoscaling_group_Name = "asg"
  Compagne_Name = local.Compagne_Name
  Environment = local.Environment
  DesiredCapacity = 3
  MaxSize = 5
  MinSize = 3
  Image_ID = data.aws_ami.ubuntu.id
  Subnets_ids = module.vpc_module.Private_Subnets_IDS
  security_group_ids = [module.Instances_SG.SG_ID]
  instance_type = var.instance_types[terraform.workspace]
  target_group_arns = module.Load_balancer.target_group_arns
  user_data = file("${path.module}/user_data/Server1.sc")
}

# ===============================================
# Traffic
module "Load_balancer" {
  source             = "../../modules/web-loadbalancer"
  Compagne_Name      = local.Compagne_Name
  Environment        = local.Environment
  LoadBalancerName   = "main-dev-loadbalancer"
  VPC_id             = module.vpc_module.VPC_id
  SG_id              = [module.Load_balancer_SG.SG_ID]
  Subnets_ids        = module.vpc_module.Public_Subnets_IDS
  Forwarding_Traffic = local.LB_Forwarding_Traffic
}

resource "local_file" "DNS" {
  content = module.Load_balancer.DNS_LB
  filename = "${path.module}/Outputs/lb_url.txt"
}

# ===============================================
# Database
module "RDS-Postgresql-Multi-Az" {
  source = "../../modules/RDS-Postgresql-Multi-AZ"
  Compagne_Name = local.Compagne_Name
  Environment = local.Environment
  DB_Name = "mainDb"
  DB_username = "mainDb"
  DB_password = file("${path.module}/Secrets/mainDB.Password.txt")
  availability_zones = var.RDS_AZs
  security_group_ids = [module.mainDB_SG.SG_ID]
  subnet_ids = module.vpc_module.Private_Subnets_IDS
}

# ===============================================
# Networking & Security
module "vpc_module" {
  source          = "../../modules/vpc"
  Compagne_Name   = local.Compagne_Name
  Environment     = local.Environment
  VPC_Name        = "main-dev-vpc"
  Private_Subnets = var.Private_Subnets
  Public_Subnets  = var.Public_Subnets
  VPC_CIDR = "10.0.0.0/16"
}

module "Instances_SG" {
  source        = "../../modules/sg"
  Compagne_Name = local.Compagne_Name
  Environment   = local.Environment
  SG_Name       = "main-dev-WebSG"
  Inbound = [
    { sg_source = module.Load_balancer_SG.SG_ID, port = "80", ip_protocol = "tcp" }
  ]
  Outbound = [{ cidr_block = "0.0.0.0/0", ip_protocol = "-1" }]
  VPC_id   = module.vpc_module.VPC_id
}

module "Load_balancer_SG" {
  source        = "../../modules/sg"
  Compagne_Name = local.Compagne_Name
  Environment   = local.Environment
  SG_Name       = "main-dev-lbSG"
  Inbound       = [{ cidr_block = "0.0.0.0/0", port = "80", ip_protocol = "tcp" }]
  Outbound      = [{ cidr_block = "0.0.0.0/0", ip_protocol = "-1" }]
  VPC_id        = module.vpc_module.VPC_id
}

module "mainDB_SG" {
  source        = "../../modules/sg"
  Compagne_Name = local.Compagne_Name
  Environment   = local.Environment
  SG_Name       = "main-dev-mainDBSG"
  Inbound = [
    { sg_source = module.Instances_SG.SG_ID, port = "5432", ip_protocol = "tcp" }
  ]
  Outbound = [{ cidr_block = "0.0.0.0/0", ip_protocol = "-1" }]
  VPC_id   = module.vpc_module.VPC_id
}