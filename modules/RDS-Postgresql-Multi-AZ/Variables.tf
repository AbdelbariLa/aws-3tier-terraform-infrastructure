variable "Compagne_Name" {
   default = ""
}

variable "Environment" {
   default = ""
}

variable "DB_Name" {
}

variable "DB_username" {
}

variable "availability_zones" {
   type = list(string)
}

variable "DB_password" {
  sensitive = true
}

variable "DB_backup_retention_period" {
   default = 5
}

variable "preferred_backup_window" {
  default = "07:00-09:00"
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
}