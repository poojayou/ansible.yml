provider "aws" {
 region = "us-east-1"
}

resource "aws_s3_bucket" "ansible-my_bucket" {
 bucket = "ansible-my-awesome-bucket-710"
}
