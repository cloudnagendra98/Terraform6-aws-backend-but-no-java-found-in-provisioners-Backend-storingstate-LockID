resource "aws_key_pair" "private" {
  key_name   = var.appserver_config.key_name
  public_key = file(var.appserver_config.public_key_path)
  tags = {
    CreatedBy = "terraform"
  }

}

data "aws_ami" "default_ami" {
  most_recent = true


  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_subnet" "web" {
  filter {
    name   = "tag:Name"
    values = [var.appserver_config.web_subnet]
  }



  depends_on = [
    aws_vpc.vpc_ntier,
  aws_subnet.subnets]
}

resource "aws_instance" "appserver" {
  ami                         = data.aws_ami.default_ami.id
  associate_public_ip_address = true
  instance_type               = var.appserver_config.instance_type
  key_name                    = var.appserver_config.key_name
  # security_groups = [aws_security_group.webnsg]
  subnet_id              = data.aws_subnet.web.id
  vpc_security_group_ids = [aws_security_group.webnsg.id]

  tags = {
    Name = "appserver"
  }


  depends_on = [
    #data.aws_ami.default_ami,
    #aws_vpc.vpc_ntier,
    aws_subnet.subnets,
    #aws_security_group.webnsg,
    aws_route.route_vpc_igw
  ]

}


# provisioner "file" {
#   source      = "./installjenkins.sh"
#   destination = "/tmp/installjenkins.sh"

#   connection {
#   type        = "ssh"
#   user        = "ubuntu"
#   private_key = file(var.appserver_config.private_key_path)
#   #host     = aws_instance.appserver.public_ip
#   host = self.public_ip # here we are writing the connection block in the same resource which is aws_instance so we use self in place of that
# }

# }

# provisioner "remote-exec" {
#   script = "/tmp/installjenkins.sh"

#   connection {
#   type        = "ssh"
#   user        = "ubuntu"
#   private_key = file(var.appserver_config.private_key_path)
#   #host     = aws_instance.appserver.public_ip
#   host = self.public_ip # here we are writing the connection block in the same resource which is aws_instance so we use self in place of that
# }

# }





resource "null_resource" "script_executor" {

  provisioner "remote-exec" {

    inline = [
      "sudo apt-get update",
      "sudo apt-get install openjdk-17-jdk -y",
      "cd /tmp && wget https://referenceapplicationskhaja.s3.us-west-2.amazonaws.com/spring-petclinic-2.4.2.jar",
      "java -jar /tmp/spring-petclinic-2.4.2.jar &",
      "sleep 20s"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.appserver_config.private_key_path)
      #host     = aws_instance.appserver.public_ip
      host = aws_instance.appserver.public_ip # here we are writing the connection block in the same resource which is aws_instance so we use self in place of that
    }

  }
  triggers = {
    app_script_version = var.app_script_version

  }
  depends_on = [
    aws_instance.appserver
  ]

}