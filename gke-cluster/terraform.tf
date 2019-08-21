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

provider "google" {
  project     = "cff-eirini-peace-pods"
  region      = "${var.region}"
}

resource "google_compute_network" "network" {
  name = "${var.name}"
}

resource "google_container_cluster" "cluster" {
  name     = "${var.name}"
  location = "${var.region}"

  network = "${google_compute_network.network.name}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1

  ip_allocation_policy {
    use_ip_aliases = true
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
}

resource "google_container_node_pool" "node-pool" {
  name       = "${var.name}"
  location   = "${var.region}"
  cluster    = "${google_container_cluster.cluster.name}"
  node_count = var.node_count_per_zone

  node_config {
    preemptible  = true
    machine_type = "${var.node_machine_type}"
    image_type = "cos_containerd"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

