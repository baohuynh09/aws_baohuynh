terraform {
    required_version = ">= 0.8"
}

provider "aws" {
    region = "us-west-2"
    access_key = "AKIAJV4WCHDIFUWA7TVQ"
    secret_key = "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"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "/home/baohuynh/.ssh/id_rsa.pub"
}

resource "aws_key_pair" "web_server" {
  key_name = "web_server"
  public_key = "${file("${var.key_path}")}"
}

resource "aws_instance" "example" {
    ami           = "ami-ba602bc2"
    instance_type = "t2.micro"
	subnet_id     = "subnet-1599f06c"
}

