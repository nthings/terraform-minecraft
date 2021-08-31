variable "credentials_file" {
  description = "The contents of the JSON GCP Service Account."
}

variable "project_id" {
  description = "ID of the GCP Project"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}