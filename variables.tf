#
# Variables for ceph
#
variable "cluster_id" {
  description = "The ID of the Ceph cluster to use to back the ceph storage"
  type        = string

  validation {
    condition     = can(regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", var.cluster_id))
    error_message = "The ceph cluster ID must be a uuid"
  }
}

variable "ceph_username" {
  description = "The username for an account with access to the RBD pool the RBD driver uses"
  type        = string
  sensitive   = true
}

variable "ceph_key" {
  description = "The kep for an account with access to the RBD pool the RBD driver uses"
  type        = string
  sensitive   = true
}

variable "ceph_pool_name" {
  description = "The name of the Ceph pool to use for RBD volumes"
  type        = string
  default     = "nomad"
}

variable "csi_plugin_id" {
  description = "The ID of the Nomad CSI plugin for Ceph"
  type        = string
  default     = "ceph-rbd"
}


#
# Volume parameters
#
variable "pgsql_data_size_min" {
  description = "The minimum size for the PostgreSQL data volume"
  type        = string
  default     = "32M"
}

variable "pgsql_data_size_max" {
  description = "The maximum size for the PostgreSQL data volume"
  type        = string
  default     = "128M"
}

variable "authentik_media_size_min" {
  description = "The minimum size for the Authentik media volume"
  type        = string
  default     = "32M"
}

variable "authentik_media_size_max" {
  description = "The maximum size for the Authentik media volume"
  type        = string
  default     = "128M"
}

#
# Variables for postgresql
#
variable "pg_pass" {
  description = "The password to use for postgresql"
  type        = string
  sensitive   = true
}

#
# Variables for authentik
#
variable "authentik_version" {
  description = "The version of authentik to use"
  type        = string
  default     = "2026.2"
}

variable "authentik_secret_key" {
  description = "The secret key to use for authentik"
  type        = string
  sensitive   = true
}

variable "authentik_web_workers" {
  description = "Number of gunicorn workers to start"
  type        = number
  default     = 2
}

variable "postgres_image" {
  description = "The Docker image to use for PostgreSQL"
  type        = string
  default     = "postgres:17-alpine"
}

variable "redis_image" {
  description = "The Docker image to use for Redis"
  type        = string
  default     = "redis:7-alpine"
}


variable "bootstrap_email" {
  description = "The email to use for bootstrapping authentik"
  type        = string
}

variable "bootstrap_password" {
  description = "The password to use for bootstrapping authentik"
  type        = string
  sensitive   = true
}

variable "bootstrap_token" {
  description = "The token to use for bootstrapping authentik"
  type        = string
  sensitive   = true
}

variable "database_memory" {
  description = "The amount of memory to allocate for the database"
  type        = number
  default     = 256
}

variable "database_memory_max" {
  description = "The max amount of memory to allow the database"
  type        = number
  default     = 256
}

variable "redis_memory" {
  description = "The amount of memory to allocate for the redis"
  type        = number
  default     = 64
}

variable "redis_memory_max" {
  description = "The max amount of memory to allow the redis"
  type        = number
  default     = 64
}

variable "server_memory" {
  description = "The amount of memory to allocate to authentik server"
  type        = number
  default     = 4096
}

variable "server_memory_max" {
  description = "The max amount of memory to allow authentik server"
  type        = number
  default     = 4096
}

variable "worker_memory" {
  description = "The amount of memory to allocate to authentik worker"
  type        = number
  default     = 2048
}

variable "worker_memory_max" {
  description = "The max amount of memory to allow authentik worker"
  type        = number
  default     = 2048
}

variable "worker_enable_traefik" {
  description = "If enabled, will set tag to route server through traefik"
  type        = bool
  default     = true
}

variable "worker_traefik_hostname" {
  description = "The fqdn to use to access authentik via traefik"
  type        = string
  default     = "auth.example.net"
}

variable "worker_traefik_entrypoint" {
  description = "The name of the traefik entrypoint to use"
  type        = string
  default     = "websecure"
}

variable "worker_traefik_enable_tls" {
  description = "If enabled, will attempt to use tls on the entrypoint"
  type        = bool
  default     = true
}

variable "worker_traefik_certresolver" {
  description = "When tls is enabled, this sets which cert resolver within traefik to use"
  type        = string
  default     = "letsencrypt"
}

variable "name_prefix" {
  description = "A prefix to add to all created resources"
  type        = string
  default     = "authentik"
}

