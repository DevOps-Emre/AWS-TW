# Define the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Fetch the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

# Create EC2 instances
resource "aws_instance" "first_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  tags = {
    Name = "Terraform First Instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo echo 'Hello World' > /var/www/html/index.html",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }
}

resource "aws_instance" "second_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  tags = {
    Name = "Terraform Second Instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo echo 'Hello World' > /var/www/html/index.html",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }
}

# Create security group
resource "aws_security_group" "instance_sg" {
  name_prefix = "instance-sg"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Attach security group to instances
resource "aws_instance" "first_instance" {
  security_groups = [aws_security_group.instance_sg.id]
}

resource "aws_instance" "second_instance" {
  security_groups = [aws_security_group.instance_sg.id]
}

# Create public and private IP files
resource "local_file" "public_ip_file" {
  filename = "public.txt"
  content = "${aws_instance.first_instance.public_ip},${aws_instance.second_instance.public_ip}"
}

resource "local_file" "private_ip_file" {
  filename = "private.txt"
  content = "${aws_instance.first_instance.private_ip},${aws_instance.second_instance.private_ip}"
}

# Output the public IP addresses
output "public_ips" {
  value = "${aws_instance.first_instance.public_ip}, ${aws_instance.second_instance.public_ip}"
}
