variable "secret_key" {
    type = string
}

variable "authentik_version" {
    type = string
}

variable "authentik_external_url" {
    type = string
}

variable "authentik_web_workers" {
    type = number
}

variable "pg_pass" {
    type = string
}

variable "bootstrap_email" {
    type = string
}

variable "bootstrap_password" {
    type = string
}

variable "bootstrap_token" {
    type = string
}

variable "database_memory" {
    type = number
}

variable "database_memory_max" {
    type = number
}

variable "redis_memory" {
    type = number
}

variable "redis_memory_max" {
    type = number
}

variable "server_memory" {
    type = number
}

variable "server_memory_max" {
    type = number
}

variable "worker_memory" {
    type = number
}

variable "worker_memory_max" {
    type = number
}

variable "worker_enable_traefik" {
    type = bool
}

variable "worker_traefik_hostname" {
    type = string
}

variable "worker_traefik_entrypoint" {
    type = string
}

variable "worker_traefik_enable_tls" {
    type = bool
}

variable "worker_traefik_certresolver" {
    type = string
}

variable "postgres_image" {
    type = string
}

variable "redis_image" {
    type = string
}

variable "name_prefix" {
    type = string
}



locals {
    authentik_env = {
        AUTHENTIK_SECRET_KEY           = "${var.secret_key}"
        AUTHENTIK_POSTGRESQL__HOST     = "127.0.0.1"
        AUTHENTIK_POSTGRESQL__USER     = "authentik"
        AUTHENTIK_POSTGRESQL__PASSWORD = "${var.pg_pass}"
        AUTHENTIK_POSTGRESQL__NAME     = "authentik"
        AUTHENTIK_REDIS__HOST          = "127.0.0.1"
        AUTHENTIK_HOST                 = "${var.authentik_external_url}"
        AUTHENTIK_HOST_BROWSER         = "${var.authentik_external_url}"
        AUTHENTIK_WEB__WORKERS         = "${var.authentik_web_workers}"
        AUTHENTIK_BOOTSTRAP_EMAIL    = "${var.bootstrap_email}"
        AUTHENTIK_BOOTSTRAP_PASSWORD = "${var.bootstrap_password}"
        AUTHENTIK_BOOTSTRAP_TOKEN    = "${var.bootstrap_token}"
    }
}

job "authentik" {
    type = "service"

    group "authentik" {
        count = 1

        volume "ceph-authentik-pgsql-data" {
            type            = "csi"
            attachment_mode = "file-system"
            access_mode     = "single-node-writer"
            read_only       = false
            source          = "${var.name_prefix}-pgsql-data"
        }

        volume "ceph-authentik-server-media" {
            type            = "csi"
            attachment_mode = "file-system"
            access_mode     = "single-node-writer"
            read_only       = false
            source          = "${var.name_prefix}-server-media"
        }

        network {
            mode = "bridge"

            port "http" {
                to = 9000
            }

            port "redis" {
                to = 6379
            }

            port "pgsql" {
                to = 5432
            }
        }

        task "database" {
            driver = "docker"

            resources {
                memory = var.database_memory
                memory_max = var.database_memory_max
            }

            lifecycle {
                hook    = "prestart"
                sidecar = true
            }

            volume_mount {
                volume      = "ceph-authentik-pgsql-data"
                destination = "/var/lib/postgresql"
                read_only   = false
            }

            config {
                image = var.postgres_image
            }

            env {
                POSTGRES_USER     = "authentik"
                POSTGRES_PASSWORD = "${var.pg_pass}"
                POSTGRES_DB       = "authentik"
            }

            service {
                name         = "authentik-database"

                check {
                    type         = "tcp"
                    port         = "pgsql"
                    interval     = "10s"
                    timeout      = "10s"
                }
            }

            service {
                name     = "authentik-redis"

                check {
                    type     = "tcp"
                    port     = "redis"
                    interval = "10s"
                    timeout  = "5s"
                }
            }

            service {
                name     = "authentik"
                port     = "http"

                tags = [
                    "traefik.enable=${var.worker_enable_traefik? "true" : "false"}",
                    "traefik.http.routers.authentik.rule=Host(`${var.worker_traefik_hostname}`)",
                    "traefik.http.routers.authentik.entrypoints=${var.worker_traefik_entrypoint}",
                    "traefik.http.routers.authentik.tls=${var.worker_traefik_enable_tls? "true" : "false"}",
                    "traefik.http.routers.authentik.tls.certresolver=${var.worker_traefik_certresolver}",
                    "traefik.http.middlewares.authentik.headers.customrequestheaders.X-Forwarded-Proto=https",
                    "traefik.http.routers.authentik.middlewares=authentik",
                ]

                check {
                    type     = "http"
                    path     = "/-/health/live/"
                    port     = "http"
                    interval = "20s"
                    timeout  = "10s"
                }
            }
        }

        task "redis" {
            driver = "docker"

            resources {
                memory = var.redis_memory
                memory_max = var.redis_memory_max
            }

            lifecycle {
                hook    = "prestart"
                sidecar = true
            }

            config {
                image = var.redis_image
            }
        }

        task "server" {
            driver = "docker"

            resources {
                memory = var.server_memory
                memory_max = var.server_memory_max
            }

            lifecycle {
                hook = "poststart"
            }

            volume_mount {
                volume      = "ceph-authentik-server-media"
                destination = "/media"
                read_only   = false
            }

            config {
                image   = "authentik/server:${var.authentik_version}"
                ports   = ["http"]
                command = "server"
            }

            env = local.authentik_env
        }

        task "worker" {
            driver = "docker"

            resources {
                memory = var.worker_memory
                memory_max = var.worker_memory_max
            }

            lifecycle {
                hook = "poststart"
            }

            volume_mount {
                volume      = "ceph-authentik-server-media"
                destination = "/media"
                read_only   = false
            }

            config {
                image   = "authentik/server:${var.authentik_version}"
                command = "worker"
            }

            env = local.authentik_env
        }
    }
}


