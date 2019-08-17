data "alicloud_instance_types" "2c4g" {
  cpu_core_count = 2
  memory_size = 4
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

# Create a web server
resource "alicloud_instance" "web" {
  image_id          = "${data.alicloud_images.default.images.0.id}"
  internet_charge_type  = "PayByBandwidth"

  instance_type        = "${data.alicloud_instance_types.2c4g.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"
  security_groups      = ["${alicloud_security_group.default.id}"]
  instance_name        = "web"
  vswitch_id = "vsw-abc12345"
}

# Create security group
resource "alicloud_security_group" "default" {
  name        = "default"
  description = "default"
  vpc_id = "${alicloud_vpc.vpc.id}"
}
