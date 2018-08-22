output "repository_arn" {
  value       = "${element(concat(aws_ecr_repository.this.*.arn, list("")), 0)}"
  description = "Repository ARN"
}

output "repository_name" {
  value       = "${element(concat(aws_ecr_repository.this.*.name, list("")), 0)}"
  description = "Repository name"
}

output "registry_id" {
  value       = "${element(concat(aws_ecr_repository.this.*.registry_id, list("")), 0)}"
  description = "Registry ID"
}

output "registry_url" {
  value       = "${element(concat(aws_ecr_repository.this.*.repository_url, list("")), 0)}"
  description = "Registry URL"
}
