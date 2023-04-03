variable "ami" {
  type = map

  default = {
    "ap-south-1" = "ami-0e742cca61fb65051"
  }
}

variable "instance_count" {
  default = "2"
}

variable "instance_tags" {
  type = list
  default = ["Terraform-1", "Terraform-2"]
}

variable "aws_region" {
  default = "ap-south-1"
}

