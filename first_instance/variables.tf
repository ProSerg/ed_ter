variable "ami_name" {
    default = "gry0-instance"
}

variable "aws_region" {
    default = "eu-north-1"
    description = "The AWS region to create things in."
}


variable "ami_id" {
    default = "ami-005bc7d72deb72a3d"
}

variable "ami_key_pair_name" {
    default = "gry0-dev"
}
