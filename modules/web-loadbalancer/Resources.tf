# =====================================================
# Locals Variables
locals {
  # lower characters , and remove spaces
  Compagne_Name = lower(trimspace(var.Compagne_Name))
  Environment = lower(trimspace(var.Environment))
  LoadBalancerName = lower(trimspace(var.LoadBalancerName))
  ManagedBy = "terraform"
  
  Attachments = flatten([
    for tg_idx, rule in var.Forwarding_Traffic : [
      for inst_idx, inst_id in rule.Instances_ids : {
        key         = "${tg_idx}-${inst_idx}"
        tg_idx      = tg_idx
        instance_id = inst_id
        port        = rule.forward_port
      }
    ]
  ])
}

# =====================================================
# Load Balancer
resource "aws_lb" "Load_balancer" {
  name               = local.LoadBalancerName
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.SG_id
  subnets            = var.Subnets_ids

  tags = {
    Name = local.LoadBalancerName
    Compagne = local.Compagne_Name
    Environment = local.Environment
    ManagedBy = local.ManagedBy
  }
}

# =====================================================
# Forwarding Traffic
resource "aws_lb_listener" "listener" {
  count = length(var.Forwarding_Traffic)
  load_balancer_arn = aws_lb.Load_balancer.arn
  port              = var.Forwarding_Traffic[count.index].listener_port
  protocol          = var.Forwarding_Traffic[count.index].protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[count.index].arn
  }
}

resource "aws_lb_target_group" "target_group" {
  count = length(var.Forwarding_Traffic)
  name_prefix     = "tg-${count.index}"
  port     = var.Forwarding_Traffic[count.index].forward_port
  protocol = var.Forwarding_Traffic[count.index].protocol
  vpc_id   = var.VPC_id
  health_check {
    enabled = true  
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "bridge" {
  for_each = {for a in local.Attachments : a.key => a}
  target_group_arn = aws_lb_target_group.target_group[each.value.tg_idx].arn
  target_id        = each.value.instance_id
  port             = each.value.port
}