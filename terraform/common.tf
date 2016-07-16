provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  availability_zone = "us-east-1b"
  availability_zone = "us-east-1c"
  availability_zone = "us-east-1d"
}

resource "aws_efs_file_system" "default" {
  reference_name = "jenkins"
  tags {
    Name = "Jenkins"
  }
}

resource "aws_efs_mount_target" "default" {
  file_system_id = "${aws_efs_file_system.default.id}"
  subnet_id = "${aws_subnet.default.id}"
}
