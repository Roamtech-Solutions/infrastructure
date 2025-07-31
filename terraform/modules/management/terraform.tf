terraform {
  required_version = "1.12.1"
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
    # github = {
    #   source  = "integrations/github"
    #   version = "6.5.0"
    # }
  }
}

