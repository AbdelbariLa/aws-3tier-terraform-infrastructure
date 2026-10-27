variable "Compagne_Name" {
   default = ""
}

variable "Environment" {
   default = ""
}

variable "Instance_Name" {
}

variable "Instance_Type" {
  default = "t3.micro"
}

variable "ami_id" {
    default = ""
}

variable "Root_Storage_Size" {
    type = number
    description = "get the storage in GB"
    default = 10
}

variable "user_data" {
    default = ""
}

variable "subnet_id" {
  
}

variable "sg_ids" {
  type = list(string)
}