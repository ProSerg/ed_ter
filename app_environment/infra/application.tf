// elastic ip
resource "aws_eip" "gry0_eip_nat_1" {
    associate_with_private_ip = "${cidrsubnet(var.vpc_cidr, 4, 1)}"
    vpc      = true
}

resource "aws_eip" "gry0_eip_nat_2" {
    associate_with_private_ip = "${cidrsubnet(var.vpc_cidr, 4, 2)}"
    vpc      = true
}

// gateway

resource "aws_nat_gateway" "gw_1" {
  allocation_id = "${aws_eip.gry0_eip_nat_1.id}"
  subnet_id = "${cidrsubnet(var.vpc_cidr, 4, 1)}"
 
  tags = {
      Name = "gry0-${var.aws_env}-gw-nat-1"
  }
}


resource "aws_nat_gateway" "gw_2" {
  allocation_id = "${aws_eip.gry0_eip_nat_2.id}"
  subnet_id = "${cidrsubnet(var.vpc_cidr, 4, 2)}"
 
  tags = {
      Name = "gry0-${var.aws_env}-gw-nat-2"
  }
}


// subnets
resource "aws_subnet" "gry0_private_subnet_1" {
    cidr_block = "${cidrsubnet(var.vpc_cidr, 4, 3)}"
    vpc_id = "${aws_vpc.gry0_vpc.id}"
    availability_zone = "eu-north-1b"
    map_public_ip_on_launch = "true"

    tags = {
        Name = "Private Application Subnet 1"
    }

    depends_on = [
        "aws_vpc.gry0_vpc"
    ]
}

resource "aws_subnet" "gry0_private_subnet_2" {
    cidr_block = "${cidrsubnet(var.vpc_cidr, 4, 4)}"
    vpc_id = "${aws_vpc.gry0_vpc.id}"
    availability_zone = "eu-north-1b"
    map_public_ip_on_launch = "true"

    tags = {
        Name = "Private Application Subnet 2"
    }

    depends_on = [
        "aws_vpc.gry0_vpc"
    ]
}

// route table app server
resource "aws_route_table" "app_server_route_table_1" {
  vpc_id = "${aws_vpc.gry0_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw_1.id}"
  }

  depends_on = [
    "aws_vpc.gry0_vpc",
    "aws_nat_gateway.gw_1"
  ]
}

resource "aws_route_table_association" "app_server_route_table_assoc_az_1" {
  count          = "${var.az_count}"
  subnet_id      = "${aws_subnet.gry0_private_subnet_1.id}"
  route_table_id = "${aws_route_table.app_server_route_table_1.id}"

  depends_on = [
    "aws_subnet.gry0_private_subnet_1",
    "aws_route_table.app_server_route_table_1"
  ]
}

resource "aws_route_table" "app_server_route_table_2" {
  vpc_id = "${aws_vpc.gry0_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw_2.id}"
  }

  depends_on = [
    "aws_vpc.gry0_vpc",
    "aws_nat_gateway.gw_2"
  ]
}

resource "aws_route_table_association" "app_server_route_table_assoc_az_2" {
  count          = "${var.az_count}"
  subnet_id      = "${aws_subnet.gry0_private_subnet_2.id}"
  route_table_id = "${aws_route_table.app_server_route_table_2.id}"

  depends_on = [
    "aws_subnet.gry0_private_subnet_2",
    "aws_route_table.app_server_route_table_2"
  ]
}

// security group
resource "aws_security_group" "gry0_app_server_sg" {
    name = "app-server-sg"
    description = "Allow all inbound traffic"
    vpc_id = "${aws_vpc.gry0_vpc.id}"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["${cidrsubnet(var.vpc_cidr, 4, 1)}"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["${cidrsubnet(var.vpc_cidr, 4, 2)}"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${cidrsubnet(var.vpc_cidr, 4, 1)}"]
    }

    tags = {
        Name = "gry0-${var.aws_env}-app-server-sg"
    }

    depends_on = [
        "aws_vpc.gry0_vpc"
    ]
}

// application server
data "aws_ami" "nginx_ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["nginx-plus-ami-ubuntu-hvm-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["679593333241"] # Canonical
}

resource "aws_launch_configuration" "gry0_app_server_lc" {
    name_prefix = "gry0_app_server-${var.aws_env}-"
    image_id = "${data.aws_ami.nginx_ubuntu.id}"
    instance_type = "t3.micro"
    key_name = "${var.ami_key_pair_name}"
    security_groups = ["${aws_security_group.gry0_app_server_sg.id}"]

    lifecycle {
        create_before_destroy = true
    }
    depends_on = [
        "aws_security_group.gry0_app_server_sg"
    ]
}

resource "aws_autoscaling_group" "gry0_app_server_asg_1" {
    name = "gry0-app-server-${var.aws_env}-asg-1"
    launch_configuration = "${aws_launch_configuration.gry0_app_server_lc.name}"
    min_size = 1 
    max_size = 2
    vpc_zone_identifier = ["${aws_subnet.gry0_private_subnet_1.id}"]
    target_group_arns   = ["${aws_alb_target_group.gry0_alb_target_group.id}"]

    lifecycle {
        create_before_destroy = true
    }

    depends_on = [
        "aws_launch_configuration.gry0_app_server_lc",
        "aws_subnet.gry0_private_subnet_1",
        "aws_alb_target_group.gry0_alb_target_group"
    ]
}

resource "aws_autoscaling_group" "gry0_app_server_asg_2" {
    name = "gry0-app-server-${var.aws_env}-asg-2"
    launch_configuration = "${aws_launch_configuration.gry0_app_server_lc.name}"
    min_size = 1 
    max_size = 2
    vpc_zone_identifier = ["${aws_subnet.gry0_private_subnet_2.id}"]
    target_group_arns   = ["${aws_alb_target_group.gry0_alb_target_group.id}"]

    lifecycle {
        create_before_destroy = true
    }

    depends_on = [
        "aws_launch_configuration.gry0_app_server_lc",
        "aws_subnet.gry0_private_subnet_2",
        "aws_alb_target_group.gry0_alb_target_group"
    ]
}


