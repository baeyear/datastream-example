resource "google_bigquery_dataset" "dataset" {
  dataset_id    = "datastream_dataset"
  friendly_name = "datastream_dataset"
  description   = "dataset for datastream demo"
  project       = var.project_id

  location = var.default_region

  labels = {
    env = "dev"
  }
}
