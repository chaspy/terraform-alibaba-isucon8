data "alicloud_instance_types" "type" {
  cpu_core_count = 1
  memory_size    = 1
}

data "alicloud_images" "default" {
  name_regex  = "^ubuntu"
  most_recent = true
  owners      = "system"
}

resource "alicloud_vpc" "vpc" {
  name       = "isucon8"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id            = alicloud_vpc.vpc.id
  cidr_block        = "172.16.0.0/21"
  availability_zone = "ap-northeast-1a"
}

resource "alicloud_eip" "eip" {
}

# Create a web server
resource "alicloud_instance" "web" {
  image_id             = data.alicloud_images.default.images[0].id
  internet_charge_type = "PayByTraffic"

  instance_type              = data.alicloud_instance_types.type.instance_types[0].id
  system_disk_category       = "cloud_efficiency"
  security_groups            = [alicloud_security_group.default.id, alicloud_security_group.allow_basic_rule.id]
  instance_name              = "web"
  vswitch_id                 = alicloud_vswitch.vsw.id
  internet_max_bandwidth_out = 5
  host_name                  = "isucon8"
}

resource "alicloud_key_pair_attachment" "attachment" {
  key_name     = "key_pair_github" # Create key pair by hand
  instance_ids = ["${alicloud_instance.web.id}"]
}

# Create security group
resource "alicloud_security_group" "default" {
  name        = "default"
  description = "default"
  vpc_id      = alicloud_vpc.vpc.id
}

resource "alicloud_security_group" "allow_basic_rule" {
  inner_access = true
  name         = "allow_basic_rule"
  vpc_id       = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_https" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "443/443"
  priority          = 1
  security_group_id = "${alicloud_security_group.allow_basic_rule.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = "${alicloud_security_group.allow_basic_rule.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_icmp" {
  type              = "ingress"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = "${alicloud_security_group.allow_basic_rule.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = "${alicloud_security_group.allow_basic_rule.id}"
  cidr_ip           = "0.0.0.0/0"
}

output "ip" {
  value = alicloud_instance.web.public_ip
}
