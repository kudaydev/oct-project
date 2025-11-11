###############################################################################
# Google Cloud Scheduler Job - HTTP, OIDC, and OAuth Token Support
###############################################################################

# HTTP Target (No Authentication)
resource "google_cloud_scheduler_job" "http_job" {
  count = var.auth_header_type == "none" ? 1 : 0

  project          = var.project_id
  name             = var.scheduler_name
  description      = var.description
  schedule         = var.schedule
  attempt_deadline = var.attempt_deadline
  region           = var.region
  time_zone        = var.time_zone

  http_target {
    http_method = var.http_method
    uri         = var.uri
    body        = base64encode(var.body)

    headers = {
      "Content-Type" = var.content_type
    }
  }
}

###############################################################################
# OIDC Token Authenticated Target
###############################################################################
resource "google_cloud_scheduler_job" "oidc_job" {
  count = var.auth_header_type == "oidc_token" ? 1 : 0

  project          = var.project_id
  name             = var.scheduler_name
  description      = var.description
  schedule         = var.schedule
  attempt_deadline = var.attempt_deadline
  region           = var.region
  time_zone        = var.time_zone

  http_target {
    http_method = var.http_method
    uri         = var.uri
    body        = base64encode(var.body)

    headers = {
      "Content-Type" = var.content_type
    }

    oidc_token {
      service_account_email = var.sa_email
      audience              = var.audience
    }
  }
}

###############################################################################
# OAuth Token Authenticated Target
###############################################################################
resource "google_cloud_scheduler_job" "oauth_job" {
  count = var.auth_header_type == "oauth_token" ? 1 : 0

  project          = var.project_id
  name             = var.scheduler_name
  description      = var.description
  schedule         = var.schedule
  attempt_deadline = var.attempt_deadline
  region           = var.region
  time_zone        = var.time_zone

  http_target {
    http_method = var.http_method
    uri         = var.uri
    body        = base64encode(var.body)

    headers = {
      "Content-Type" = var.content_type
    }

    oauth_token {
      service_account_email = var.sa_email
      scope                 = var.oauth_scope
    }
  }
}
