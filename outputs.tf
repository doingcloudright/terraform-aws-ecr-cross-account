output "registry_id" {
  value       = "${element(concat(aws_ecr_repository.this.*.registry_id, list("")), 0)}"
  description = "Registry id"
}

output "repository_name" {
  value       = "${element(concat(aws_ecr_repository.this.*.name, list("")), 0)}"
  description = "Registry name"
}

output "registry_url" {
  value       = "${element(concat(aws_ecr_repository.this.*.repository_url, list("")), 0)}"
  description = "Registry url"
}
