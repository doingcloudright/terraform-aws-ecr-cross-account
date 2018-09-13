# AWS ECR Module  [![Build Status](https://travis-ci.org/doingcloudright/terraform-aws-ecr-cross-account.svg?branch=master)](https://travis-ci.org/doingcloudright/terraform-aws-ecr-cross-account)


This module simplifies the creation of an ECR Bucket which serves different AWS Accounts and different stages of development. The lifecycle policy rules can be passed as list of strings inside lifecycle_policy_rules. For generation of lifecycle policy rules please check out <a href="https://registry.terraform.io/modules/doingcloudright/ecr-lifecycle-policy-rule/aws/">doingcloudright/ecr-lifecycle-policy-rule/aws</a>.

The list allowed_read_principals is mandatory and defines which principals have read access to the repository. allowed_write_principals could define a principle which has write (&read) access to the repository e.g. the CICD user.


_NOTE_ ECR Resource Level policies give certain arns specific access to the Repository configured. However, a minimal IAM policy for the specific role/user is needed to give it the access to ECR.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

## Examples

### Repo with rotating images after count of 30 for prefix test,uat and prod, and rotage images for untagged after 100 days
```
module "ecr_lifecycle_rule_tagged_image_count_30" {
  source = "doingcloudright/ecr-lifecycle-policy-rule/aws"
  version = "0.0.4"

  tag_status = "tagged"
  count_type = "imageCountMoreThan"
  prefixes  = ["test","uat","prod"]
  count_number = 30
}

module "ecr_lifecycle_rule_untagged_100_days_since_image_pushed" {
  source = "doingcloudright/ecr-lifecycle-policy-rule/aws"
  version = "0.0.4"

  tag_status = "untagged"
  count_type = "sinceImagePushed"
  count_number = "100"
}

module "ecr_repo_with_namespaces" {
    source                      = "doingcloudright/ecr-cross-account/aws"
    version                     = "0.1.4"

    namespace                   = "dcr"
    name                        = "repo"

    allowed_read_principals     = ["arn:aws:iam::1234567890:root"]
    allowed_write_principals    = ["arn:aws:iam::1234567890:user/ecs-deploy"]

    lifecycle_policy_rules    = ["${module.ecr_lifecycle_rule_tagged_image_count_30.policy_rule}","${module.ecr_lifecycle_rule_untagged_100_days_since_image_pushed.policy_rule}" ]
    lifecycle_policy_rules_count = 2
}
```


### Repo using namespaces by default, will be named dcr-repo
```
module "ecr_repo_with_namespaces" {
    source                      = "doingcloudright/ecr-cross-account/aws"
    version                     = "0.1.4"

    namespace                   = "dcr"
    name                        = "repo"

    allowed_read_principals     = ["arn:aws:iam::1234567890:root"]
    allowed_write_principals    = ["arn:aws:iam::1234567890:user/ecs-deploy"]

    # lifecycle_policy_rules    = []
    # lifecycle_policy_rules_count = 0
}
```

### Repo will be named repo with use_namespaces is set to false
```
module "ecr_repo_no_namespaces" {
    source                      = "doingcloudright/ecr-cross-account/aws"
    version                     = "0.1.4"

    namespace                   = "dcr"
    use_namespaces		= false
    name                        = "repo"

    allowed_read_principals     = ["arn:aws:iam::1234567890:root"]
    allowed_write_principals    = ["arn:aws:iam::1234567890:user/ecs-deploy"]

    # lifecycle_policy_rules    = []
    # lifecycle_policy_rules_count = 0
}
```
