##########################################################
##                                                      ##
##             INSTALLATION TRAEFIK VIA HELM            ##
##                                                      ##
##########################################################

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "gke_infrastructure-176114_europe-west1-c_cluster-testing"
}

resource "kubernetes_namespace" "traefik" {
  metadata {
    annotations = {
      name      = "traefik"
    }
    name        = "traefik"
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"

  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"

  values = [
   file("values.yaml")
  ]

  namespace = kubernetes_namespace.traefik.metadata[0].name
  depends_on = [ kubernetes_namespace.traefik ]
}