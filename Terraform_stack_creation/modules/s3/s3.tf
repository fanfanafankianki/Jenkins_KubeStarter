resource "aws_s3_object" "file" {
  bucket = "stateterrafor"
  key = "terraform.tfstate"
  source = "./terraform.tfstate"
}
