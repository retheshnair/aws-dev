provider "aws" {
          region = "${var.region}"
          profile = "${var.profile}"
}

resource "aws_vpc" "terraform" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = "1"
tags {
        Name = "Terraform-VPC"
    }
}

# Create ans instance gateway to give our subnet access to the open internet 

resource "aws_internet_gateway" "internet-gateway" {
              vpc_id = "${aws_vpc.terraform.id}"
tags {
        Name = "Gateway-Terraform"
    }
         
}

#Give VPC access to internet on its main route table
resource "aws_route" "internet_access" {
    route_table_id = "${aws_vpc.terraform.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet-gateway.id}"
}

##Create a subnet to lanch our instance 
resource "aws_subnet" "terraform" {
    vpc_id = "${aws_vpc.terraform.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true

    tags {
        Name = "Public-Terraform"
    }
}

resource "aws_security_group" "terraform_sg" {
  name = "terraform_securitygroup"
  description = "Allow all ssh and http traffic"
  vpc_id = "${aws_vpc.terraform.id}"

#SSH access from anywhere
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
#HTTP access from anywhere
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
#Outbound internet access
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]      
  }
}

#resource "aws_key_pair" "auth" {
#  key_name = "${var.key_name}"
#  public_key = "{file(var.public_key_path)}"
#}

resource "aws_iam_instance_profile" "admin_profile" {
    name = "admin_profile"
    roles = ["${aws_iam_role.admin_role.name}"]
}

resource "aws_iam_role_policy" "admin_policy" {
    name = "admin_policy"
    role = "${aws_iam_role.admin_role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
  "Effect": "Allow",
  "NotAction": "iam:*",
  "Resource": "*"
  },
  {
  "Effect": "Allow",
  "Action": "iam:PassRole",
  "Resource": "arn:aws:iam::aws:policy/PowerUserAccess"
  }
  ]
}
EOF
}

resource "aws_iam_role" "admin_role" {
    name = "admin_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_instance" "web" {
   instance_type = "t2.micro"
   ami = "ami-dc361ebf"
   iam_instance_profile = "admin_profile"
#   key_name = "{aws_key_pair.auth.id}"
   key_name = "mysydenykey"
   vpc_security_group_ids = ["${aws_security_group.terraform_sg.id}"]
   subnet_id = "${aws_subnet.terraform.id}"
 
connection {
        user = "ec2-user"
}

provisioner "remote-exec" {
   inline = [
          "sudo yum update -y",
          "sudo yum install python-pip ImageMagick -y",
          "sudo pip install ansible",
          "sudo pip install  boto",
          "mkdir images",
          "cd images"
]
}
}


output "hostname" {
  value = "${aws_instance.web.public_dns}"
}
#
###

