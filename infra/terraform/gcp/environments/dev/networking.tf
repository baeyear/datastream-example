resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = "vpc-datastream"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "tcp_proxy_datastream" {
  name          = "tcp-proxy-datastream"
  project       = var.project_id
  region        = var.default_region
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.0.0/16"
}

resource "google_compute_firewall" "allow_internal" {
  name    = "ds-allow-internal"
  project = var.project_id
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]

  direction = "INGRESS"
  priority  = 65534
}

data "google_service_account" "gce_default" {
  account_id = var.gce_sa
}