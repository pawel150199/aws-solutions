locals {
    project_name = "eks"

    # Automatically load configuration from env.yaml file
    env_vars = yamldecode(file("${get_terragrunt_dir()}/env.yaml"))

    aws_region = local.env_vars.aws_region
    environment = local.env_vars.environment

    terraform_version = ">= 1.5.5"
    aws_provider_version = ">= 5.55.0"
}

generate "terraform" {
    path      = "terraform.tf"
    if_exists = "overwrite"
    contents   = <<EOF
terraform {
    required_version = "${local.terraform_version}"

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "${local.aws_provider_version}"
        }
    }
}
EOF
}

generate "locals" {
    path        = "configuration.tf"
    if_exists   = "overwrite_terragrunt"
    contents = <<EOF
locals {
    env_vars = yamldecode(file("${get_terragrunt_dir()}/env.yaml"))
}
EOF
}

generate "provider" {
    path        = "provider.tf"
    if_exists   = "overwrite_terragrunt"
    contents     = <<EOF
provider "aws" {
    region = "${local.aws_region}"

    # default tags
    default_tags {
        tags = {
            Environment     = "${local.environment}"
            ManagedBy       = "pawel.polski99@gmail.com"
            Project         = "${upper(local.project_name)}"
            TaggingVersion  = "v2.4"
            Confidentiality = "C3"
        }
    }
}
EOF
}

remote_state {
    backend = "s3"
    config = {
        encrypt        = true
        bucket         = "${local.project_name}-remote-state"
        key            = "${path_relative_to_include()}/terraform.tfstate"
        region         = "${local.aws_region}"
        dynamodb_table = "terraform-locks"
    }

    generate = {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }
}
