variable "aws_region" {
    default = "eu-north-1"
    description = "The AWS region to create things in."
}

variable "ami_bastion_id" {
    default = "ami-005bc7d72deb72a3d"
}

variable "ami_key_pair_name" {
    default = "gry0-dev-test"
}

variable "vpc_cidr" {
    description = "VPC CIDR"
    default = "172.18.0.0/16"
}
variable "cidr_public_1" {
    default = "172.18.1.0/24"
}

variable "cidr_public_2" {
    default = "172.18.2.0/24"
}

variable "bastion_ssh_from" {
    default = "0.0.0.0/0"
}

variable "aws_env" {
    default = "stage"
}

variable "az_count" {
    default = 1
}
