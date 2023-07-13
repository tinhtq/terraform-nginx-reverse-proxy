variable "appname" {
  default = "test"
}

variable "prefix" {}

variable "region" {
  default = "us-west-2"
}

provider "aws" {
  region     = "${var.region}"
}

# terraform {
#   backend "s3" {
#   }
# }

# ec2
variable "ec2_ami_id" {}
variable "ec2_instance_size" {}
variable "ec2_instance_count" {}

# # keypair
variable "identity_location" {}

# # EXISTING RESOURCES
variable "subnet_id" {}
variable "vpc_id" {} 
variable "allowed_ip" { 
  default = ["0.0.0.0/0"]
}
resource "aws_key_pair" "example" {
  key_name   = "exampledocumentdb"
  public_key = file("/mnt/c/Users/Admin/Documents/nginx/.ssh/id_rsa.pub")
}
resource "aws_instance" "example" {
  count         = "${var.ec2_instance_count}"
  ami           = "${var.ec2_ami_id}"
  instance_type = "${var.ec2_instance_size}"
  key_name = "${aws_key_pair.example.id}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

  tags = {
    Name = "nginx-${count.index}"
  }

  root_block_device {
    volume_size = "8"
  }

  provisioner "file" {
    source = "config/nginx.conf"
    destination = "/home/ubuntu/stream.conf"
    connection {
      user = "ubuntu"
      private_key = "${file("${var.identity_location}")}"
      host = "${self.public_ip}"
    }
  }

  provisioner "remote-exec" {
    connection {
      user = "ubuntu"
      private_key = "${file("${var.identity_location}")}"
      host = "${self.public_ip}"
    }

    inline = [
      "sudo apt install -y nginx",
      "sudo mv /home/ubuntu/stream.conf /etc/nginx/stream.conf",
      "echo 'include /etc/nginx/stream.conf;' | sudo tee --append /etc/nginx/nginx.conf",
      "sudo systemctl reload nginx"
    ]
  }

}

resource "aws_security_group" "sg" {
  name        = "${var.appname}-${var.prefix}-sg"
  description = "Development"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = var.allowed_ip
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "6"
    cidr_blocks = var.allowed_ip
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

output "ec2-instance-ip" {
  value = "${aws_instance.example.*.public_ip}"
}
