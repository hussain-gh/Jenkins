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
  ami           = "ami-04b4f1a9cf54c11d0"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.example.key_name
  
  user_data = <<-EOF
    #!/bin/bash
    # Update the package list
    sudo apt-get update -y
    
    # Install Jenkins
    sudo apt install -y openjdk-17-jre
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y jenkins

    # Start Jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins

    # Install Docker
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update -y
    sudo apt-get install -y docker-ce
    sudo usermod -aG docker ubuntu
    sudo usermod -aG docker jenkins
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