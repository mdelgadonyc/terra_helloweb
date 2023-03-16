resource "aws_instance" "helloec2" {
    ami                     = "ami-0172070f66a8ebe63"
    instance_type           = "t2.micro"
    vpc_security_group_ids  = [aws_security_group.hello_sg.id]


    user_data = <<-EOF
                #!/bin/bash
                echo "Hello world!" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF

    user_data_replace_on_change = true

    tags = {
        Name = "terraform-example"
    }
}

resource "aws_security_group" "hello_sg" {
    name = "terraform-helloworld-secgroup"

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks =["0.0.0.0/0"]
    }
}