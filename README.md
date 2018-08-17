# AWS ECR Module  [![Build Status](https://travis-ci.org/doingcloudright/terraform-aws-ecr-cross-account.svg?branch=master)](https://travis-ci.org/doingcloudright/terraform-aws-ecr-cross-account)


This module simplifies the creation of an ECR Bucket which serves different AWS Accounts and different stages of development. With one repository per application for multiple stacks it's important that the builds are created with the stack name prefixed as TAG, this to allow lifecycles per tag prefix.

For all prefixes in the variable "prefixes", a lifecycle will be made with a default max count of 100. After 100 builds, the build with the earliest build-time will be dropped from the repository. The variable "prefixes_specific_max_count" is a map in which the maximum size can be changed per stage.

The list allowed_read_principals is mandatory and defines which principals have read access to the repository. allowed_write_principals could define a principle which has write (&read) access to the repository e.g. the CICD user.

## Examples

### Repository A, repo will be named dcr-repo
```
module "ecr_repo_a" {
    source                      = "doingcloudright/ecr-cross-account/aws"
    version                     = "0.0.2"
    namespace                   = "dcr"
    name                        = "repo"
    allowed_read_principals     = ["arn:aws:iam::1234567890:root"]
    allowed_write_principals    = []
    prefixes                    = ["test","uat","prod"]
}
```

### Repository A, repo will be named repo as use_namespaces is set to false
```
module "ecr_repo_a" {
    source                      = "doingcloudright/ecr-cross-account/aws"
    version                     = "0.0.2"
    namespace                   = "dcr"
    use_namespaces		= false
    name                        = "repo"
    allowed_read_principals     = ["arn:aws:iam::1234567890:root"]
    allowed_write_principals    = []
    prefixes                    = ["test","uat","prod"]
}
```

### The user arn:aws:iam::1234567891:user/cicd will have write access to this repository
```
module "ecr_repo_a" {
    source                      = "doingcloudright/ecr-cross-account/aws"
    version                     = "0.0.2"
    namespace                   = "dcr"
    name                        = "repo"
    allowed_read_principals     = ["arn:aws:iam::1234567890:root"]
    allowed_write_principals    = ["arn:aws:iam::1234567891:user/cicd"]
    prefixes                    = ["test","uat","prod"]
}
```

### Prefixes_specific_max_count sets the maximum count for test and uat to 40, instead of the default 100
```
module "ecr_repo_a" {
    source                      = "doingcloudright/ecr-cross-account/aws"
    version                     = "0.0.2"
    namespace                   = "dcr"
    name                        = "repo"
    allowed_read_principals     = ["arn:aws:iam::1234567890:root"]
    allowed_write_principals    = ["arn:aws:iam::1234567891:user/cicd"]
    prefixes                    = ["test","uat","prod"]
    prefixes_pecific_max_count = {
      test = 40
      uat = 40
    }
}
```
