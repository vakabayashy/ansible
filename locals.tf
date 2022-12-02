locals {
  count      = length(var.devs.prefix)
  vps_pub_ip = yandex_compute_instance.ansible.*.network_interface.0.nat_ip_address

}
