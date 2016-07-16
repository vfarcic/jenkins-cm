provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

resource "aws_vpc" "cjp" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "cjp" {
  vpc_id = "${aws_vpc.cjp.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.cjp.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.cjp.id}"
}

resource "aws_subnet" "cjp" {
  vpc_id                  = "${aws_vpc.cjp.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "ssh" {
  name = "ssh"
  description = "SSH traffic"
  vpc_id      = "${aws_vpc.cjp.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_efs_file_system" "cjp" {
  reference_name = "cjp"
  tags {
    Name = "cjp"
  }
}

resource "aws_efs_mount_target" "cjp" {
  file_system_id = "${aws_efs_file_system.cjp.id}"
  subnet_id = "${aws_subnet.cjp.id}"
}