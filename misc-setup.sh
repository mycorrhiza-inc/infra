set -euo pipefail

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


cd /mycorrhiza
helm list


git clone https://github.com/mycorrhiza-inc/kessler
# Change to the infra directory.

# Install k8s dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm install testing-dashboard kubernetes-dashboard/kubernetes-dashboard
# To make acessible publicly
# kubectl -n default port-forward svc/testing-dashboard-kong-proxy 8443:443 --address 0.0.0.0

# Create a service account with cluster-admin privileges
kubectl create serviceaccount nicole -n default
kubectl create clusterrolebinding nicole-admin-binding \
    --clusterrole=cluster-admin \
    --serviceaccount=default:nicole

# helm repo add jetstack https://charts.jetstack.io
# helm repo update
# kubectl create namespace cert-manager
# helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.9.1 --set installCRDs=true
# Create a token for the service account
# kubectl create token nicole

# kubectl create namespace traefik
# helm repo add traefik https://traefik.github.io/charts
# helm install traefik traefik/traefik --namespace traefik --values k8s/helm-traefik-values.yaml
# helm install traefik traefik/traefik 




kubectl create namespace kessler


# manually do some magic to copy k8s/secret.yml
cd /mycorrhiza/infra
# helm install kessler ./helm/ -f helm/values-prod.yaml --namespace kessler






