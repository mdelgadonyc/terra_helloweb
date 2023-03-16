resource "aws_launch_configuration" "launchconfig_example" {
    image_id                = "ami-0172070f66a8ebe63"
    instance_type           = "t2.micro"
    security_groups         = [aws_security_group.hello_sg.id]


    user_data = <<-EOF
                #!/bin/bash
                echo "Hello world!" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    # Required when using a launch configuration with an auto scaling group.
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "asg_example" {
    launch_configuration    = aws_launch_configuration.launchconfig_example.name
    vpc_zone_identifier     = data.aws_subnets.default.ids

    min_size = 2
    max_size = 10

    tag {
        key                 = "Name"
        value               = "terraform-asg-example"
        propagate_at_launch = true
    }
}

resource "aws_security_group" "hello_sg" {
    name = "terraform-helloworld-secgroup"

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks =["0.0.0.0/0"]
    }
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
        name        = "vpc-id"
        values      = [data.aws_vpc.default.id]
    }
}

variable "server_port" {
    description = "The port number the web server will use for HTTP requests"
    type        = number
}