terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}
provider "yandex" {
  token = "y0_AgAAAAAeDgurAATuwQAAAADfAP2Jh_u4KASxQG2XsJ8vF_kWyTDL5Ds"
  cloud_id = "b1gm89k2ds3gdamaj4vo"
  folder_id = "b1gkoo3ipkk5jge3h5m3"
}
#####################################################################
#Сеть
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}
resource "yandex_vpc_subnet" "private-a" {
  name           = "private-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}
resource "yandex_vpc_subnet" "private-c" {
  name           = "private-c"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}
######################################################################
resource "yandex_compute_instance" "vm-1" {
  name        = "site-a"
  zone        = "ru-central1-a"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd830gae25ve4glajdsj"
      size = 30
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-a.id
    ip_address = "192.168.20.4"
    nat = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
##
resource "yandex_compute_instance" "vm-2" {
  name        = "site-c"
  zone        = "ru-central1-c"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd830gae25ve4glajdsj"
      size = 30
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-c.id
    ip_address = "192.168.30.4"
    nat = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
##
resource "yandex_compute_instance" "vm-4" {
  name        = "elastic"
  zone        = "ru-central1-a"
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd830gae25ve4glajdsj"
      size = 40
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-a.id
    ip_address = "192.168.20.5"
    nat = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
##
resource "yandex_compute_instance" "vm-3" {
  name        = "zabbix-server"
  zone        = "ru-central1-a"
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd830gae25ve4glajdsj"
      size = 40
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.1.3"
    nat = true
  }
 metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
##
resource "yandex_compute_instance" "vm-5" {
  name        = "kibana"
  zone        = "ru-central1-a"
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd830gae25ve4glajdsj"
      size = 40
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.1.4"
    nat = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
##
resource "yandex_compute_instance" "vm-6" {
  name        = "bastion-host"
  zone        = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd830gae25ve4glajdsj"
      size = 20
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    security_group_ids = [yandex_vpc_security_group.bastion-sg.id]
    ip_address = "192.168.1.50"
    nat = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}