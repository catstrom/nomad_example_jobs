job "example" {
  datacenters = ["dc1"]
  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "30s"
    progress_deadline = "2m"
    stagger           = "30s"
  }
  migrate {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "3m"
  }
  group "cache" {
  count = 3
    task "redis" {
      driver = "docker"

      config {
        image = "redis:3.2"
        port_map {
          db = 6379
        }
      }

      resources {
        network {
          port "tcp" {}
          port "db" {}
        }
      }

      service {
        name = "broken-service"
        port = "tcp"
        check {
          name     = "broken-check"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      service {
        name = "redis-cache"
        tags = ["global", "cache"]
        port = "db"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
