# Configure AWS as the cloud provider
provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

# Find the latest AMI of Ubuntu
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    owners = ["099720109477"] # Canonical
}

# Use an existing VPC ID
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# Use an existing public subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_subnet
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}

# Create instances
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

# 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "udacity_t2" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  count = 4
  subnet_id = aws_default_subnet.default_az1.id
  associate_public_ip_address = true

  tags = {
    Name = "Udacity T2"
  }    
}

# 2 m4.large EC2 instances named Udacity M4
resource "aws_instance" "udacity_m4" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "m4.large"
  count = 2
  subnet_id = aws_default_subnet.default_az1.id
  associate_public_ip_address = true

  tags = {
    Name = "Udacity M4"
  }    
}

# Outputs
output "image_id" {
    value = "${data.aws_ami.ubuntu.id}"
}