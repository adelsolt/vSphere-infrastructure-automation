terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "path/to/your/terraform.tfstate"
    region = "your-region"
    access_key = "your-access-key"
    secret_key = "your-secret-key"
  }
}
