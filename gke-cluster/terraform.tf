variable "name" {
  type = string
}

variable "node-count-per-zone" {
  type = number
  default = 1
}

variable "region" {
  type = string
  default = "europe-west1"
}

variable "zone" {
  type = string
  default = "europe-west1-b"
}

variable "node-machine-type" {
  type = string
  default = "n1-standard-4"
}

variable "dns-zone-name" {
  type = string
  default = "ci-envs"
}

variable "dns-name" {
  type = string
  default = "ci-envs.eirini.cf-app.com."
}

variable "project-id" {
  type = string
  default = "cff-eirini-peace-pods"
}

provider "google" {
  project     = var.project-id
  region      = var.region
}

terraform {
  backend "gcs" {
    bucket = "eirini-ci"
  }
  required_providers {
    google = "~> 2.20"
  }
}

resource "google_service_account" "eirini" {
  account_id   = var.name
  display_name = var.name
}

resource "google_service_account_key" "eirini" {
  service_account_id = google_service_account.eirini.name
}

resource "google_project_iam_custom_role" "eirini_dns" {
  role_id     = "${var.name}_dns_role"
  title       = "${var.name} DNS Role"
  permissions = [
    "dns.changes.create",
    "dns.changes.get",
    "dns.managedZones.list",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update",
  ]
}

resource "google_project_iam_binding" "erini_dns" {
  role    = "projects/${var.project-id}/roles/${google_project_iam_custom_role.eirini_dns.role_id}"

  members = [
    "serviceAccount:${google_service_account.eirini.email}",
  ]
}

resource "local_file" "private_service_account_key" {
  sensitive_content     = google_service_account_key.eirini.private_key
  filename = "sa-private-key.json"
}

resource "google_compute_network" "network" {
  name = var.name
}

resource "google_container_cluster" "cluster" {
  name     = var.name
  location = var.zone

  network = google_compute_network.network.name

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = var.node-count-per-zone

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
}

resource "google_container_node_pool" "node_pool" {
  name       = var.name
  location   = var.zone
  cluster    = google_container_cluster.cluster.name
  management {
    auto_repair = true
    auto_upgrade = true
  }
  autoscaling {
    min_node_count = var.node-count-per-zone
    max_node_count = 12
  }
  initial_node_count = var.node-count-per-zone

  node_config {
    disk_size_gb = 200
    disk_type = "pd-ssd"
    machine_type = var.node-machine-type
    image_type = "COS_CONTAINERD"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_compute_address" "ingress_address" {
  name = var.name
  region = var.region
}

output "static_ip" {
  value = google_compute_address.ingress_address.address
}

resource "google_dns_record_set" "gorouter_root" {
  name = "${var.name}.${var.dns-name}"
  managed_zone = var.dns-zone-name
  type = "A"
  ttl  = 300

  rrdatas = [google_compute_address.ingress_address.address]
}

resource "google_dns_record_set" "gorouter_wildcard" {
  name = "*.${var.name}.${var.dns-name}"
  managed_zone = var.dns-zone-name
  type = "A"
  ttl  = 300

  rrdatas = [google_compute_address.ingress_address.address]
}

resource "google_dns_record_set" "uaa_root" {
  name = "uaa.${var.name}.${var.dns-name}"
  managed_zone = var.dns-zone-name
  type = "A"
  ttl  = 300

  rrdatas = [google_compute_address.ingress_address.address]
}

resource "google_dns_record_set" "uaa_wildcard" {
  name = "*.uaa.${var.name}.${var.dns-name}"
  managed_zone = var.dns-zone-name
  type = "A"
  ttl  = 300

  rrdatas = [google_compute_address.ingress_address.address]
}
