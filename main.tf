locals {
  ecr_repo_name = "${var.use_namespaces ? "${var.namespace}-${var.name}" : "${var.name}"}"
}

# aws_ecr_repository creates the aws_ecr_repository resource
resource "aws_ecr_repository" "this" {
  count = "${var.create ? 1 : 0 }"
  name  = "${local.ecr_repo_name}"
}

# ecs_ecr_read_perms defines the regular read and login perms for principals defined in var.allowed_read_principals
data "aws_iam_policy_document" "ecs_ecr_read_perms" {
  count = "${var.create ? 1 : 0 }"

  statement {
    sid = "ECRREad"

    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
    ]

    principals {
      identifiers = ["${var.allowed_read_principals}"]
      type        = "AWS"
    }
  }
}

# ecr_read_and_write_perms defines the ecr_read_and_write_perms for principals defined in var.allowed_write_principals
data "aws_iam_policy_document" "ecr_read_and_write_perms" {
  count = "${var.create ? 1 : 0 }"

  # The previously created ecs_ecr_read_perms will be merged into this document.
  source_json = "${data.aws_iam_policy_document.ecs_ecr_read_perms.json}"

  statement {
    sid = "ECRWrite"

    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
    ]

    principals {
      identifiers = ["${var.allowed_write_principals}"]
      type        = "AWS"
    }
  }
}

# aws_ecr_repository_policy defines the policy for the ECR repository
# when var.allowed_write_principals contains no principals, only the data.aws_iam_policy_document.ecs_ecr_read_perms.json will
# be used to populate the iam policy.
resource "aws_ecr_repository_policy" "this" {
  count      = "${var.create ? 1 : 0 }"
  repository = "${aws_ecr_repository.this.name}"

  policy = "${length(var.allowed_write_principals) > 0
              ? data.aws_iam_policy_document.ecr_read_and_write_perms.json
              : data.aws_iam_policy_document.ecs_ecr_read_perms.json}"
}

# aws_ecr_lifecycle_policy_rule is used as template for a rule of the lifecycle policy
locals {
  aws_ecr_lifecycle_policy_rule = {
    rulePriority = "$${priority}"
    description  = "Rotate images after amount of: $${max_image_count} is reached for prefix $${prefix}"

    selection = {
      tagStatus     = "tagged"
      tagPrefixList = ["$${prefix}"]
      countType     = "imageCountMoreThan"
      countNumber   = "$${max_image_count}"
    }

    action = {
      type = "expire"
    }
  }
}

# Create a policy rule per stage
# The jsonencoded aws_ecr_lifecycle_policy_rule will be used as template, the variables will be replaced
# A policy will be made per available prefix
data "template_file" "lifecycle_policy" {
  count = "${(var.create ? 1 : 0 ) * length(var.prefixes)}"

  template = "${jsonencode(local.aws_ecr_lifecycle_policy_rule)}"

  vars {
    priority = "${count.index + 1}"
    prefix   = "${var.prefixes[count.index]}"

    # If there is no count defined in the map var.prefixes_pecific_max_count, we take the var.default_max_image_count
    max_image_count = "${lookup(var.prefixes_specific_max_count,var.prefixes[count.index], var.default_max_image_count)}"
  }
}

# The final rendered lifecycle_policy will be regexed to remove the double quotes surrounding strings
resource "aws_ecr_lifecycle_policy" "this" {
  count      = "${var.create ? 1 : 0 }"
  repository = "${aws_ecr_repository.this.name}"

  policy = "${replace(
               replace("{\"rules\": [${join(",",data.template_file.lifecycle_policy.*.rendered)}]}",
		 "/\"(true|false|[[:digit:]]+)\"/", "$1"
	), "string:", ""
      )}"
}
