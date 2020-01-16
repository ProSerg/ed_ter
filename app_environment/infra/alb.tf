// securety
resource "aws_security_group" "gry0_alb_sg" {
    name = "alb-sg"
    description = "Allow all inbound traffic"
    vpc_id = "${aws_vpc.gry0_vpc.id}"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["${cidrsubnet(var.vpc_cidr, 4, 1)}"]
    }

    egress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["${cidrsubnet(var.vpc_cidr, 4, 2)}"]
    }

    tags = {
        Name = "gry0-${var.aws_env}-alb-sg"
    }

    depends_on = [
        "aws_vpc.gry0_vpc"
    ]
}

// alb

resource "aws_alb_target_group" "gry0_alb_target_group" {
    name = "gry0-${var.aws_env}-alb-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = "${aws_vpc.gry0_vpc.id}"

    depends_on = [
        "aws_vpc.gry0_vpc"
    ]
}

resource "aws_alb" "gry0_alb" {
    name = "gry0-${var.aws_env}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = ["${aws_security_group.gry0_alb_sg.id}"]
    subnets = ["${aws_subnet.gry0_public_subnet_az_1.id}", "${aws_subnet.gry0_public_subnet_az_2.id}"]
    
    enable_deletion_protection = false

    tags = {
        Environment = "${var.aws_env}"
    }

    depends_on = [
        "aws_security_group.gry0_alb_sg",
        "aws_subnet.gry0_public_subnet_az_1",
        "aws_subnet.gry0_public_subnet_az_2"
    ]
}

resource "aws_alb_listener" "gry0_alb_listener" {
    load_balancer_arn = "${aws_alb.gry0_alb.id}"
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.gry0_alb_target_group.id}"
        type             = "forward"
    }

    depends_on = [
        "aws_alb.gry0_alb",
        "aws_alb_target_group.gry0_alb_target_group"
    ]
}
