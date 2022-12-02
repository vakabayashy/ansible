terraform {
  required_providers {
    yandex = {
      source = "terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "Y_key"
  cloud_id                 = var.Y_cloud_id
  folder_id                = var.Y_folder_id
  zone                     = var.Y_zone
}


provider "aws" {
  region     = "ap-southeast-1"
  access_key = var.aws_ak
  secret_key = var.aws_sk
  default_tags {
    tags = {
      email  = var.email
      module = var.module
    }
  }
}

resource "random_string" "root_passwd" {
  count   = local.count
  length  = "12"
  upper   = true
  lower   = true
  numeric  = true
  special = true
}
resource "yandex_compute_instance" "ansible" {
  count       = local.count
  allow_stopping_for_update = true
  name        = "${var.devs.prefix[count.index]}${count.index + 1}"
  hostname    = "${var.devs.email}-${var.devs.prefix[count.index]}${count.index + 1}"
  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = var.Y_image_id.Ubuntu20
      size     = 15
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.net.id
    nat       = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: root\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${var.my_pub_ssh}\n      - ${var.pub_ssh}"
  }
  labels = {
    user_email = var.email
    task_name  = var.my_task_name
    type_vm    = var.devs.prefix[count.index]
  }

  connection {
    host        = self.network_interface.0.nat_ip_address
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_path)
  }
  provisioner "remote-exec" {
    inline = [
      "/bin/echo \"root:${random_string.root_passwd[count.index].result}\" | sudo chpasswd"
    ]
  }
}

data "yandex_vpc_subnet" "net" {
  name = "default-${var.Y_zone}"
}


data "aws_route53_zone" "selected" {
  name = var.aws_dns_devops
}

resource "aws_route53_record" "server_dns" {
  count   = local.count
  name    = "${yandex_compute_instance.ansible[count.index].hostname}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  zone_id = data.aws_route53_zone.selected.id
  ttl     = "300"
  records = [local.vps_pub_ip[count.index]]
}

output "ips" {
  value = yandex_compute_instance.ansible.*.network_interface.0.nat_ip_address
}

output "pass" {
  value = random_string.root_passwd.*.result
}

data "template_file" "template" {
  count    = local.count
  template = file("${path.module}/ansible_forming.tpl")
  vars = {
    server_dns = aws_route53_record.server_dns[count.index].name
  }
}

resource "local_file" "created_vm_list" {
  count    = local.count
  filename = "${path.module}/inventory.yml"
  content  = <<-EOT
    %{for server in data.template_file.template.*.rendered~}
    ${chomp(server)}
    %{endfor~}
EOT
}
