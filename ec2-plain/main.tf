provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "example" {
  key_name   = "ec2-ubuntu-lab-key2"
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "example" {
  ami           = "ami-04b4f1a9cf54c11d0"  # Replace with your desired AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.example.key_name
    
  tags = {
    Name = "jenkins-master-node"
  }
}

output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}

output "private_key_pem" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/key2.pem"
}

resource "null_resource" "save_private_key" {
  depends_on = [local_file.private_key_pem]
}