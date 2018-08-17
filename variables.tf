# The namespace we interpolate in all resources
variable "namespace" {}

# if with_namespace is false we don't interpolate it..
variable "use_namespaces" {
  default = true
}

# The name of the ECR repository
variable "name" {}

# default_max_image_count defines the default maximum image count after which images needs to rotate
variable "default_max_image_count" {
  default = "100"
}

# prefixes_pecific_max_count defines the map of stages when the default_max_image_count is not
# the right setting
# example
# { 
#  dev = 40
#  prod = 100
# }
variable "prefixes_specific_max_count" {
  default = {}
}

# create defines if resources need to be created true/false
variable "create" {
  default = true
}

# allowed_principals defines which external principals are allowed to the ECR repository
variable "allowed_read_principals" {
  type = "list"
}

variable "allowed_write_principals" {
  type    = "list"
  default = []
}

# prefixes define which prefixes need to have separate rules applied
variable "prefixes" {
  default = []
}
