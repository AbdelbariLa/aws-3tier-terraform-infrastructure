# =====================================================
# Locals Variables
locals {
  # lower characters , and remove spaces
  Compagne_Name = lower(trimspace(var.Compagne_Name))
  Environment = lower(trimspace(var.Environment))
  autoscaling_group_Name = substr(lower(trimspace(var.autoscaling_group_Name)),0,6)
  instance_Name = "${substr(local.autoscaling_group_Name,0,3)}ec2"
  ManagedBy = "terraform"
}

# =====================================================

resource "aws_autoscaling_group" "autoscaling" {
  name_prefix = local.autoscaling_group_Name
  max_size                  = var.MaxSize
  min_size                  = var.MinSize
  health_check_grace_period = 300
  health_check_type         = var.health_check_type
  desired_capacity          = var.DesiredCapacity
  force_delete              = true
  launch_template {
     id = aws_launch_template.template.id
     version = "$Latest"
  }
  vpc_zone_identifier       = var.Subnets_ids
  target_group_arns = var.target_group_arns
}

resource "aws_launch_template" "template" {
  name_prefix   = local.instance_Name
  image_id      = var.Image_ID
  instance_type = var.instance_type
  vpc_security_group_ids = var.security_group_ids
  user_data = base64encode(var.user_data)

  tags = {
    Compagne_Name = local.Compagne_Name
    Environment = local.Environment
    name = local.instance_Name
  }
} 