set -euo pipefail

helm list

cd / 
mkdir mycorrhiza
cd mycorrhiza
git clone https://github.com/mycorrhiza-inc/kessler
cd kessler
git fetch --all
# Temporary since I dont want to fuck up by pushing all this stuff to main.
git switch improving-reliability-3

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
helm install kessler ./k8s -f k8s/values-prod.yaml --namespace kessler






