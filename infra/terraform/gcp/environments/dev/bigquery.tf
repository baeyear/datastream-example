// https://registry.terraform.io/modules/terraform-google-modules/bigquery/google/latest
module "bigquery" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 6.1"

  dataset_id   = "datastream_dataset"
  dataset_name = "datastream_dataset"
  description  = "dataset for datastream demo"
  project_id   = var.project_id

  tables = [
    {
      table_id           = "users",
      schema             = file("bigquery_schema/user.json"),
      time_partitioning  = null
      range_partitioning = null,
      expiration_time    = null,
      clustering         = [],
      labels = {
        env = "dev"
      },
    },
    {
      table_id = "users_partitioned",
      schema   = file("bigquery_schema/user.json")
      time_partitioning = {
        type                     = "DAY",
        field                    = "created_at",
        require_partition_filter = true,
        expiration_ms            = null,
      },
      range_partitioning = null
      expiration_time    = null,
      clustering         = [],
      labels = {
        env = "dev"
      }
    },
  ]

  dataset_labels = {
    env = "dev"
  }
}
