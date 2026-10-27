variable "aws_profile" {
  default = "default"
}

variable "aws_region" {
  default = "eu-central-1"
}

# the instance type for each workspace
variable "instance_types" {
  default = {
    "default" = "t3.micro" # default is dev mode
    "prod"    = "t3.medium"
  }
}

variable "NodesCount" {
  default = "2"
}


variable "Public_Subnets" {
  type = list(object({
    az   = string
    cidr = string
  }))

  default = [
    { az = "eu-central-1a", cidr = "10.0.10.0/24" },
  { az = "eu-central-1b", cidr = "10.0.20.0/24" }]
}

variable "Private_Subnets" {
  type = list(object({
    az          = string
    cidr        = string
    use_nat_gwy = bool
  }))

  default = [
    { az = "eu-central-1a", cidr = "10.0.100.0/24", use_nat_gwy = true },
    { az = "eu-central-1b", cidr = "10.0.200.0/24", use_nat_gwy = true },
  { az = "eu-central-1c", cidr = "10.0.201.0/24", use_nat_gwy = true }]
}

variable "RDS_AZs" {
  default = [
    "eu-central-1a","eu-central-1b","eu-central-1c"
  ]
}