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
# Add kubernetes dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

# Install dashboard with skip login enabled
cat <<EOF > dashboard-values.yaml
extraArgs:
  - --enable-skip-login
  - --enable-insecure-login
  - --disable-settings-authorizer
service:
  type: NodePort
EOF

helm install testing-dashboard kubernetes-dashboard/kubernetes-dashboard -f dashboard-values.yaml

# Create dashboard admin access
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard-admin
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: default
EOF

# Create service account with cluster-admin privileges
kubectl create serviceaccount nicole -n default
kubectl create clusterrolebinding nicole-admin-binding \
    --clusterrole=cluster-admin \
    --serviceaccount=default:nicole

# To access dashboard:
echo "Access dashboard using:"
echo "kubectl port-forward svc/testing-dashboard-kubernetes-dashboard 8443:443 --address 0.0.0.0"
echo "Then visit https://your-server-ip:8443"

helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl create namespace cert-manager
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.9.1 --set installCRDs=true
# Create a token for the service account
# kubectl create token nicole

# kubectl create namespace traefik
# helm repo add traefik https://traefik.github.io/charts
# helm install traefik traefik/traefik --namespace traefik --values k8s/helm-traefik-values.yaml
# helm install traefik traefik/traefik 




kubectl create namespace kessler-prod
kubectl create namespace kessler-nightly


# manually do some magic to copy k8s/secret.yml
cd /mycorrhiza/infra
helm install kessler-nightly ./helm/ -f helm/values-nightly.yaml






