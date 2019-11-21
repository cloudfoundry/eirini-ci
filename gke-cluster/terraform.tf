variable "name" {
  type = string
}

variable "node_count_per_zone" {
  type = number
  default = 1
}

variable "region" {
  type = string
  default = "europe-west1"
}

variable "node_machine_type" {
  type = string
  default = "n1-standard-4"
}

variable "dns-zone" {
  type = string
  default = "ci-envs"
}

variable "dns-name" {
  type = string
  default = "ci-envs.eirini.cf-app.com."
}


provider "google" {
  project     = "cff-eirini-peace-pods"
  region      = "${var.region}"
}

terraform {
  backend "gcs" {
    bucket = "eirini-ci"
  }
}

resource "google_compute_network" "network" {
  name = "${var.name}"
}

resource "google_container_cluster" "cluster" {
  name     = "${var.name}"
  location = "${var.region}-b"

  network = "${google_compute_network.network.name}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = var.node_count_per_zone

  ip_allocation_policy {
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
}

resource "google_container_node_pool" "node-pool" {
  name       = "${var.name}"
  location   = "${var.region}-b"
  cluster    = "${google_container_cluster.cluster.name}"
  management {
    auto_repair = true
    auto_upgrade = true
  }
  autoscaling {
    min_node_count = var.node_count_per_zone
    max_node_count = 12
  }
  initial_node_count = var.node_count_per_zone

  node_config {
    disk_size_gb = 200
    disk_type = "pd-ssd"
    machine_type = "${var.node_machine_type}"
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

resource "google_compute_address" "ingress-address" {
  name = "${var.name}-address"
  region = "europe-west1"
}

resource "google_dns_record_set" "gorouter-root" {
  name = "${var.name}.${var.dns-name}"
  managed_zone = "${var.dns-zone}"
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_address.ingress-address.address}"]
}

resource "google_dns_record_set" "gorouter-wildcard" {
  name = "*.${var.name}.${var.dns-name}"
  managed_zone = "${var.dns-zone}"
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_address.ingress-address.address}"]
}

resource "google_dns_record_set" "uaa-root" {
  name = "uaa.${var.name}.${var.dns-name}"
  managed_zone = "${var.dns-zone}"
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_address.ingress-address.address}"]
}

resource "google_dns_record_set" "uaa-wildcard" {
  name = "*.uaa.${var.name}.${var.dns-name}"
  managed_zone = "${var.dns-zone}"
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_address.ingress-address.address}"]
}
