
variable "key" {
  type = string
}
provider "google" {
  credentials = file(var.key)
  project     = "seismic-aloe-375119"
  region      = "europe-west1"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "google_storage_bucket" "project_airbnb" {
  name          = "project_airbnb_${random_id.bucket_id.hex}"
  location      = "europe-west1"
  force_destroy = true
}

resource "google_bigquery_dataset" "project_airbnb" {
  dataset_id                  = "project_airbnb"
  friendly_name               = "Project Airbnb"
  description                 = "Dataset for Project Airbnb"
  location                    = "EU"
}