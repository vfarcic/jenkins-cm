resource "aws_security_group" "cjoc" {
  name = "cjoc"
  description = "Internet traffic"
  vpc_id      = "${aws_vpc.cjp.id}"

  ingress {
    from_port = 8888
    to_port = 8888
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
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "cjoc" {
  count = "${var.cjoc.count}"
  ami = "${var.cjoc_ami_id}"
  instance_type = "${var.cjoc.instance_type}"
  tags {
    Name = "cjoc"
  }
  subnet_id = "${aws_subnet.cjp.id}"
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.cjoc.id}",
    "${aws_vpc.cjp.default_security_group_id}"
  ]
  depends_on = ["aws_route.internet_access", "aws_efs_mount_target.cjp"]
  provisioner "remote-exec" {
    connection {
      user = "${var.ssh_user}"
      password = "${var.ssh_pass}"
    }
    inline = [
      "sudo service jenkins-oc stop",
      "sudo cp /data/jenkins-oc/license.xml /tmp/license.xml",
      "sudo mount -t nfs4 -o nfsvers=4.1 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).${aws_efs_file_system.cjp.id}.efs.${var.region}.amazonaws.com:/ /data/",
      "sudo mkdir -p /data/jenkins-oc",
      "sudo mv /tmp/license.xml /data/jenkins-oc/license.xml",
      "sudo chown jenkins-oc:jenkins-oc /data/jenkins-oc/",
      "sudo service jenkins-oc start"
    ]
  }
}

output "cjoc_public_ip_0" {
  value = "${aws_instance.cjoc.0.public_ip}"
}

output "cjoc_public_ip_1" {
  value = "${aws_instance.cjoc.1.public_ip}"
}