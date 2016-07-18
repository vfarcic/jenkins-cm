resource "aws_instance" "agent" {
  count = "${var.agent.count}"
  ami = "${var.agent_ami_id}"
  instance_type = "${var.agent.instance_type}"
  tags {
    Name = "agent"
  }
  subnet_id = "${aws_subnet.cjp.id}"
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}"
  ]
  depends_on = ["aws_route.internet_access"]
  provisioner "remote-exec" {
    connection {
      user = "${var.ssh_user}"
      password = "${var.ssh_pass}"
    }
    inline = [
      "nohup java -jar /etc/swarm-client-jar-with-dependencies.jar -executors ${var.agent.executors} -master http://${aws_instance.ha.private_ip}:${var.ha.cje_port} -labels \"centos java\" >/tmp/jenkins-agent.log 2>&1 &",
      "sleep 5"
    ]
  }
}

output "agent_public_ip_0" {
  value = "${aws_instance.agent.0.public_ip}"
}

output "agent_public_ip_1" {
  value = "${aws_instance.agent.1.public_ip}"
}