resource "google_compute_global_address" "private_ip_alloydb" {
  name          = "${var.project_id}-alloydb-cluster-ip"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloydb.name]
}

// https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/alloydb_cluster
resource "google_alloydb_cluster" "main" {
  cluster_id = "${var.project_id}-alloydb-cluster"
  location   = var.default_region
  network    = google_compute_network.vpc_network.id

  initial_user {
    user     = sensitive(var.alloydb.username)
    password = sensitive(var.alloydb.password)
  }
}

// https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/alloydb_instance
resource "google_alloydb_instance" "main" {
  cluster       = google_alloydb_cluster.main.name
  instance_id   = "${var.project_id}-alloydb-instance"
  instance_type = "PRIMARY"

  database_flags = {
    "alloydb.logical_decoding" = "on"
  }

  depends_on = [google_service_networking_connection.vpc_connection]
}
