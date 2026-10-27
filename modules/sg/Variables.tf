variable "Compagne_Name" {
   default = ""
}

variable "Environment" {
   default = ""
}

variable "SG_Name" {
}

variable "VPC_id" {
  
}

variable "Inbound" {
  type = list(object({
    cidr_block = optional(string) ,  ip_protocol = string , port = string , sg_source = optional(string)
  }))

  validation {
    condition = alltrue([
      for r in var.Inbound : r.cidr_block != null || r.sg_source != null
    ])
    error_message = "Each rule must define at least one of cidr_block or sg_source."
  }
}

variable "Outbound" {
  type = list(object({
    cidr_block = string ,  ip_protocol = string
  }))
}