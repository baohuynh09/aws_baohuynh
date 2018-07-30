#----------------------------------------#
#           SYSTEM CONFIGURE             #
#----------------------------------------#
terraform {
    required_version = ">= 0.8"
}

provider "aws" {
    region = "us-west-2"
    access_key = ""
    secret_key = ""
}

#----------------------------------------#
#           VARIABLE ASSIGNMENT          #
#----------------------------------------#
variable "server_port" {
    description = "The port the server will use for HTTP requests"
    default     = 8080
}

#----------------------------------------#
#               OUTPUT                   #
#----------------------------------------#
output "public_ip_printout" {
    value = "${aws_instance.example.public_ip}"
}


#----------------------------------------#
#              AWS RESOURCE              #
#----------------------------------------#
resource "aws_instance" "example" {
    count         = 1
    ami           = "ami-ba602bc2"
    instance_type = "t2.micro"
    subnet_id     = "subnet-1599f06c"
    key_name      = "webserver-keypair"
    vpc_security_group_ids = [ "sg-599fde28" ]
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > First.message
                EOF
    tags {
        Name = "terraform-example" 
    }
}

