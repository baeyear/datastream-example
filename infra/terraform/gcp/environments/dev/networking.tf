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