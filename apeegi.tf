/***********************************************
 * Deploy Apigee-X with northbound PSC
 ***********************************************/

module "apigee-x-core" {
  source                    = "optimus.bupa.com/bupa-admin-test/apigee-x/module//modules/apigee-x-core"
  version                   = "1.0.0"
  billing_type              = "PAYG"
  api_consumer_data_location = var.ax_region
  project_id                = var.project_id
  kms_keyring_name          = var.org_kms_keyring_name
  inst_disk_keyring_name    = var.inst_disk_keyring_name
  ax_region                 = var.ax_region
  apigee_environments       = var.apigee_environments
  apigee_envgroups = {
    for name, env_group in var.apigee_envgroups : name => {
      hostnames = concat(env_group.hostnames)
    }
  }
  apigee_instances          = var.apigee_instances
  network                   = var.network
  peering_network_project_id = var.peering_network_project_id
}

data "google_compute_network" "apigee_trust_vpc" {
  name    = var.apigee_trust_vpc
  project = var.peering_network_project_id
}

resource "google_compute_subnetwork" "psc_ingress_subnet" {
  name          = var.psc_ingress_subnet_name
  ip_cidr_range = var.psc_ingress_subnet_range
  region        = var.region
  network       = data.google_compute_network.apigee_trust_vpc.id
}

resource "google_compute_region_network_endpoint_group" "psc_neg" {
  project               = var.peering_network_project_id
  for_each              = var.apigee_instances
  name                  = var.psc_ingress_neg_name
  region                = var.region
  network               = data.google_compute_network.apigee_trust_vpc.id
  subnetwork            = google_compute_subnetwork.psc_ingress_subnet.self_link
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = module.apigee-x-core.instance_service_attachments[each.value.region]

  lifecycle {
    create_before_destroy = true
  }
}
