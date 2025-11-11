############################################################
# Provider & Version Setup
############################################################
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

############################################################
# Data Sources
############################################################
data "google_compute_network" "vpc" {
  name    = "shared-vpc-dev"
  project = "gfvpchub-939368"
}

data "google_compute_subnetwork" "subnet" {
  name    = "shared-vpc-techportal-europewest2"
  project = "gfvpchub-939368"
  region  = "europe-west2"
}

############################################################
# PSC NEG Module
############################################################
module "psc_neg" {
  source  = "optimus.bupa.com/bupa-tfe-admin/compute-neg/module//modules/psc_neg"
  version = "1.0.2"

  project_id            = "techportal-dev-490018"
  name                  = "psc-neg-test"
  region                = "europe-west2"
  network               = data.google_compute_network.vpc.id
  subnetwork            = data.google_compute_subnetwork.subnet.self_link
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = "projects/g92390eeb3100cd63p-tp/regions/europe-west1/serviceAttachments/apigee-europe-west-kgkf"
  producer_port         = 15000
}

############################################################
# Apigee PSC LB Module
############################################################
module "nb-psc-171lb" {
  source  = "optimus.bupa.com/BGUK/apigee-x-psc-buk/module"
  version = "1.0.6"

  project_id                = "techportal-dev-490018"
  peering_network_project_id = "gfvpchub-939368"
  ilb_network               = data.google_compute_network.vpc.id
  region                    = "europe-west2"
  ilb_name_prefix           = "proxy-dev-europewest2"  # REPLACE if needed
  psc_neg                   = module.psc_neg.psc_neg_self_link
}

############################################################
# PSC NEG Resource (if module not used)
############################################################
resource "google_compute_region_network_endpoint_group" "psc_neg" {
  project                = var.project_id
  name                   = var.name
  region                 = var.region
  network                = var.network
  subnetwork             = var.subnetwork
  network_endpoint_type  = var.network_endpoint_type
  psc_target_service     = var.psc_target_service
  producer_port          = var.producer_port

  lifecycle {
    create_before_destroy = true
  }
}

############################################################
# Outputs
############################################################
output "psc_neg_self_link" {
  description = "Self-link of the PSC Network Endpoint Group"
  value       = google_compute_region_network_endpoint_group.psc_neg.self_link
}

output "psc_neg_name" {
  description = "The name of the PSC Network Endpoint Group"
  value       = google_compute_region_network_endpoint_group.psc_neg.name
}

output "psc_neg_network" {
  description = "The network of the PSC Network Endpoint Group"
  value       = google_compute_region_network_endpoint_group.psc_neg.network
}

output "psc_neg_subnetwork" {
  description = "The subnetwork of the PSC Network Endpoint Group"
  value       = google_compute_region_network_endpoint_group.psc_neg.subnetwork
}

output "psc_neg_network_endpoint_type" {
  description = "The type of the PSC Network Endpoint Group"
  value       = google_compute_region_network_endpoint_group.psc_neg.network_endpoint_type
}

output "psc_neg_psc_target_service" {
  description = "The PSC target service of the PSC Network Endpoint Group"
  value       = google_compute_region_network_endpoint_group.psc_neg.psc_target_service
}

############################################################
# Variables
############################################################
variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the PSC NEG."
  type        = string
}

variable "network" {
  description = "Network to deploy to. Only one of network or subnetwork should be specified."
  type        = string
  default     = null
}

variable "region" {
  description = "The GCP region for PSC NEG."
  type        = string
}

variable "subnetwork" {
  description = "Subnet to deploy to. Only one of network or subnetwork should be specified."
  type        = string
  default     = null
}

variable "network_endpoint_type" {
  description = "Type of network endpoint group (e.g., PRIVATE_SERVICE_CONNECT)."
  type        = string
}

variable "psc_target_service" {
  description = "Use existing PSC target service from respective Apigee runtime instance."
  type        = string
}

variable "producer_port" {
  description = "The PSC producer port to use when consumer PSC NEG connects to a producer."
  type        = number
  default     = 443
}
