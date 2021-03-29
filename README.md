# Traefik Cert-manager and Let'Encrypt

This project allows you to install Traefik and cert-manger then deploy a website(whoami). After setup, you would finally have a website that you can access with HTTPS over SSL/TLS

## Note:
This project has been tested on a GKE cluster, but can work on any cluster.

## Requirements
With the command helm version, make sure that you have:
* Helm v3 [installed](https://helm.sh/docs/intro/)
## Provider
* Helm
* Kubernetes

## Create GKE cluster
```
gcloud container clusters create cluster_name --project project_name --zone zone_name
```

## Connect to the Cluster
* Get the kubeConfig file of the cluster

```
gcloud container clusters get-credentials cluster_name --zone zone_name --project project_name
```

I used Helm and kubernetes provider in Terraform to install and configure Traefik, Cert-manager

## Installing Traefik
Check in `value.yaml` the custom configurations

### Exposing the Traefik dashboard
The dashboard access could be achieved through a port-forward
```
kubectl -n traefik port-forward $(kubectl -n traefik get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000
```
Now head to http://127.0.0.1:9000/dashboard/ and you should be able to see the Traefik dashboard

## Manager DNS
Configure your DNS provider to point to your Traefik service

## Installing Cert-manager
Check in `value.yaml` the custom configurations

You should see three pods running: `cert-manager`, `cert-manager-cainjector` and `cert-manager-webhook`.

## TLS and HTTPS Access
I managed the certificate in order to access the traefik dasboard service in HTTPS.
The certificate is managed by LETSENCRYPT and CERTMANAGER.

[How to Manage Cert manager ?](https://cert-manager.io/docs/installation/kubernetes/)
[How to use letsencrypt ?](https://github.com/jetstack/cert-manager)

### Create ClusterIssuer and Certificate resource
Check `cluster-issuer-*.yaml` file to have example

### Exposing the Traefik dashboard
You can access the dasboard in your owner dns.
Check `ingress-route.yaml` file to have example. Executed objects in order

## Usage
NB: Manage your DNS zone and dns records like this:
```
* for zone **example.com**, we have two dns records:

  nginx.example.com ---> A ---> @ip_ingress_controller

  *.demo.example.com ---> CNAME ----> nginx.example.com
```

```
cd traefik-cert_manager/tools/staging/cert-manager
terraform init
terraform plan
terraform apply
kubectl apply -f cluster-issuer-staging.yaml
```

```
cd traefik-cert_manager/tools/staging/traefik
terraform init
terraform plan
terraform apply
kubectl apply -f certificate.yaml
```

## Check a certifficate
```
kubectl -n traefik describe secrets traefik-cert
```
You will have this type of result :
```
Name:         traefik-cert
Namespace:    traefik
Labels:       <none>
Annotations:  cert-manager.io/alt-names: localhost.test.k8s.tlmq.fr
              cert-manager.io/certificate-name: traefik-cert
              cert-manager.io/common-name: localhost.test.k8s.tlmq.fr
              cert-manager.io/ip-sans: 
              cert-manager.io/issuer-group: 
              cert-manager.io/issuer-kind: ClusterIssuer
              cert-manager.io/issuer-name: letsencrypt-prod
              cert-manager.io/uri-sans: 

Type:  kubernetes.io/tls

Data
====
tls.crt:  3456 bytes
tls.key:  1679 bytes
```

## References
* [Exemple of the configured article How to easily get SSL/TLS](https://medium.com/@alexgued3s/how-to-easily-ish-471307f276a9)
* [Reference docs certificate](https://docs.cert-manager.io/en/release-0.11/reference/certificates.html)
* [Stack overflow test a clusterIssuer](https://stackoverflow.com/questions/58423312/how-do-i-test-a-clusterissuer-solver/58436097?noredirect=1#comment103215785_58436097)
