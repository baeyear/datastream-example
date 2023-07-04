resource "google_datastream_connection_profile" "alloydb" {
  display_name          = "AlloyDB Connection profile"
  location              = var.default_region
  connection_profile_id = "alloydb-connection-profile"
  project               = var.project_id

  postgresql_profile {
    hostname = google_compute_instance.ds-tcp-proxy.network_interface.0.network_ip
    port     = "5432"
    username = sensitive(var.alloydb_datastream.username)
    password = sensitive(var.alloydb_datastream.password)
    database = "postgres"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.main.id
  }
}

resource "google_datastream_connection_profile" "bigquery" {
  display_name          = "BigQuery Connection profile"
  location              = var.default_region
  connection_profile_id = "bigquery-connection-profile"
  project               = var.project_id

  bigquery_profile {}

  private_connectivity {
    private_connection = google_datastream_private_connection.main.id
  }
}

resource "google_datastream_private_connection" "main" {
  display_name          = "Datastream Private Connection"
  location              = var.default_region
  private_connection_id = "ds-private-connection"
  project               = var.project_id

  vpc_peering_config {
    vpc    = google_compute_network.vpc_network.id
    subnet = "10.1.0.0/29" // Datastream が配置されるサブネット範囲
  }
}


resource "google_datastream_stream" "main" {
  display_name  = "AlloyDB to BigQuery Datastream"
  location      = var.default_region
  stream_id     = "ds-alloydb-to-bigquery"
  desired_state = "RUNNING"
  project       = var.project_id

  source_config {
    source_connection_profile = google_datastream_connection_profile.alloydb.id

    postgresql_source_config {
      publication      = "datastream_publication"
      replication_slot = "datastream_replication_slot"
      include_objects {
        postgresql_schemas {
          schema = "public"
          /* postgresql_tables {
            table = "users"
            postgresql_columns {
              column = "name"
              data_type = "text"
            }
            postgresql_columns {
              column = "type"
              data_type = "user_type"
            }
          } */
        }
      }
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.bigquery.id

    bigquery_destination_config {
      data_freshness = "60s"
      single_target_dataset {
        dataset_id = google_bigquery_dataset.dataset.id
      }
      /* source_hierarchy_datasets {
        dataset_template {
          location = var.default_region
          dataset_id_prefix = "ds_"
        }
      } */
    }

  }

  backfill_all {

  }
}
