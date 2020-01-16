# gry0
// instance
provider "aws" {
    region = "${var.aws_region}"
    version = "~> 2.0"
    shared_credentials_file = "/c/Users/Home/.aws/creds"
    profile                 = "develop"
}

// network
resource "aws_vpc" "gry0-env" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "gry0-env"
    }
}

// elastic ip
resource "aws_eip" "gry0-eip-env" {
    instance = "${aws_instance.gry0-ec2-instance.id}"
    vpc      = true
}

// gateway
resource "aws_internet_gateway" "gry0-env-gw" {
    vpc_id = "${aws_vpc.gry0-env.id}"
    tags = {
        Name = "gry0-env-gw"
    }
}

resource "aws_route_table" "gry0-env-route-table" {
    vpc_id = "${aws_vpc.gry0-env.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gry0-env-gw.id}"
    }
    tags = {
        Name = "gry0-env-route-table"
    }
}

resource "aws_route_table_association" "gry0-subnet-assocation" {
    subnet_id = "${aws_subnet.gry0-subnet.id}"
    route_table_id = "${aws_route_table.gry0-env-route-table.id}"
}



// subnets
resource "aws_subnet" "gry0-subnet" {
    cidr_block = "${cidrsubnet(aws_vpc.gry0-env.cidr_block, 3, 1)}"
    vpc_id = "${aws_vpc.gry0-env.id}"
    availability_zone = "eu-north-1a"
}

// securety
resource "aws_security_group" "gry0-sg-ingress-all" {
    name = "allow-all-sg"
    vpc_id = "${aws_vpc.gry0-env.id}"
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 22
        to_port = 22
        protocol = "tcp"
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

// instance
resource "aws_instance" "gry0-ec2-instance" {
    ami = "${var.ami_id}"
    instance_type = "t3.micro"
    key_name = "${aws_key_pair.gry0-key.key_name}"
    security_groups = [
        "${aws_security_group.gry0-sg-ingress-all.id}"
    ]
    tags = {
        Name = "${var.ami_name}"
    }
    subnet_id = "${aws_subnet.gry0-subnet.id}"
}

// key_pair
resource "aws_key_pair" "gry0-key" {
    key_name = "${var.ami_key_pair_name}"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCLxqcz+b6Gn6u9CtnPgv2ZT3ro1djep7qhzSWtjpEXoU8JiBlZFMgxDCl+KUgUtjN6GCQBlQpMOpF5ZpNSmg7p0j4xlOL3zwAmiw51WgTeIMhtroKPAUsmclgZPJl9z9yFgJJlhV6NhU+K1ke2pL81jErLqNG0xGwW/4N1WDa3dJm+XJDyrEvqsFR7kZ3uCxZolDzP+z3QCMoa8lDlteiWF86vmjA9JS6dwA/5Rm2H8caYNo4TCY4m33DTvZaHBctvvGuxvjHqXgRpPhUt3Wic9DweN/yxEf4RQ2CJ/cYP2+IFa5+SUDmMXoF36V6orJziuf8ogP8cpRzMQUjtF1L9"
}




