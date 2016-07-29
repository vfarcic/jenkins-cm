resource "aws_security_group" "cje" {
  name = "cje"
  description = "Internet traffic"
  vpc_id      = "${aws_vpc.cjp.id}"

  ingress {
    from_port = "${var.cje.port}"
    to_port = "${var.cje.port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "${var.agent.jnlp_port}"
    to_port = "${var.agent.jnlp_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "${var.cjoc.client_master_port}"
    to_port = "${var.cjoc.client_master_port}"
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

variable "cje_ami_id" {
  default = "unknown"
}
variable "cje_count" {
  default = "2"
}
variable "cje_instance_type" {
  default = "m1.medium"
}
variable "cje" {
  default = {
    port = "8080"
  }
}
