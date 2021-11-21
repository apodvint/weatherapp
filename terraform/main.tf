resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "kp" {
  key_name = "myKey"
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "allow_frontend_traffic" {
  name        = "allow-frontend-traffic"

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_backend_traffic" {
  name        = "allow-backend-traffic"

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_inbound_ssh" {
  name = "allow-inbound-ssh"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group" "allow_outbound_traffic" {
  name        = "allow-outbound-traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "weatherapp" {
  ami = data.aws_ami.ubuntu.id
  key_name = aws_key_pair.kp.key_name
  instance_type = "t2.micro"

  tags = {
      name = "EficodeTask"
  }

  vpc_security_group_ids = [
      aws_security_group.allow_frontend_traffic.id,
      aws_security_group.allow_backend_traffic.id,
      aws_security_group.allow_inbound_ssh.id,
      aws_security_group.allow_outbound_traffic.id
  ]
}