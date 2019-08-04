resource "aws_lb" "node6-nlb" {
  name               = "node6-nlb-${var.SUFFIX}"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.private-subnet.id}"]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "stellar6_front_end" {
  load_balancer_arn = "${aws_lb.node6-nlb.arn}"
  port              = "11625"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.node6-nlb-tg.arn}"
  }
}


resource "aws_lb_target_group" "node6-nlb-tg" {
  name     = "node6-nlb-tg-${var.SUFFIX}"
  port     = 11625
  protocol = "TCP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.Application-VPC.id}"
}

resource "aws_lb_target_group_attachment" "attach6" {
  target_group_arn = "${aws_lb_target_group.node6-nlb-tg.arn}"
  target_id        = "${aws_instance.test-core-6.id}"
  port             = 11625
}

################################

resource "aws_instance" "test-core-6" {
   ami = "${var.test_core_ami}"
   instance_type = "c5.large"
   key_name = "${aws_key_pair.default.id}"
   user_data = "${file("nodes/setup-env.6")}"
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.stellar-sg.id}"]
   associate_public_ip_address = false
   source_dest_check = false
   #iam_instance_profile = "${aws_iam_instance_profile.stellar_profile.name}"
root_block_device {
    volume_size = "8"
    volume_type = "standard"
  }

  tags = {
    Name = "test-core-6-${var.SUFFIX}"
  }
}

#####################

resource "aws_route53_record" "ip-test-core-6" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "ip-core-test-6"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.test-core-6.private_ip}"]
}


resource "aws_route53_record" "test-core-6" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "core-test-6"
  type    = "A"
 alias {
    name                   = "${aws_lb.node6-nlb.dns_name}"
    zone_id                = "${aws_lb.node6-nlb.zone_id}"
    evaluate_target_health = false
  }
}

