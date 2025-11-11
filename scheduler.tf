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

###############################################################################
# Outputs for Cloud Scheduler Jobs
###############################################################################

# Output: HTTP Job ID
output "http_job_id" {
  description = "The ID of the HTTP job."
  value       = var.auth_header_type == "none" ? google_cloud_scheduler_job.http_job[0].id : null
}

# Output: OIDC Job ID
output "oidc_job_id" {
  description = "The ID of the OIDC job."
  value       = var.auth_header_type == "oidc_token" ? google_cloud_scheduler_job.oidc_job[0].id : null
}

# Output: OAuth Job ID
output "oauth_job_id" {
  description = "The ID of the OAuth job."
  value       = var.auth_header_type == "oauth_token" ? google_cloud_scheduler_job.oauth_job[0].id : null
}


###############################################################################
# Variables for Google Cloud Scheduler Jobs
###############################################################################

# ---------------------------------------------------------------------------
# General Configuration
# ---------------------------------------------------------------------------

variable "project_id" {
  description = "(Required) The ID of the project where the Cloud Scheduler job will be created."
  type        = string
}

variable "region" {
  description = "Region where the Cloud Scheduler job resides."
  type        = string
}

variable "scheduler_name" {
  description = "The name of the Cloud Scheduler job."
  type        = string
  default     = "scheduler-created-by-tf"
}

variable "description" {
  description = "Description of the Cloud Scheduler job."
  type        = string
  default     = "HTTP scheduler job"
}

variable "schedule" {
  description = "Cron pattern to schedule the job execution (e.g., '*/5 * * * *')."
  type        = string
}

variable "time_zone" {
  description = "Specifies the time zone used in interpreting the schedule. Must be a valid tz database name."
  type        = string
}

variable "attempt_deadline" {
  description = "The deadline in seconds for each job attempt."
  type        = string
  default     = "320s"
}

# ---------------------------------------------------------------------------
# HTTP Target Configuration
# ---------------------------------------------------------------------------

variable "http_method" {
  description = "Which HTTP method to use for the request."
  type        = string
  default     = "POST"
}

variable "uri" {
  description = "(Required) The full URI path that the request will be sent to."
  type        = string
}

variable "body" {
  description = "(Optional) HTTP request body. A request body is allowed only if the HTTP method is POST, PUT, or PATCH."
  type        = string
  default     = "{\"key\":\"value\"}"
}

variable "content_type" {
  description = "HTTP target content type."
  type        = string
  default     = "application/json"
}

# ---------------------------------------------------------------------------
# Authentication Configuration
# ---------------------------------------------------------------------------

variable "auth_header_type" {
  description = "HTTP target authentication header type. Allowed values: 'none', 'oidc_token', 'oauth_token'."
  type        = string
  default     = "none"
}

variable "sa_email" {
  description = "Service account email used for OIDC or OAuth authentication."
  type        = string
  default     = ""
}

variable "audience" {
  description = "Audience value for OIDC HTTP target."
  type        = string
  default     = ""
}

variable "oauth_scope" {
  description = "OAuth scope for HTTP target authentication."
  type        = string
  default     = "https://www.googleapis.com/auth/cloud-platform"
}



# 🌐 Cloud Scheduler Module Examples

This document provides Terraform examples for creating **Google Cloud Scheduler** jobs using the module  
`optimus.bupa.com/bupa-tfe-admin/cloud-scheduler/module`.  

The examples include:
1. HTTP target without authentication token  
2. HTTP target with OAuth token  
3. HTTP target with OIDC token  
4. Pub/Sub target

---

## 1️⃣ HTTP Target — Without Token

```hcl
module "cloud_scheduler_without_token" {
  source             = "optimus.bupa.com/bupa-tfe-admin/cloud-scheduler/module//modules/http"
  version            = "1.0.13"

  scheduler_name     = "http-scheduler"
  description        = "Scheduler for running job"
  project_id         = "optimus-sandbox-6458655"
  region             = "europe-west2"
  time_zone          = "Europe/London"
  schedule           = "0 12 * * *" # Cron job - runs daily at 12 PM
  
  http_method        = "POST"
  uri                = "https://www.googleapis.com/auth/cloud-platform"

  auth_header_type   = "none"
  body               = "sending data to target"
  content_type       = "application/json"

  # Update audience URL if required
  audience           = "https://example.target.endpoint"
}


module "cloud_scheduler_oauth" {
  source             = "optimus.bupa.com/bupa-tfe-admin/cloud-scheduler/module//modules/http"
  version            = "1.8.13"

  scheduler_name     = "test-http-scheduler"
  description        = "Scheduler for running job"
  project_id         = "optimus-sandbox-6458655"
  region             = "europe-west2"
  time_zone          = "Europe/London"
  schedule           = "0 2 * * *" # Cron job - runs daily at 2 AM
  
  http_method        = "POST"
  uri                = "https://www.googleapis.com/auth/cloud-platform"

  auth_header_type   = "oauth_token"
  sa_email           = "1049757293895-compute@developer.gserviceaccount.com"
  body               = "sending data to target"
  content_type       = "application/json"

  # Update audience URL if required
  audience           = "https://example.target.endpoint"
}



module "cloud_scheduler_oidc" {
  source             = "optimus.bupa.com/bupa-tfe-admin/cloud-scheduler/module//modules/http"
  version            = "1.0.13"

  scheduler_name     = "test-http-scheduler"
  description        = "Scheduler for running job"
  project_id         = "optimus-sandbox-6458655"
  region             = "europe-west2"
  time_zone          = "Europe/London"
  schedule           = "0 2 * * *" # Cron job - runs daily at 2 AM
  
  http_method        = "POST"
  uri                = "https://www.googleapis.com/auth/cloud-platform"

  auth_header_type   = "oidc_token"
  sa_email           = "1049757293895-compute@developer.gserviceaccount.com"
  body               = "sending data to target"
  content_type       = "application/json"

  # Update audience URL if required
  audience           = "https://example.target.endpoint"
}

module "cloud_scheduler_pubsub" {
  source             = "optimus.bupa.com/bupa-tfe-admin/cloud-scheduler/module//modules/pubsub"
  version            = "1.0.13"

  scheduler_name     = "pubsub-scheduler"
  description        = "Scheduler for running job"
  project_id         = "optimus-sandbox-6458655"
  region             = "europe-west2"
  time_zone          = "Europe/London"
  schedule           = "*/2 * * * *" # Cron job - runs every 2 minutes

  topic_name         = "pubsub-topic"
  pubsub_topic_data  = "test"
}
