#!/bin/bash

#echo -n "\"{" >> allnodes.txt
for (( c=1; c<$1; c++ ))
do
   cat <<"EOF" > example
resource "aws_lb" "node5-nlb-III" {
  name               = "node5-nlb-${var.SUFFIX}"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.private-subnet.id}"]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "stellar5_front_end" {
  load_balancer_arn = "${aws_lb.node5-nlb.arn}"
  port              = "11625"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.node5-nlb-tg.arn}"
  }
}


resource "aws_lb_target_group" "node5-nlb-tg" {
  name     = "node5-nlb-tg-${var.SUFFIX}"
  port     = 11625
  protocol = "TCP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.Application-VPC.id}"
}

resource "aws_lb_target_group_attachment" "attach5" {
  target_group_arn = "${aws_lb_target_group.node5-nlb-tg.arn}"
  target_id        = "${aws_instance.test-core-5.id}"
  port             = 11625
}

EOF

sed '/^*III*/ s/'"$c"'/'  example >> setup-env.$c

done
##########################################
allnodes=$(cat allnodes.txt)
for (( c=1; c<=$1; c++ ))
do
sed '/^export[[:blank:]]*all_nodes=/ s/$/'"$allnodes"'/'  setup-env-a.$c >> setup-env.$c
rm setup-env-a.$c
#rm core-test-$c
rm setup*
done
rm allnodes.txt
