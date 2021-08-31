terraform {
  backend "remote" {
    organization = "tecnoly"

    workspaces {
      name = "terraform-minecraft"
    }
  }
}