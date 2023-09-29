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
#####################################################################
#Группы безопасности
resource "yandex_vpc_security_group" "bastion-sg" {
  name        = "bastion-sg"
  network_id  = "${yandex_vpc_network.network-1.id}"
  ingress {
    protocol       = "TCP"
    description    = "ssh-in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  egress {
    protocol       = "TCP"
    description    = "ssh-out"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}
##
resource "yandex_vpc_security_group" "nginx-sg" {
  name        = "nginx-sg"
  network_id  = "${yandex_vpc_network.network-1.id}"
  ingress {
    protocol       = "TCP"
    description    = "nginx-in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol       = "TCP"
    description    = "nginx-in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  ingress {
    protocol       = "TCP"
    description    = "ssh-bastion-in"
    port           = 22
    security_group_id = yandex_vpc_security_group.bastion-sg.id
  }
  egress {
    protocol       = "ANY"
    description    = "out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
##
resource "yandex_vpc_security_group" "zabbix-sg" {
  name        = "zabbix-sg"
  network_id  = "${yandex_vpc_network.network-1.id}"
  ingress {
    protocol       = "TCP"
    description    = "zabbix-in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 10050
    to_port        = 10051
  }
  ingress {
    protocol       = "TCP"
    description    = "ssh-bastion-in"
    port           = 22
    security_group_id = yandex_vpc_security_group.bastion-sg.id
  }
  egress {
    protocol       = "ANY"
    description    = "out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
##
resource "yandex_vpc_security_group" "kibana-sg" {
  name        = "kibana-sg"
  network_id  = "${yandex_vpc_network.network-1.id}"
  ingress {
    protocol       = "TCP"
    description    = "kibana-in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }
  ingress {
    protocol       = "TCP"
    description    = "ssh-bastion-in"
    port           = 22
    security_group_id = yandex_vpc_security_group.bastion-sg.id
  }
  egress {
    protocol       = "ANY"
    description    = "out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
##
resource "yandex_vpc_security_group" "elastic-sg" {
  name        = "elastic-sg"
  network_id  = "${yandex_vpc_network.network-1.id}"
  ingress {
    protocol       = "TCP"
    description    = "elastic-in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 9200
  }
  ingress {
    protocol       = "TCP"
    description    = "ssh-bastion-in"
    port           = 22
    security_group_id = yandex_vpc_security_group.bastion-sg.id
  }
  egress {
    protocol       = "ANY"
    description    = "out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
#####################################################################
#Виртуальные машины
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
    security_group_ids = [yandex_vpc_security_group.nginx-sg.id, yandex_vpc_security_group.zabbix-sg.id]
    ip_address = "192.168.20.4"
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
    security_group_ids = [yandex_vpc_security_group.nginx-sg.id, yandex_vpc_security_group.zabbix-sg.id]
    ip_address = "192.168.30.4"
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
    security_group_ids = [yandex_vpc_security_group.elastic-sg.id]
    ip_address = "192.168.20.5"
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
    security_group_ids = [yandex_vpc_security_group.zabbix-sg.id]
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
    security_group_ids = [yandex_vpc_security_group.kibana-sg.id]
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
################################################################################
#Группы бекэндов и балансировщик
resource "yandex_alb_target_group" "foo" {
  name           = "siet-target-group"
  target {
    subnet_id    = yandex_vpc_subnet.private-a.id
    ip_address   = "192.168.20.4"
  }
  target {
    subnet_id    = yandex_vpc_subnet.private-c.id
    ip_address   = "192.168.30.4"
  }
}
##
resource "yandex_alb_backend_group" "site-backend-group" {
  name      = "site-backend-group"
  http_backend {
    name = "site-http-backend"
    weight = 1
    port = 80
    target_group_ids = ["${yandex_alb_target_group.foo.id}"]
    load_balancing_config {
      panic_threshold = 50
    }    
    healthcheck {
      timeout = "10s"
      interval = "2s"
      healthy_threshold = 10
      unhealthy_threshold = 15 
      http_healthcheck {
        path  = "/"
      }
    }
  }
}
##
resource "yandex_alb_http_router" "http-router" {
  name          = "server-router"
}
##
resource "yandex_alb_virtual_host" "my-virtual-host" {
  name                    = "site-virtual-host"
  http_router_id          = yandex_alb_http_router.http-router.id
  route {
    name                  = "based"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.site-backend-group.id
        timeout           = "60s"
      }
    }
  }
}    
##
resource "yandex_alb_load_balancer" "my-balancer" {
  name        = "site-balanser"
  network_id  = yandex_vpc_network.network-1.id
  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.private-a.id 
    }
    location {
      zone_id   = "ru-central1-c"
      subnet_id = yandex_vpc_subnet.private-c.id 
    }
  }
  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.http-router.id
      }
    }
  }
}
