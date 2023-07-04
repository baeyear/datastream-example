module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = "gcr.io/dms-images/tcp-proxy"
    env = [
      {
        name  = "SOURCE_CONFIG"
        value = "${google_alloydb_instance.main.ip_address}:5432"
      }
    ],
  }
}

resource "google_compute_instance" "ds-tcp-proxy" {
  project                   = var.project_id
  name                      = "ds-tcp-proxy"
  machine_type              = "e2-micro"
  zone                      = var.default_zone
  allow_stopping_for_update = true

  tags = ["ds-tcp-proxy"]

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.tcp_proxy_datastream.id
    access_config {

    }
  }

  can_ip_forward = true

  metadata = {
    gce-container-declaration = module.gce-container.metadata_value
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  labels = {
    container-vm = module.gce-container.vm_container_label
  }

  service_account {
    email  = data.google_service_account.gce_default.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_firewall" "ds_proxy" {
  name    = "ds-proxy"
  project = var.project_id
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  # datastream のある　IP 範囲からのトラフィックのみ firewall が適用される
  source_ranges = ["10.1.0.0/29"]

  direction = "INGRESS"
  priority  = 1000

  # この tags がついた GCE にのみ firewall が適用される
  target_tags = ["ds-tcp-proxy"]
}