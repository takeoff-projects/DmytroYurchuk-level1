terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.86"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.provider_region
}

locals {
  service_name = "go-pets"
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_project_iam_binding" "service_permissions" {
  for_each   = toset(["run.invoker", "datastore.user"])
  project    = var.project_id
  role       = "roles/${each.key}"
  members    = ["serviceAccount:${google_service_account.service_account.email}"]
  depends_on = [google_service_account.service_account]
}

resource "google_project_service" "gcp_services" {
  for_each           = toset(var.project_services)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_service_account" "service_account" {
  account_id   = "service-account"
  display_name = "SA"
  project = var.project_id
}

resource "google_cloud_run_service" "run_service" {
  name                       = local.service_name
  location                   = var.provider_region
  autogenerate_revision_name = true
  depends_on = [google_project_service.gcp_services]

  template {
    spec {
      service_account_name = google_service_account.service_account.email
      containers {
        image = "gcr.io/${var.project_id}/${local.service_name}:v1.0"
        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = var.project_id
        }
        ports {
          container_port = 8080
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.run_service.location
  project  = google_cloud_run_service.run_service.project
  service  = google_cloud_run_service.run_service.name

  policy_data = data.google_iam_policy.noauth.policy_data
  depends_on  = [google_cloud_run_service.run_service]
}

output "public_url" {
  value = google_cloud_run_service.run_service.status[0].url
}
