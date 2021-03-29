##########################################################
##                                                      ##
##           INSTALLATION CERT-MANAGER VIA HELM         ##
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

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    annotations = {
      name      = "cert-manager"
    }
    name        = "cert-manager"
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  values = [
   file("values.yaml")
  ]

  namespace = kubernetes_namespace.cert-manager.metadata[0].name
  depends_on = [ kubernetes_namespace.cert-manager ]
}