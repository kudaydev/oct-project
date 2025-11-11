##############################
# Pub/Sub Target Scheduler
##############################

# -----------------------------
# Variables
# -----------------------------
variable "project_id" {
  description = "(Required) The ID of the project where the Cloud Scheduler will be created."
  type        = string
}

variable "region" {
  description = "Region where the scheduler job resides."
  type        = string
}

variable "scheduler_name" {
  description = "Name of the Cloud Scheduler job."
  type        = string
  default     = "pubsub-scheduler"
}

variable "description" {
  description = "Description of the scheduler job."
  type        = string
  default     = "Scheduler for Pub/Sub job"
}

variable "schedule" {
  description = "Use cron pattern to schedule time event (e.g. */2 * * * *)."
  type        = string
}

variable "time_zone" {
  description = "Specifies the time zone to be used in interpreting schedule. The value must be a valid IANA time zone name (e.g. Europe/London)."
  type        = string
}

variable "topic_name" {
  description = "The name of the Pub/Sub topic to which the job will publish."
  type        = string
}

variable "pubsub_topic_data" {
  description = "The message data to send to the Pub/Sub topic."
  type        = string
}

# -----------------------------
# Cloud Scheduler Job Resource
# -----------------------------
resource "google_cloud_scheduler_job" "job" {
  project     = var.project_id
  region      = var.region
  name        = var.scheduler_name
  description = var.description
  schedule    = var.schedule
  time_zone   = var.time_zone

  pubsub_target {
    topic_name = var.topic_name
    data       = base64encode(var.pubsub_topic_data)
  }
}

# -----------------------------
# Outputs
# -----------------------------
output "scheduler_job_id" {
  description = "The ID of the created Cloud Scheduler job."
  value       = google_cloud_scheduler_job.job.id
}
