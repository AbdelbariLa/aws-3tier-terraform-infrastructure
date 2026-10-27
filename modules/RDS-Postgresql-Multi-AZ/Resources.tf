# =====================================================
# Locals Variables
locals {
  # lower characters , and remove spaces
  Compagne_Name = lower(trimspace(var.Compagne_Name))
  Environment = lower(trimspace(var.Environment))
  RDS_Name = lower(trimspace(var.DB_Name))
  ManagedBy = "terraform"
}

# =====================================================
resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-postgresql"
  availability_zones      = var.availability_zones
  database_name           = var.DB_Name
  master_username         = var.DB_username
  master_password         = var.DB_password
  backup_retention_period = var.DB_backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name = aws_db_subnet_group.this.name
  

  tags = {
    Environment = local.Environment
    RDS_Name = local.RDS_Name
    ManagedBy = local.ManagedBy
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.RDS_Name}-subnet-group"
  subnet_ids = var.subnet_ids
}
