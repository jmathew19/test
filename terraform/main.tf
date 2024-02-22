provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_instance" "example" {
  count         = var.create_instance ? 1 : 0  # Control whether to create the instance
  ami           = "ami-0e731c8a588258d0d" 
  instance_type = "t2.micro"
  key_name      = "terraform-key-pairs"
  vpc_security_group_ids = ["sg-0d6473f814374a9a6"]
  tags = {
    Name = "react proj"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "mkdir project",
      "cd project",
      "sudo yum install git -y",
      "git clone https://github.com/jmathew19/test.git",
      "cd react-aws-terraform-project",
      "sudo yum install -y nodejs npm",
      "node --version",
      "npm --version",
      "npm install web-vitals",
      "npm install react-scripts --save-dev",
      "npm install react-dom",
      # Additional commands to start your application
    ]
    
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = base64decode(var.private_key_base64)
      host        = self.public_ip
    }
  }
}

variable "private_key_base64" {
  description = "Base64 encoded private key content"
  type        = string
}

variable "aws_access_key_id" {
  description = "AWS access key ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
}

variable "create_instance" {
  description = "Whether to create the EC2 instance"
  type        = bool
  default     = true  # Default to creating the instance
}
