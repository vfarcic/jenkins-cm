resource "aws_security_group" "ha" {
  name = "jenkins-ha"
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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

output "ha_public_ip" {
  value = "${aws_instance.ha.public_ip}"
}
