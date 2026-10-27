# =====================================================
# Locals Variables
locals {
  # lower characters , and remove spaces
  Compagne_Name = lower(trimspace(var.Compagne_Name))
  Environment = lower(trimspace(var.Environment))
  Instance_Name = lower(trimspace(var.Instance_Name))
  ManagedBy = "terraform"
}

# =====================================================
#  Instance
resource "aws_instance" "Instance" {
  ami           = var.ami_id == "" ? data.aws_ami.ubuntu.id : var.ami_id
  instance_type = var.Instance_Type
  subnet_id = var.subnet_id
  user_data = var.user_data == "" ?  null : var.user_data
  vpc_security_group_ids = var.sg_ids
  root_block_device {
    encrypted = true
    volume_size = var.Root_Storage_Size
  }
  tags = {
    Name = local.Instance_Name
    Compagne = local.Compagne_Name
    Environment = local.Environment
    ManagedBy = local.ManagedBy
  }
}