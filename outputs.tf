output "elb_dns_name" {
    value = aws_elb.elb.dns_name
    description = "The domain name of the load balancer"
}

output "asg_name" {
    value = aws_autoscaling_group.asg.name
    description = "The name of the ASG"
}
