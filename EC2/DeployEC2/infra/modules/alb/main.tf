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

variable "subnets" {
  type = list(string)
}

module "web_server" {
  source = "git::https://github.com/your-org/your-repo.git//EC2/DeployEC2/infra/modules/webserver?ref=main"
  name                = var.name
  instance_type       = var.instance_type
  ami                 = var.ami
  vpc_id              = var.vpc_id
  number_of_instances = var.number_of_instances

}

resource "aws_security_group" "alb_sg" {
  name        = "${var.name}-alb-sg"
  description = "Security group for the ALB"
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "webserveralb_tg" {
  name     = "${var.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb" "webserveralb" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnets
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.webserveralb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserveralb_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "web_server_attachment" {
  count = var.number_of_instances

  target_group_arn = aws_lb_target_group.webserveralb_tg.arn
  target_id        = module.web_server.instance_ids[count.index]
  port             = 80
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.webserveralb.dns_name
}