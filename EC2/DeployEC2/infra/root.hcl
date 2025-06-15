locals {
  // S3 bucket specific inputs
  s3_bucket_name = "aws-studies-eduardo-bucket-01"
  s3_bucket_acl  = "private"
  s3_creation_provider_region = "sa-east-1" 
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = local.s3_bucket_name
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.s3_creation_provider_region
    encrypt        = true
  }
}