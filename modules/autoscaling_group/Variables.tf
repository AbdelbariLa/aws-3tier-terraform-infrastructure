variable "Compagne_Name" {
   default = ""
}

variable "Environment" {
   default = ""
}

variable "autoscaling_group_Name" {
}

variable "MaxSize" {
}

variable "MinSize" {
}

variable "DesiredCapacity" {
}

variable "health_check_type" {
  default = "ELB"
}

variable "Subnets_ids" {
  type = list(string)
}

variable "Image_ID" { 
}

variable "instance_type" {
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arns" {
  
}

variable "user_data" {
  
}