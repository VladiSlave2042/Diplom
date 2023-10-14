#####################################################################
#Сеть
resource "yandex_vpc_network" "network" {
  name = "network"
}
#Подсети, разбил на 4 штуки по одной приватной для каждой ВМ web сайта и по одной приватной и публичной для соответствующих сервисов, отдельную подсеть для бастиона не делал, излишне наверное.
resource "yandex_vpc_subnet" "public-serviese" {
  name           = "public-serviese"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
resource "yandex_vpc_subnet" "private-serviese" {
  name           = "private-bastion"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}
resource "yandex_vpc_subnet" "private-1" {
  name           = "web-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.4.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}
resource "yandex_vpc_subnet" "private-2" {
  name           = "web-2"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.8.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}
##Шлюз для выхода в сеть
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "gateway"
  shared_egress_gateway {}
}
resource "yandex_vpc_route_table" "rt" {
  name       = "route-table"
  network_id = yandex_vpc_network.network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}
################################################################################
#Группы бекэндов и балансировщик
resource "yandex_alb_target_group" "foo" {
  name           = "siet-target-group"
  target {
    subnet_id    = yandex_vpc_subnet.private-1.id
    ip_address   = "192.168.4.10"
  }
  target {
    subnet_id    = yandex_vpc_subnet.private-2.id
    ip_address   = "192.168.8.10"
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
  network_id  = yandex_vpc_network.network.id
  security_group_ids = [yandex_vpc_security_group.load-balancer-sg.id, yandex_vpc_security_group.private-sg.id]
  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.private-1.id 
    }#Вот тут с зонами доступности тоже непоняточка небольшая, вообще как я понял, то баланисровщик должен базироваться во всех зонах где есть соответствующие машины для балансировки трафика между ними. Хотя может это просто зона локализации.
    location {
      zone_id   = "ru-central1-c"
      subnet_id = yandex_vpc_subnet.private-2.id 
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
#####################################################################
#Группы безопасности
resource "yandex_vpc_security_group" "private-sg" {
  name       = "private-sg"  #Решил сделать единое правило для пропуска трафика во внутренней сети, что бы не прописывать порты у отдельных правил.
  network_id = yandex_vpc_network.network.id
  ingress {
    protocol          = "TCP"
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "TCP"
    security_group_id = yandex_vpc_security_group.load-balancer-sg.id
    port              = 80
  }
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.4.0/24", "192.168.8.0/24"]
  }
  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
##
resource "yandex_vpc_security_group" "load-balancer-sg" {
  name       = "load-balancer-sg"  #Не совсем уверен что это нужно, т.к. хелсчек описывается для немного другого ресурса, но поскольку в бекенд группе есть подобная задача, то оставил.
  network_id = yandex_vpc_network.network.id
  ingress {
    protocol          = "ANY"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
##
resource "yandex_vpc_security_group" "bastion-sg" {
  name        = "bastion-sg"
  network_id  = yandex_vpc_network.network.id
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
##
resource "yandex_vpc_security_group" "zabbix-sg" {
  name        = "zabbix-sg"
  network_id  = yandex_vpc_network.network.id
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 80
  }
  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
##
resource "yandex_vpc_security_group" "kibana-sg" {
  name        = "kibana-sg"
  network_id  = yandex_vpc_network.network.id
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }
  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
##
resource "yandex_vpc_security_group" "elastic-sg" {
  name        = "elastic-sg"
  network_id  = yandex_vpc_network.network.id
  ingress {
    protocol          = "TCP"
    v4_cidr_blocks    = ["192.168.10.0/24"]
    port              = 9200
  }
  ingress {
    protocol          = "TCP"
    v4_cidr_blocks    = ["192.168.4.0/24", "192.168.8.0/24"]
    port              = 9200
  }
  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}