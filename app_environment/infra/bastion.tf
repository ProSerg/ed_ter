
// security group

resource "aws_security_group" "gry0_bastion_sg" {
    name = "app-bastion-sg"
    description = "Allow all inbound traffic"
    vpc_id = "${aws_vpc.gry0_vpc.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${var.bastion_ssh_from}"]
    }

    egress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${cidrsubnet(var.vpc_cidr, 4, 1)}"]
    }

    egress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${cidrsubnet(var.vpc_cidr, 4, 2)}"]
    }

    tags = {
        Name = "gry0-${var.aws_env}-bastion-sg"
    }

    depends_on = [
        "aws_vpc.gry0_vpc"
    ]
}

// bastion

resource "aws_launch_configuration" "gry0_bastion_lc" {
    name_prefix = "gry0-bastion-"
    image_id = "${var.ami_bastion_id}"
    instance_type = "t3.micro"
    key_name = "${var.ami_key_pair_name}"
    security_groups = ["${aws_security_group.gry0_bastion_sg.id}"]

    lifecycle {
        create_before_destroy = true
    }

    depends_on = [
        "aws_security_group.gry0_bastion_sg"
    ]
}

resource "aws_autoscaling_group" "gry0_bastion_asg" {
    name = "gry0-bastion-asg"
    launch_configuration = "${aws_launch_configuration.gry0_bastion_lc.name}"
    min_size = 1 
    max_size = 1
    vpc_zone_identifier = ["${aws_subnet.gry0_public_subnet_az_1.id}"]

    lifecycle {
        create_before_destroy = true
    }

    depends_on = [
        "aws_launch_configuration.gry0_bastion_lc",
        "aws_subnet.gry0_public_subnet_az_1",
    ]
}