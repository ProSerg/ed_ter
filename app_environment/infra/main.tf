# gry0
// instance
provider "aws" {
    region = "${var.aws_region}"
    version = "~> 2.0"
    shared_credentials_file = "/c/Users/Home/.aws/creds"
    profile                 = "develop"
}

// network
resource "aws_vpc" "gry0_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"
    tags = {
        Name = "gry0-${var.aws_env}"
        Owner = "smarkin"
    }
}

// gateway

resource "aws_internet_gateway" "gry0_gw" {
    vpc_id = "${aws_vpc.gry0_vpc.id}"
    tags = {
        Name = "gry0-${var.aws_env}-gw"
    }
}

resource "aws_route_table" "gry0_route_table" {
    vpc_id = "${aws_vpc.gry0_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gry0_gw.id}"
    }
    tags = {
        Name = "gry0-${var.aws_env}-route-table"
    }
}

resource "aws_route_table_association" "gry0_ingress_route_table_assoc_az_1" {
  count          = "${var.az_count}"
  subnet_id      = "${aws_subnet.gry0_public_subnet_az_1.id}"
  route_table_id = "${aws_route_table.gry0_route_table.id}"

  depends_on = [
    "aws_subnet.gry0_public_subnet_az_1",
    "aws_route_table.gry0_route_table",
  ]
}

resource "aws_route_table_association" "gry0_ingress_route_table_assoc_az_2" {
  count          = "${var.az_count}"
  subnet_id      = "${aws_subnet.gry0_public_subnet_az_2.id}"
  route_table_id = "${aws_route_table.gry0_route_table.id}"

  depends_on = [
    "aws_subnet.gry0_public_subnet_az_2",
    "aws_route_table.gry0_route_table"
  ]
}


// subnets
resource "aws_subnet" "gry0_public_subnet_az_1" {
    cidr_block = "${cidrsubnet(var.vpc_cidr, 4, 1)}"
    vpc_id = "${aws_vpc.gry0_vpc.id}"
    availability_zone = "eu-north-1a"
    map_public_ip_on_launch = "true"

    tags = {
        Name = "Public Ingress Subnet 1"
    }

    depends_on = [
        "aws_vpc.gry0_vpc"
    ]
}

resource "aws_subnet" "gry0_public_subnet_az_2" {
    cidr_block = "${cidrsubnet(var.vpc_cidr, 4, 2)}"
    vpc_id = "${aws_vpc.gry0_vpc.id}"
    availability_zone = "eu-north-1b"
    map_public_ip_on_launch = "true"

    tags = {
        Name = "Public Ingress Subnet 2"
    }

    depends_on = [
        "aws_vpc.gry0_vpc"
    ]
}





