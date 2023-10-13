#####################################################################
#Виртуальные машины
resource "yandex_compute_instance" "vm-1" {
  name        = "web-a"
  zone        = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd830gae25ve4glajdsj"
      size = 15
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-1.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id]
    ip_address = "192.168.30.10"
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
##
resource "yandex_compute_instance" "vm-2" {
  name        = "web-c"
  zone        = "ru-central1-c"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd830gae25ve4glajdsj"
      size = 15
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-2.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id]
    ip_address = "192.168.40.10"
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
      size = 25
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public-serviese.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.zabbix-sg.id]
    ip_address = "192.168.10.10"
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
      size = 25
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-serviese.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.elastic-sg.id]
    ip_address = "192.168.20.10"
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
      size = 25
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public-serviese.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.kibana-sg.id]
    ip_address = "192.168.10.11"
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
    subnet_id = yandex_vpc_subnet.public-serviese.id
    security_group_ids = [yandex_vpc_security_group.bastion-sg.id]
    ip_address = "192.168.10.12"
    nat = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}