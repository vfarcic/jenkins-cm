variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "ami_id" {
  default = "unknown"
}
variable "ha_ami_id" {
  default = "unknown"
}
variable "ssh_user" {}
variable "ssh_pass" {}
variable "region" {
  default = "us-east-1"
}
variable "instance_type" {
  default = "t1.micro"
}
variable "count" {
  default = "2"
}