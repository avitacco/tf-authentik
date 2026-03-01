resource "nomad_csi_volume" "ceph-authentik-pgsql-data" {
  volume_id = "${var.name_prefix}-pgsql-data"
  name      = "${var.name_prefix}-pgsql-data"
  plugin_id = var.csi_plugin_id

  capacity_min = var.pgsql_data_size_min
  capacity_max = var.pgsql_data_size_max

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "block-device"
  }

  mount_options {
    fs_type = "ext4"
  }

  secrets = {
    userID  = var.ceph_username
    userKey = var.ceph_key
  }

  parameters = {
    clusterID     = var.cluster_id
    pool          = var.ceph_pool_name
    imageFeatures = "layering"
    mkfsOptions   = "-t ext4"
  }
}

resource "nomad_csi_volume" "ceph-authentik-server-media" {
  volume_id = "${var.name_prefix}-server-media"
  name      = "${var.name_prefix}-server-media"
  plugin_id = var.csi_plugin_id

  capacity_min = var.authentik_media_size_min
  capacity_max = var.authentik_media_size_max

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "block-device"
  }
  mount_options {
    fs_type = "ext4"
  }

  secrets = {
    userID  = var.ceph_username
    userKey = var.ceph_key
  }

  parameters = {
    clusterID     = var.cluster_id
    pool          = var.ceph_pool_name
    imageFeatures = "layering"
    mkfsOptions   = "-t ext4"
  }
}

resource "nomad_job" "authentik" {
  jobspec = file("${path.module}/jobs/authentik.nomad.hcl")

  hcl2 {
    vars = {
      secret_key                  = var.authentik_secret_key
      authentik_version           = var.authentik_version
      authentik_external_url      = "${var.worker_traefik_enable_tls ? "https" : "http"}://${var.worker_traefik_hostname}"
      authentik_web_workers       = var.authentik_web_workers
      pg_pass                     = var.pg_pass
      postgres_image              = var.postgres_image
      redis_image                 = var.redis_image
      name_prefix                 = var.name_prefix
      bootstrap_email             = var.bootstrap_email
      bootstrap_password          = var.bootstrap_password
      bootstrap_token             = var.bootstrap_token
      database_memory             = var.database_memory
      database_memory_max         = var.database_memory_max
      redis_memory                = var.redis_memory
      redis_memory_max            = var.redis_memory_max
      server_memory               = var.server_memory
      server_memory_max           = var.server_memory_max
      worker_memory               = var.worker_memory
      worker_memory_max           = var.worker_memory_max
      worker_enable_traefik       = var.worker_enable_traefik
      worker_traefik_hostname     = var.worker_traefik_hostname
      worker_traefik_entrypoint   = var.worker_traefik_entrypoint
      worker_traefik_enable_tls   = var.worker_traefik_enable_tls
      worker_traefik_certresolver = var.worker_traefik_certresolver
    }
  }
}
