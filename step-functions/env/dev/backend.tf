# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "step-functions-remote-state"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
  }
}
