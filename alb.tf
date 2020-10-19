resource "aws_lb" "application-lb" {
  provider           = aws.region-master
  name               = "smart-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  tags = {
    Name = "smart-LB"
  }
}


#Create variable named webserver-port , type number , default 80
#Change port to variable in smart-sg group ingress rule which allows traffic from LB SG.

resource "aws_lb_target_group" "app-lb-tg" {
  provider    = aws.region-master
  name        = "app-lb-tg"
  port        = var.webserver-port
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_master.id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/"
    port     = var.webserver-port
    protocol = "HTTP"
    matcher  = "200-299"
  }
  tags = {
    Name = "smart-target-group"
  }
}

resource "aws_lb_listener" "smart-listener-http" {
  provider          = aws.region-master
  load_balancer_arn = aws_lb.application-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.id
  }
}


resource "aws_lb_target_group_attachment" "smart-master-attach" {
  provider         = aws.region-master
  target_group_arn = aws_lb_target_group.app-lb-tg.arn
  target_id        = aws_instance.smart-master.id
  port             = var.webserver-port
}
