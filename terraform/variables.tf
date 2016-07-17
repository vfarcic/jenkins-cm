variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "cje_ami_id" {
  default = "unknown"
}
variable "cjoc_ami_id" {
  default = "unknown"
}
variable "ha_ami_id" {
  default = "unknown"
}
variable "agent_ami_id" {
  default = "unknown"
}
variable "ssh_user" {}
variable "ssh_pass" {}
variable "region" {
  default = "us-west-2"
}
variable "ha" {
  default = {
    instance_type = "t1.micro"
    cjoc_port = "80"
    cje_port = "8080"
  }
}
variable "cjoc" {
  default = {
    instance_type = "t1.micro"
    count = "2"
    port = "8888"
  }
}
variable "cje" {
  default = {
    instance_type = "t1.micro"
    count = "2"
    port = "8080"
  }
}

variable "agent" {
  default = {
    instance_type = "t1.micro"
    count = "2"
    port = "8080"
    executors = "2"
  }
}