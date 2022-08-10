In this repo you can find the declarative configurations for Jenkins controller stored in private GKE cluster.
Most of the configuration is done using Terraform. TLS certificate, Ingress and FrontendConfig (redirect HTTP->HTTPS) are stored in Kubernetes YAML manifest.
