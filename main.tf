resource "aws_instance" "public" {
  count                       = 2
  ami                         = data.aws_ami.amazon_linux_2023.id # find the AMI ID of Amazon Linux 2023  
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.public.ids[count.index]
  key_name                    = "yeefei-key-pair" #Change to your keyname, e.g. jazeel-key-pair
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
 
  tags = {
   Name = "${var.name}-ec2-${count.index + 1}"
 }
}

resource "aws_security_group" "allow_ssh" {
  name        = "yeefei-terraform-security-group" #Security group name, e.g. jazeel-terraform-security-group
  description = "Allow SSH inbound"
  vpc_id      = data.aws_vpc.selected.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"  
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}