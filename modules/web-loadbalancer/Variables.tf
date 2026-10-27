variable "Compagne_Name" {
   default = ""
}

variable "Environment" {
   default = ""
}

variable "LoadBalancerName" {
}

variable "VPC_id" {
}

variable "SG_id" {
  type = list(string)
}

variable "Subnets_ids" {
  type = list(string)
}

variable "Forwarding_Traffic" {
  type = list(object({
    listener_port = string , forward_port = string , protocol = string, Instances_ids = list(string)
  }))
}