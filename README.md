# terraform-gcp
These scripts will create a simple infrastructure in GCP for testing/learning purposes. The infrastructure consists of a GKE cluster with two separate namespaces for Jenkins Master and workers(Clouds). There are also two simple VM instances which will be used in Ansible inventory.
 
Before starting, please create a GCP project, enable billing, install gcloud CLI and create a service account with following IAM roles (those are quite wide because we need access to many cloud resources in the project. Please remember to keep your private key safe):
- Artifact Registry Administrator
- Compute Admin
- Compute Network Admin
- Kubernetes Engine Admin
- Security Admin
- Service Account Admin
- Service Account User
- Storage Admin
There will be the domain name required for deploying a ssl certificate.
 
1. Clone the repository, set the GOOGLE_APPLICATION_CREDENTIALS environment variable, to path pointing to your service account key. This allows you to authenticate to your GCP cloud environment, more details: (https://cloud.google.com/docs/authentication/getting-started#setting_the_environment_variable)
2. Install gcloud CLI
3. Create Cloud Storage Bucket for Terraform backend
4. In main.tf, set the bucket name in the backend configuration
5. Set all required variables in terraform.tfvars, and put your service account email in gke.tf file
6. Set the IP address for authorized networks in terraform.tfvars file (it should be public IP address of your workstation in this use case)
7. Run the commands: terraform plan and terraform apply
8. Authenticate into your GKE cluster. Run the command: gcloud container clusters get-credentials primary-gke --region <CLUSTER_REGION>'
9. Create HTTP(S) External Load Balancer and TLS certificate, with redirection http->https using Ingress. Put your domain name in place of <FQDN> in the ingress.yaml. Run the command: kubectl apply -f ingress.yaml (it can take up to 24 hours before ssl certificate is fully provisioned)
10. Create Docker image with Ansible in Artifacts Registry. Go to the folder docker in your terminal and run the command: gcloud builds submit --region=<CLUSTER_REGION> --tag <CLUSTER_REGION>-docker.pkg.dev/<PROJECT_ID>/jenkins/ansible
11. Set the correct image location in jenkins-scripts/jenkinsfile_ansible
12. Get the jenkins password, use admin as login in your browser. To get the admin password run the command: printf $(kubectl get secret --namespace jenkins-namespace jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
13. Go to Configure Clouds section in Jenkins, define the namespace to jenkins-build
14. Get the service account token for the SA created in jenkins-build namespace and store it in the cloud configuration using the secret text option (the same window as in the previous step). Run the command: kubectl describe secret $(kubectl describe serviceaccount jenkins-build --namespace=jenkins-build | grep Token | awk '{print $2}') --namespace=jenkins-build
15. Click Check connection and make sure it succeeded
16. Go to Manage Plugins section in Jenkins and install Ansible plugin
17. Login to the ansible-client-0, create a new user named 'jenkins'. Run the command: sudo useradd -m jenkins
18. Switch to jenkins user. Run the command: sudo su jenkins
19. Generate ssh keys. Run the command: ssh-keygen -t ed25519
20. Create the authorized_keys file and store the public key into it. Go to the /home/jenkins/.ssh in your terminal and run the command: cat id_ed25519.pub >> authorized_keys
21. Repeat the steps (17-20) in your second (ansible-client-1) VM. Use the same keys (this pair will be used for both VMs, just for Ansible inventory testing purposes)
22. Copy the private key from the id_ed25519 file and create jenkins secret named gcp_vm using SSH Username with private key
23. Create new Pipeline in Jenkins and copy pipeline script from jenkins-scripts/jenkinsfile_ansible
24. Fork the https://github.com/DamianPawlow/ansible.git repository into your own and change the URL in the jenkins-scripts/jenkinsfile_ansible
25. Add the correct IPs (your VMs) in the inventory.txt file in your forked repository
26. Create the pipeline in the Jenkins using Groovy script from jenkins-scripts/jenkinsfile_ansible
27. Start the pipeline, and check /tmp/ folders in your VMs. There should be the created_from_the_jenkins_pipeline files visible