terraform {
  backend "s3" {
    bucket       = "ml-ops-project-bucket"
    key          = "terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}