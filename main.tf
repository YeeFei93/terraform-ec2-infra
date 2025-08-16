resource "aws_instance" "public" {
  count                       = 2
  ami                         = "ami-0de716d6197524dd9" # find the AMI ID of Amazon Linux 2023  
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.public.ids[count.index % length(data.aws_subnets.public.ids)]  # Dynamically select public subnet
  associate_public_ip_address = true
  key_name                    = "yeefei-key-pair" #Change to your keyname, e.g. jazeel-key-pair
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
 
  tags = {
    Name = "yeefei-ec2-${count.index + 1}"    #Prefix your own name, e.g. jazeel-ec2
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "yeefei-terraform-security-group" #Security group name, e.g. jazeel-terraform-security-group
  description = "Allow SSH inbound"
  vpc_id      = data.aws_vpc.selected.id  # Using data source to retrieve VPC ID dynamically
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"  
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Data source to retrieve VPC by name tag
data "aws_vpc" "selected" {
  tags = {
    Name = "ce11-vpc-vpc"
  }
}

# Data source to retrieve public subnets from the selected VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}