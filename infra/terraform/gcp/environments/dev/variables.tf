variable "project_id" {
  type    = string
  default = "default"
}

variable "default_region" {
  type    = string
  default = "asia-northeast1"
}

variable "default_zone" {
  type    = string
  default = "asia-northeast1-a"
}

variable "credential_path" {
  type = string
}

variable "alloydb" {
  type = map(string)
  default = {
    "username" = "username"
    "password" = "password"
  }
}

variable "alloydb_datastream" {
  type = map(string)
  default = {
    "username" = "username"
    "password" = "password"
  }
}