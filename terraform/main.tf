terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

locals {
  service_name = "go-pets"
}

resource "google_cloud_run_service" "default" {
  name     = local.service_name
  location = var.provider_region
  autogenerate_revision_name = true

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/go-pets:v1.0"
        env {
          name = "GOOGLE_CLOUD_PROJECT"
          value = var.project_id
        }
      }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_project_service" "gcp_services" {
  for_each           = toset(var.project_services)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}