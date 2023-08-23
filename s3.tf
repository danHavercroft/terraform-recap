provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "files_bucket" {
  bucket = "terraformfiles-2"

  tags = {
    Name = "Final T Bucket"
  }
}
