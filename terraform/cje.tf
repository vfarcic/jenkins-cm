resource "aws_security_group" "default" {
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

resource "aws_instance" "default" {
  count = "${var.count}"
  ami = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  tags {
    Name = "jenkins"
  }
  subnet_id = "${aws_subnet.default.id}"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}",
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

output "cje_public_ip_0" {
  value = "${aws_instance.default.0.public_ip}"
}

output "cje_public_ip_1" {
  value = "${aws_instance.default.1.public_ip}"
}
