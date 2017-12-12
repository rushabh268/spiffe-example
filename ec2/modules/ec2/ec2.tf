variable "availability_zone" {}
variable "ami" {}
variable "name" {}
variable "demo_role" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "vpc_security_group_ids" { type = "list" }
variable "private_ip" {}
variable "key_name" {}
variable "private_key" {}
variable "script_dir" {}
variable "iam_instance_profile" {}

resource "aws_instance" "server" {
    tags { Name = "${var.name}" }
    private_ip = "${var.private_ip}"
    key_name = "${var.key_name}"
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    availability_zone = "${var.availability_zone}"
    subnet_id = "${var.subnet_id}"
    vpc_security_group_ids =  [ "${var.vpc_security_group_ids}" ]
	iam_instance_profile = "${var.iam_instance_profile}"
    associate_public_ip_address = true

	provisioner "file" {
		connection {
			type = "ssh"
			user = "ubuntu"
			private_key = "${file(var.private_key)}"
		}
		source = "${var.script_dir}"
		destination = "/tmp"
	}
	provisioner "remote-exec" {
		connection {
			type = "ssh"
			user = "ubuntu"
			private_key = "${file(var.private_key)}"
		}
	    inline = [
			"chmod -R a+x /tmp/${basename(var.script_dir)}/",
			"/tmp/${basename(var.script_dir)}/provision_${var.demo_role}.sh"
		]
	}
}

output "public_ip" { value = "${aws_instance.server.public_ip}" }

