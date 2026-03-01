# Authentik on Nomad with Ceph Storage

This Terraform module deploys a complete [Authentik](https://goauthentik.io/) stack on a [Nomad](https://www.nomadproject.io/) cluster. It leverages [Ceph](https://ceph.io/) RBD (via the CSI plugin) for persistent storage of the PostgreSQL database and Authentik media files.

## Architecture

The deployment consists of a single Nomad job (`authentik`) with a task group containing:

*   **Database**: PostgreSQL 17 (Sidecar)
*   **Redis**: Redis 7 (Sidecar)
*   **Server**: Authentik Server
*   **Worker**: Authentik Worker

Both the database and the server/worker media directories are backed by persistent Ceph RBD volumes created via `nomad_csi_volume`.

## Prerequisites

*   **Terraform**: >= 1.0
*   **Nomad Cluster**: A running Nomad cluster.
*   **Ceph Cluster**: A Ceph cluster with a pool accessible by the Nomad clients.
*   **Nomad CSI Driver for Ceph**: The Ceph CSI plugin must be deployed and registered on your Nomad cluster (plugin ID: `ceph-rbd`).
*   **Traefik**: Traefik is used as the ingress controller/proxy (enabled by default).

## Usage

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd tf-authentik
    ```

2.  **Configure Variables:**
    Create a `terraform.tfvars` file with your specific configuration.

    **Required Variables:**

    ```hcl
    # Ceph Cluster Configuration
    cluster_id      = "YOUR-CEPH-CLUSTER-UUID"
    ceph_username   = "admin" # or your specific user
    ceph_key        = "YOUR-CEPH-KEY"

    # Authentik Secrets
    authentik_secret_key = "generate-a-long-random-key"
    pg_pass             = "secure-db-password"

    # Initial Admin User
    bootstrap_email    = "admin@example.com"
    bootstrap_password = "admin-password"
    bootstrap_token    = "bootstrap-token"

    # Domain Configuration
    worker_traefik_hostname = "auth.example.com"
    ```

3.  **Review Configuration:**
    There are many optional variables for resource sizing (memory) and volume sizes. Check `variables.tf` for defaults.

4.  **Deploy:**

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

## Storage Volumes

This configuration manages two CSI volumes:
*   `ceph-authentik-pgsql-data`: Persistent storage for the PostgreSQL database.
*   `ceph-authentik-server-media`: Persistent storage for user-uploaded media (icons, etc.).

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `cluster_id` | The ID of the Ceph cluster to use to back the ceph storage | `string` | n/a |
| `ceph_username` | The username for an account with access to the RBD pool the RBD driver uses | `string` | n/a |
| `ceph_key` | The kep for an account with access to the RBD pool the RBD driver uses | `string` | n/a |
| `pgsql_data_size_min` | The minimum size for the PostgreSQL data volume | `string` | `"32M"` |
| `pgsql_data_size_max` | The maximum size for the PostgreSQL data volume | `string` | `"128M"` |
| `authentik_media_size_min` | The minimum size for the Authentik media volume | `string` | `"32M"` |
| `authentik_media_size_max` | The maximum size for the Authentik media volume | `string` | `"128M"` |
| `pg_pass` | The password to use for postgresql | `string` | n/a |
| `authentik_version` | The version of authentik to use | `string` | `"2026.2"` |
| `authentik_secret_key` | The secret key to use for authentik | `string` | n/a |
| `authentik_web_workers` | Number of gunicorn workers to start | `number` | `2` |
| `bootstrap_email` | The email to use for bootstrapping authentik | `string` | n/a |
| `bootstrap_password` | The password to use for bootstrapping authentik | `string` | n/a |
| `bootstrap_token` | The token to use for bootstrapping authentik | `string` | n/a |
| `database_memory` | The amount of memory to allocate for the database | `number` | `256` |
| `database_memory_max` | The max amount of memory to allow the database | `number` | `256` |
| `redis_memory` | The amount of memory to allocate for the redis | `number` | `64` |
| `redis_memory_max` | The max amount of memory to allow the redis | `number` | `64` |
| `server_memory` | The amount of memory to allocate to authentik server | `number` | `4096` |
| `server_memory_max` | The max amount of memory to allow authentik server | `number` | `4096` |
| `worker_memory` | The amount of memory to allocate to authentik worker | `number` | `2048` |
| `worker_memory_max` | The max amount of memory to allow authentik worker | `number` | `2048` |
| `worker_enable_traefik` | If enabled, will set tag to route server through traefik | `bool` | `true` |
| `worker_traefik_hostname` | The fqdn to use to access authentik via traefik | `string` | `"auth.example.net"` |
| `worker_traefik_entrypoint` | The name of the traefik entrypoint to use | `string` | `"websecure"` |
| `worker_traefik_enable_tls` | If enabled, will attempt to use tls on the entrypoint | `bool` | `true` |
| `worker_traefik_certresolver` | When tls is enabled, this sets which cert resolver within traefik to use | `string` | `"letsencrypt"` |

## License

[MIT](LICENSE)
