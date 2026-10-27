variable "Compagne_Name" {
   default = ""
}

variable "Environment" {
   default = ""
}

variable "VPC_Name" {
}

variable "VPC_CIDR" {
  default = "10.0.0.0/16"
}

variable "Public_Subnets" {
  type = list(object({
    az = string
    cidr = string
  }))

  default = [
    {az = "us-east-1a" , cidr = "10.0.10.0/24"},
    {az = "us-east-1b" , cidr = "10.0.20.0/24"}]
}

variable "Private_Subnets" {
  type = list(object({
    az = string
    cidr = string
    use_nat_gwy = bool
  }))

  default = [
    {az = "us-east-1a" , cidr = "10.0.100.0/24" , use_nat_gwy = true},
    {az = "us-east-1b" , cidr = "10.0.200.0/24" , use_nat_gwy = true}]
}