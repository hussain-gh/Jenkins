provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "example" {
  key_name   = "ec2-ubuntu-lab-key1"
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "example" {
  ami           = "ami-04b4f1a9cf54c11d0"  # Replace with your desired AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.example.key_name
  
  user_data = <<-EOF
    #!/bin/bash
    # Update the package list
    sudo apt update -y
	
    # Install Docker
    sudo apt install -y docker.io
    
    sudo systemctl enable docker
    
    # Install java
    sudo apt install -y openjdk-17-jre
    
    # Install jenkins
    sudo curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
      /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
      https://pkg.jenkins.io/debian binary/ | sudo tee \
      /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update -y
    sudo apt install -y jenkins
    
    sudo systemctl enable jenkins
    
    # Add jenkins and ubuntu users to docker group
    sudo usermod -aG docker jenkins
    sudo usermod -aG docker ubuntu
    
    sudo systemctl restart docker
  EOF

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
  filename = "${path.module}/key1.pem"
}

resource "null_resource" "save_private_key" {
  depends_on = [local_file.private_key_pem]
}