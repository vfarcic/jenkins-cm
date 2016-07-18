resource "aws_security_group" "ha" {
  name        = "jenkins-ha"
  description = "SSH and Internet traffic"
  vpc_id      = "${aws_vpc.cjp.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 10001
    to_port = 10001
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 35464
    to_port = 35464
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "ha" {
  ami = "${var.ha_ami_id}"
  instance_type = "${var.ha.instance_type}"
  tags {
    Name = "jenkins-ha"
  }
  subnet_id = "${aws_subnet.cjp.id}"
  vpc_security_group_ids = [
    "${aws_security_group.ha.id}",
    "${aws_vpc.cjp.default_security_group_id}"
  ]
  depends_on = ["aws_route.internet_access"]
  provisioner "remote-exec" {
    connection {
      user = "${var.ssh_user}"
      password = "${var.ssh_pass}"
    }
    inline = [
      "echo \"${template_file.ha.rendered}\" | sudo tee /etc/haproxy/haproxy.cfg",
      "sudo service haproxy restart"
    ]
  }
}

resource "template_file" "ha" {
  template = "${file("conf/haproxy.cfg")}"

  vars {
    cjoc_ha_port       = "${var.ha.cjoc_port}"
    cjoc_ip_0          = "${aws_instance.cjoc.0.private_ip}"
    cjoc_ip_1          = "${aws_instance.cjoc.1.private_ip}"
    cjoc_port          = "${var.cjoc.port}"
    cje_ha_port        = "${var.ha.cje_port}"
    cje_ip_0           = "${aws_instance.cje.0.private_ip}"
    cje_ip_1           = "${aws_instance.cje.1.private_ip}"
    cje_port           = "${var.cje.port}"
    jnlp_port          = "${var.agent.jnlp_port}"
    client_master_port = "${var.cjoc.client_master_port}"
  }
}

output "ha_public_ip" {
  value = "${aws_instance.ha.public_ip}"
}

output "ha_private_ip" {
  value = "${aws_instance.ha.private_ip}"
}
