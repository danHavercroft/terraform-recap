provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "allow_ssh_and_web" {
  description = "Allow SSH and web traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
  ami                    = "ami-abc12345"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_and_web.id]

  tags = {
    Name = "my-instance-with-ssh-and-web"
  }
}
