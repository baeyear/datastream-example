resource "google_compute_instance" "ds-psql-client" {
  project                   = var.project_id
  name                      = "ds-psql-client"
  machine_type              = "e2-small"
  zone                      = var.default_zone
  allow_stopping_for_update = true

  tags = ["ds-psql-client"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2304-amd64"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.tcp_proxy_datastream.id

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email  = data.google_service_account.gce_default.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<EOF
#!/bin/bash
sudo apt -y update && sudo apt upgrade
sudo apt install -y postgresql-client
EOF
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "ds-allow-ssh"
  project = var.project_id
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP 経由での ssh を許可する
  source_ranges = ["35.235.240.0/20"]

  direction = "INGRESS"
  priority  = 1000

  # この tags がついた GCE にのみ firewall が適用される
  target_tags = ["ds-psql-client"]
}