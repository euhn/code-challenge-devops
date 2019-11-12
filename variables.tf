variable "region" {
    description = "The region to deploy in"
    type = string
    default = "us-east-1"
}

variable "cluster_name" {
    description = "The name to use for all the cluster resources"
    type = string
    default = "ugroup-test"
}

variable "server_port" {
    description = "The port to use for HTTP requests"
    type = number
    default = 80
}

variable "elb_port" {
    description = "The port the ELB will use for HTTP requests"
    type = number
    default = 80
}

variable "instance_type" {
    description = "The type of EC2 Instance to run"
    type = string
    default = "t2.micro"
}

variable "min_size" {
    description = "The min number of EC2 Instances in the ASG"
    type = number
    default = 2
}

variable "max_size" {
    description = "The max number of EC2 Instances in the ASG"
    type = number
    default = 6
}
