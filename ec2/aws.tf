variable "REGION" {}
variable "AZ" {}
variable "CIDR" {}
variable "SSH_PUB_KEY" {}
variable "SSH_PRIV_KEY" {}
variable "PRIVATE_IP_BLOG" {}
variable "PRIVATE_IP_DATABASE" {}
variable "PRIVATE_IP_SERVER" {}
variable "SCRIPT_DIR" {}
variable "type" { default = "t2.micro" }

provider "aws" {
    region = "${var.REGION}"
}

resource "aws_vpc" "root" {
	cidr_block = "${var.CIDR}"
	enable_dns_support = "true"
	enable_dns_hostnames = "true"
	tags { Name = "spire_demo vpc" }
}

resource "aws_subnet" "public" {
	vpc_id = "${aws_vpc.root.id}"
	cidr_block = "${var.CIDR}"
	availability_zone = "${var.REGION}${var.AZ}"
	map_public_ip_on_launch = true
	tags { Name = "spire_demo subnet public" }
}

resource "aws_internet_gateway" "public" {
	vpc_id = "${aws_vpc.root.id}"
	tags { Name = "spire_demo igw" }
}

resource "aws_route_table" "public" {
	vpc_id = "${aws_vpc.root.id}"
	tags { Name = "spire_demo rt public" }
}

resource "aws_route" "public_default" {
	route_table_id = "${aws_route_table.public.id}"
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_internet_gateway.public.id}"
}

resource "aws_route_table_association" "public" {
	route_table_id = "${aws_route_table.public.id}"
	subnet_id = "${aws_subnet.public.id}"
}

resource "aws_security_group" "default" {
    name = "spire-demo-default"
    description = "spire_demo default sg"
    vpc_id = "${aws_vpc.root.id}"
    tags { Name = "spire_demo default sg" }
}

resource "aws_security_group_rule" "self" {
	type = "ingress"
	from_port = 0
	to_port = 0
	protocol = "-1"
	self = true
	security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "https" {
	type = "ingress"
	from_port = 80
	to_port = 80
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "ssh" {
	type = "ingress"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "egress" {
	type = "egress"
	from_port = 0
	to_port = 0
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
	security_group_id = "${aws_security_group.default.id}"
}

resource "aws_key_pair" "demo" {
  key_name   = "spire_demo-key"
  public_key = "${file(var.SSH_PUB_KEY)}"
}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"] # Canonical
}

module "blog" {
    source = "modules/ec2"
    name = "spire_demo_blog" 
	private_ip = "${var.PRIVATE_IP_BLOG}"
	script_dir = "${var.SCRIPT_DIR}"
	key_name = "${aws_key_pair.demo.key_name}"
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "${var.type}"
    availability_zone = "${var.REGION}${var.AZ}"
	subnet_id = "${aws_subnet.public.id}"
	vpc_security_group_ids =  [ "${aws_security_group.default.id}" ]
	private_key = "${var.SSH_PRIV_KEY}"
}

module "database" {
    source = "modules/ec2"
    name = "spire_demo_database"
	private_ip = "${var.PRIVATE_IP_DATABASE}"
	script_dir = "${var.SCRIPT_DIR}"
	key_name = "${aws_key_pair.demo.key_name}"
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "${var.type}"
    availability_zone = "${var.REGION}${var.AZ}"
	subnet_id = "${aws_subnet.public.id}"
	vpc_security_group_ids =  [ "${aws_security_group.default.id}" ]
	private_key = "${var.SSH_PRIV_KEY}"
}

module "server" {
    source = "modules/ec2"
    name = "spire_demo_server"
	private_ip = "${var.PRIVATE_IP_SERVER}"
	script_dir = "${var.SCRIPT_DIR}"
	key_name = "${aws_key_pair.demo.key_name}"
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "${var.type}"
    availability_zone = "${var.REGION}${var.AZ}"
	subnet_id = "${aws_subnet.public.id}"
	vpc_security_group_ids =  [ "${aws_security_group.default.id}" ]
	private_key = "${var.SSH_PRIV_KEY}"
}

output "public_ip_blog" { value = "${module.blog.public_ip}" }
output "public_ip_database" { value = "${module.database.public_ip}" }
output "public_ip_server" { value = "${module.server.public_ip}" }
