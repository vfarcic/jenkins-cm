variable "aws_access_key" {}
variable "aws_secret_key" {}
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
  default = "us-east-1"
}
variable "ha" {
  default = {
    instance_type = "t1.micro"
    cjoc_port     = "80"
    cje_port      = "8080"
  }
}
variable "cjoc" {
  default = {
    instance_type      = "m3.medium"
    count              = "2"
    port               = "8888"
    client_master_port = "53624"
  }
}

variable "agent" {
  default = {
    instance_type = "m3.medium"
    count         = "2"
    jnlp_port     = "35464"
    executors     = "2"
  }
}