terraform {
  required_version = "1.15.3"
  backend "gcs" {
  }
  required_providers {
    # google = {
    #   source  = "hashicorp/google"
    #   version = "6.21.0"
    # }
    # google-beta = {
    #   source  = "hashicorp/google-beta"
    #   version = "6.21.0"
    # }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

