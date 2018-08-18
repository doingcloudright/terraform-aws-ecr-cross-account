variable "namespace" {
  description = "The namespace we interpolate in all resources"
}

variable "use_namespaces" {
  description = "use_namespaces defines if we want to interpolate the namespace inside the repo name"
  default     = true
}

# The name of the ECR repository
variable "name" {
  description = "name defines the name of the repository, by default it will be interpolated to {namespace}-{name}"
}

variable "default_max_image_count" {
  description = "default_max_image_count defines the default maximum image count after which images needs to rotate"
  default     = "100"
}

# prefixes_pecific_max_count defines the map of stages when the default_max_image_count is not
# the right setting
# example
# { 
#  dev = 40
#  prod = 100
# }
variable "prefixes_specific_max_count" {
  description = "prefixes_specific_max_count defines the map of stages when the default_max_image_count is not the preferred count for a specific prefix"
  default     = {}
}

variable "create" {
  description = "create defines if resources need to be created true/false"
  default     = true
}

variable "allowed_read_principals" {
  description = "allowed_read_principals defines which external principals are allowed to read from the ECR repository"
  type        = "list"
}

variable "allowed_write_principals" {
  description = "allowed_write_principals defines which external principals are allowed to write to the ECR repository"
  type        = "list"
  default     = []
}

variable "prefixes" {
  description = "prefixes define which prefixes need to have lifecycle rules applied"
  default     = []
}
