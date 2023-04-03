terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
    region = "ap-south-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform_vpc"
  }
}

resource "aws_subnet" "sb_public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "terraform_public"
  }
}
# resource "aws_subnet" "sb_private" {
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = "10.0.2.0/24"
#   availability_zone = "ap-south-1b"
#   tags = {
#     Name = "terraform_private"
#   }
# }

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform_ig"
  }
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = "terraform_public"
  }
}
resource "aws_route_table_association" "rta_public" {
  subnet_id      = aws_subnet.sb_public.id
  route_table_id = aws_route_table.rt_public.id
}

# resource "aws_eip" "elastic_ip" {
#   vpc      = true
# }

# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.elastic_ip.id
#   subnet_id     = aws_subnet.sb_public.id

#   tags = {
#     Name = "gw NAT"
#   }
#   depends_on = [aws_internet_gateway.ig]
# }

# resource "aws_route_table" "rt_private" {
#   vpc_id = aws_vpc.vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }
#   tags = {
#     Name = "terraform_private"
#   }
# }
# resource "aws_route_table_association" "rta_private" {
#   subnet_id      = aws_subnet.sb_private.id
#   route_table_id = aws_route_table.rt_private.id
# }

resource "aws_security_group" "sg_public" {
  name        = "sg_public"
  description = "Allow traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "ICMP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "terraform_public_sg"
  }
}

# resource "aws_security_group" "sg_private" {
#   name        = "sg_private"
#   description = "Allow sg"
#   vpc_id      = aws_vpc.vpc.id

#   ingress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "All"
#     security_groups = [ aws_security_group.sg_public.id ]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "terraform_private_sg"
#   }
# }


# resource "aws_instance" "ec2_public" {
#     count = 3
#     ami = "ami-0e742cca61fb65051"
#     instance_type = "t2.micro"
#     subnet_id = aws_subnet.sb_public.id
#     security_groups = [ aws_security_group.sg_public.id ]
#     key_name = "MyKey"
#     user_data = <<EOF
# 		            #!/bin/bash
#                 yum update -y
#                 yum install httpd -y
#                 service httpd start
#                 chkconfig httpd on
#                 cd /var/www/html
#                 echo "<html> Hello World </html>"> index.html
# 	              EOF
#     associate_public_ip_address = true
#     tags = {
#         Name = "ec2_public"
#     }
# }
resource "aws_instance" "my-instance" {
  count         = var.instance_count
  ami           = lookup(var.ami,var.aws_region)
  instance_type = "t2.micro"
  key_name = "MyKey"

  tags = {
    Name  = element(var.instance_tags, count.index)
    Batch = "6AM"
  }
}


