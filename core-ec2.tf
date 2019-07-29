###########################
# EC2 Prometheus Server   #
###########################
resource "aws_instance" "prometheus_server" {
   ami = "${var.prometheus}"
   instance_type = "t3.medium"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.stellar-sg.id}"]
   associate_public_ip_address = false
   source_dest_check = false
   #iam_instance_profile = "${aws_iam_instance_profile.stellar_profile.name}"
root_block_device {
    volume_size = "135"
    volume_type = "standard"
  }

  tags = {
    Name = "Promehteus-Server"
  }
}
############################


###################################
# EC2 stellar-load-testing client #
##################################
resource "aws_instance" "test-load-client-1" {
   ami = "${var.test_load_client_ami}"
   instance_type = "t3.medium"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.stellar-sg.id}"]
   associate_public_ip_address = false
   source_dest_check = false
   #iam_instance_profile = "${aws_iam_instance_profile.stellar_profile.name}"
root_block_device {
    volume_size = "35"
    volume_type = "standard"
  }

  tags = {
    Name = "test-load-client-1"
  }
}



#########################
# Define Prometheus ALB #
#########################
resource "aws_lb" "prometheus-nlb" {
  name               = "prometheus-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet-b.id}"]
  security_groups    = ["${aws_security_group.stellar-sg.id}"]
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "prometheus_front_end" {
  load_balancer_arn = "${aws_lb.prometheus-nlb.arn}"
  port              = "9090"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.prometheus-nlb-tg.arn}"
  }
}


resource "aws_lb_target_group" "prometheus-nlb-tg" {
  name     = "prometheus-alb-tg"
  port     = 9090
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.Application-VPC.id}"
}

resource "aws_lb_target_group_attachment" "prometheus-attach" {
  target_group_arn = "${aws_lb_target_group.prometheus-nlb-tg.arn}"
  target_id        = "${aws_instance.prometheus_server.id}"
  port             = 9090
}
