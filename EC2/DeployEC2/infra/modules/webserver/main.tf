variable "instance_type" {
  type = string
}
variable "ami" {
  type = string
  default = "ami-02f06bef654d6c27b"
}
variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "number_of_instances" {
  type = number
  default = 1
}


resource "aws_security_group" "web_server_sg" {
  name        = "${var.name}-sg"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  count = var.number_of_instances
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>My EC2 from terragrunt - Instance ${count.index + 1}</h1>" > /var/www/html/index.html
EOF
  tags = {
    Name = "${var.name}-${count.index + 1}"
  }
}