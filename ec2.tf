provider "aws" {
  region = "eu-west-2"
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

resource "aws_instance" "my_instance" {
  ami           = "ami-0f3d9639a5674d559"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.allow_alb.id]
  subnet_id              = aws_subnet.main.id

  tags = {
    Name = "my-instance"
  }
}
