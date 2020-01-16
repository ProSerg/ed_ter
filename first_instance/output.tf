output "instance_ip_addr" {
  value = "${aws_instance.gry0-ec2-instance.public_ip}"
}