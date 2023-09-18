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

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

<<<<<<< HEAD
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

resource "yandex_vpc_subnet" "private-a" {
  name           = "private-a"
  zone           = "ru-central1-a"
=======
resource "yandex_vpc_subnet" "public-a" {
  name           = "public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.3.0/24"]
}

resource "yandex_vpc_subnet" "public-b" {
  name           = "public-b"
  zone           = "ru-central1-b"
>>>>>>> 03e1ce88717e42bd0cf9021beeb3b7c51eaa4fdd
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.2.0/24"]
}

<<<<<<< HEAD
resource "yandex_vpc_subnet" "private-b" {
  name           = "private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.3.0/24"]
=======
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.1.0/24"]
>>>>>>> 03e1ce88717e42bd0cf9021beeb3b7c51eaa4fdd
}

resource "yandex_compute_instance" "vm-1" {
  name        = "site-a"
  zone        = "ru-central1-a"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vtq76jue50g6b6tm7"
      size = 30
    }
  }
  network_interface {
<<<<<<< HEAD
    subnet_id = yandex_vpc_subnet.private-a.id
    ip_address = "192.168.2.3"
=======
    subnet_id = yandex_vpc_subnet.public-a.id
    ip_address = "192.168.3.4"
    nat = true
>>>>>>> 03e1ce88717e42bd0cf9021beeb3b7c51eaa4fdd
  }
  metadata = {
    ssh-keys = "debian:${file("~/keys.from.vm/BM1.pub")}"
  }
}

resource "yandex_compute_instance" "vm-2" {
  name        = "site-b"
  zone        = "ru-central1-b"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vtq76jue50g6b6tm7"
      size = 30
    }
  }
  network_interface {
<<<<<<< HEAD
    subnet_id = yandex_vpc_subnet.private-b.id
    ip_address = "192.168.3.3"
=======
    subnet_id = yandex_vpc_subnet.public-b.id
    ip_address = "192.168.2.4"
    nat = true
>>>>>>> 03e1ce88717e42bd0cf9021beeb3b7c51eaa4fdd
  }
  metadata = {
    ssh-keys = "debian:${file("~/keys.from.vm/BM2.pub")}"
  }
}

<<<<<<< HEAD
resource "yandex_compute_instance" "vm-4" {
  name        = "elastic"
  zone        = "ru-central1-a"
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vtq76jue50g6b6tm7"
      size = 40
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-a.id
    ip_address = "192.168.2.4"
  }
  metadata = {
    ssh-keys = "debian:${file("~/keys.from.vm/BM4.pub")}"
  }
}

=======
>>>>>>> 03e1ce88717e42bd0cf9021beeb3b7c51eaa4fdd
resource "yandex_compute_instance" "vm-3" {
  name        = "zabbix-server"
  zone        = "ru-central1-a"
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vtq76jue50g6b6tm7"
      size = 40
    }
  }
  network_interface {
<<<<<<< HEAD
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.1.3"
    nat = true
=======
    subnet_id = yandex_vpc_subnet.private.id
    ip_address = "192.168.1.4"
>>>>>>> 03e1ce88717e42bd0cf9021beeb3b7c51eaa4fdd
  }
 metadata = {
    ssh-keys = "debian:${file("~/keys.from.vm/BM3.pub")}"
  }
}

<<<<<<< HEAD
=======
resource "yandex_compute_instance" "vm-4" {
  name        = "elastic"
  zone        = "ru-central1-a"
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vtq76jue50g6b6tm7"
      size = 40
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public-a.id
    ip_address = "192.168.3.5"
  }
  metadata = {
    ssh-keys = "debian:${file("~/keys.from.vm/BM4.pub")}"
  }
}

>>>>>>> 03e1ce88717e42bd0cf9021beeb3b7c51eaa4fdd
resource "yandex_compute_instance" "vm-5" {
  name        = "kibana"
  zone        = "ru-central1-a"
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vtq76jue50g6b6tm7"
      size = 40
    }
  }
  network_interface {
<<<<<<< HEAD
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.1.4"
    nat = true
=======
    subnet_id = yandex_vpc_subnet.private.id
    ip_address = "192.168.1.5"
>>>>>>> 03e1ce88717e42bd0cf9021beeb3b7c51eaa4fdd
  }
  metadata = {
    ssh-keys = "debian:${file("~/keys.from.vm/BM5.pub")}"
  }
}

resource "yandex_compute_instance" "vm-6" {
  name        = "bastion-host"
  zone        = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vtq76jue50g6b6tm7"
      size = 15
    }
  }
  network_interface {
<<<<<<< HEAD
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.1.5"
    nat = true
=======
    subnet_id = yandex_vpc_subnet.public-a.id
    ip_address = "192.168.3.6"
>>>>>>> 03e1ce88717e42bd0cf9021beeb3b7c51eaa4fdd
  }
  metadata = {
    ssh-keys = "debian:${file("~/keys.from.vm/BM6.pub")}"
  }
}

resource "yandex_alb_target_group" "foo" {
  name           = "siet-target-group"
  target {
<<<<<<< HEAD
    subnet_id    = yandex_vpc_subnet.private-a.id
    ip_address   = "192.168.2.3"
  }
  target {
    subnet_id    = yandex_vpc_subnet.private-b.id
    ip_address   = "192.168.3.3"
=======
    subnet_id    = yandex_vpc_subnet.public-a.id
    ip_address   = "192.168.3.4"
  }
  target {
    subnet_id    = yandex_vpc_subnet.public-b.id
    ip_address   = "192.168.2.4"
>>>>>>> 03e1ce88717e42bd0cf9021beeb3b7c51eaa4fdd
  }
}

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

resource "yandex_alb_http_router" "http-router" {
  name          = "server-router"
}

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

resource "yandex_alb_load_balancer" "my-balancer" {
  name        = "site-balanser"
  network_id  = yandex_vpc_network.network-1.id
  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
<<<<<<< HEAD
      subnet_id = yandex_vpc_subnet.private-a.id 
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.private-b.id
=======
      subnet_id = yandex_vpc_subnet.public-a.id 
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.public-b.id
>>>>>>> 03e1ce88717e42bd0cf9021beeb3b7c51eaa4fdd
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
