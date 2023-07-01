terraform {
  required_version = "~> 1.5.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.71.0"
    }
  }

  backend "gcs" {
    bucket = "datastream-example-bucket"
  }
}

provider "google" {
  credentials = file(var.credential_path)

  project = var.project_id
  region  = var.default_region
  zone    = var.default_zone
}