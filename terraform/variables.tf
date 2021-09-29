variable "project_id" {
  type = string
  default = "roi-takeoff-user55"
}

variable "provider_region" {
  type    = string
  default = "us-central1"
}

variable "project_services" {
  type = list(string)
  default = [
    "cloudapis.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "servicemanagement.googleapis.com",
    "servicecontrol.googleapis.com",
    "apigateway.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "datastore.googleapis.com",
    "iam.googleapis.com"
  ]
}