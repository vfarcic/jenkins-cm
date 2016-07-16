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

resource "aws_security_group" "cje" {
  name = "jenkins"
  description = "SSH and Internet traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
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

resource "aws_security_group" "ha" {
  name = "ha"
  description = "SSH and Internet traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
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

resource "aws_instance" "cje" {
  count = "${var.count}"
  ami = "${var.cje_ami_id}"
  instance_type = "${var.instance_type}"
  tags {
    Name = "cje"
  }
  subnet_id = "${aws_subnet.default.id}"
  vpc_security_group_ids = [
    "${aws_security_group.cje.id}",
    "${aws_vpc.default.default_security_group_id}"
  ]
  depends_on = ["aws_efs_mount_target.default"]
  provisioner "remote-exec" {
    connection {
      user = "${var.ssh_user}"
      password = "${var.ssh_pass}"
    }
    inline = [
      "sudo cp /data/jenkins/license.xml /tmp/.",
      "sudo mount -t nfs4 -o nfsvers=4.1 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).${aws_efs_file_system.default.id}.efs.${var.region}.amazonaws.com:/ /data/jenkins",
      "sudo mv /tmp/license.xml /data/jenkins/.",
      "sudo service jenkins restart"
    ]
  }
}

resource "aws_instance" "ha" {
  ami = "${var.ha_ami_id}"
  instance_type = "${var.instance_type}"
  tags {
    Name = "jenkins-ha"
  }
  subnet_id = "${aws_subnet.default.id}"
  vpc_security_group_ids = [
    "${aws_security_group.ha.id}",
    "${aws_vpc.default.default_security_group_id}"
  ]
  provisioner "remote-exec" {
    connection {
      user = "${var.ssh_user}"
      password = "${var.ssh_pass}"
    }
    inline = [
      "pwd"
    ]
  }
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

output "cje_public_ip_0" {
  value = "${aws_instance.cje.0.public_ip}"
}

output "cje_public_ip_1" {
  value = "${aws_instance.cje.1.public_ip}"
}

output "ha_public_ip" {
  value = "${aws_instance.ha.public_ip}"
}
