provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "files_bucket" {
  bucket = "terraformfiles-2"

  tags = {
    Name = "Final T Bucket"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
}

resource "aws_subnet" "secondary" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2b"
}

resource "aws_security_group" "allow_alb" {
  vpc_id = aws_vpc.main.id

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

resource "aws_lb" "my_lb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_alb.id]
  subnets            = [aws_subnet.main.id, aws_subnet.secondary.id]

  enable_deletion_protection = false

  tags = {
    Name = "my-lb"
  }
}

resource "aws_lb_target_group" "my_target_group" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0f3d9639a5674d559"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.allow_alb.id]
  subnet_id              = aws_subnet.main.id

  tags = {
    Name = "my-instance"
  }
}

resource "aws_lb_target_group_attachment" "my_tg_attachment" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_instance.id
  port             = 80
}
