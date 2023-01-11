# Source: https://gist.github.com/bc1188d2a4b8d5295890e9c5438b9ce4

#################################
# 10 Must-Have Kubernetes Tools #
# https://youtu.be/CB79eTFbR0w  #
#################################

# Additional Info:
# - How To Replace Docker With nerdctl And Rancher Desktop: https://youtu.be/evWPib0iNgY
# - k9s Kubernetes UI - A Terminal-Based Vim-Like Kubernetes Dashboard: https://youtu.be/boaW9odvRCc
# - Argo CD - Applying GitOps Principles To Manage A Production Environment In Kubernetes: https://youtu.be/vpWQeoaiRM4
# - Flux CD v2 With GitOps Toolkit - Kubernetes Deployment And Sync Mechanism: https://youtu.be/R6OeIgb7lUI
# - How To Shift Left Infrastructure Management Using Crossplane Compositions: https://youtu.be/AtbS1u2j7po
# - Cloud-Native Apps With Open Application Model (OAM) And KubeVela: https://youtu.be/2CBu6sOTtwk
# - Kubernetes-Native Policy Management With Kyverno: https://youtu.be/DREjzfTzNpA
# - How to apply policies in Kubernetes using Open Policy Agent (OPA) and Gatekeeper: https://youtu.be/14lGc7xMAe4
# - GitHub CLI - How to manage repositories more efficiently: https://youtu.be/BII6ZY2Rnlc

#########
# Setup #
#########

# Create a Kubernetes cluster with an Ingress (do NOT use a local cluster)
# The demo is using AWS.
# You might need to make "small" modifications to reproduce it in other providers.

# Replace `[...]` with the external IP of the Ingress service
export INGRESS_HOST=[...]

# Replace `nginx` with the Ingress class if not using NGINX
export INGRESS_CLASS=nginx

# Watch https://youtu.be/BII6ZY2Rnlc if you are not familiar with GitHub CLI
gh repo fork vfarcic/k8s-tools-demo --clone

cd k8s-tools-demo

export REPO_URL=$(\
    git config --get remote.origin.url)

cat orig/prometheus.yaml \
    | sed -e "s@alert-manager.acme.com@alert-manager.$INGRESS_HOST.nip.io@g" \
    | sed -e "s@prometheus.acme.com@prometheus.$INGRESS_HOST.nip.io@g" \
    | sed -e "s@ingressClassName: .*@ingressClassName: $INGRESS_CLASS@g" \
    | tee production/prometheus.yaml

cat orig/grafana.yaml \
    | sed -e "s@grafana.acme.com@grafana.$INGRESS_HOST.nip.io@g" \
    | tee production/grafana.yaml

cat orig/loki.yaml \
    | sed -e "s@loki.acme.com@loki.$INGRESS_HOST.nip.io@g" \
    | tee production/loki.yaml

cat argocd/app.yaml \
    | sed -e "s@repoURL: .*@repoURL: $REPO_URL@g" \
    | tee argocd/app.yaml

cp orig/apps.yaml production/.

git add .

git commit -m "Corrections"

git push

#############
# Setup AWS #
#############

# Replace `[...]` with your access key ID`
export AWS_ACCESS_KEY_ID=[...]

# Replace `[...]` with your secret access key
export AWS_SECRET_ACCESS_KEY=[...]

echo "[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
" >aws-creds.conf

#############################################
# Operate With kubectl, kubectx, And kubens #
#############################################

kubectl get namespaces

kubectl ctx

# Replace `[...]` with the context of the remote cluster
kubectl ctx [...]

kubectl get pods

kubectl get namespaces

kubectl ns kube-system

kubectl get pods

kubectl create namespace crossplane-system

kubectl ns crossplane-system

kubectl create secret generic aws-creds \
    --from-file creds=./aws-creds.conf

#############################################
# Define Third-Party Applications With Helm #
#############################################

kubectl ctx rancher-desktop

helm repo add crossplane-stable \
    https://charts.crossplane.io/stable

helm repo update

helm upgrade --install \
    crossplane crossplane-stable/crossplane \
    --namespace crossplane-system \
    --create-namespace \
    --wait

helm list

kubectl ns crossplane-system

helm list

####################
# Observe With k9s #
####################

k9s

# From k9s: `:q`

###################################
# Syncronize With Argo CD or Flux #
###################################

kubectl ctx

# Replace `[...]` with the context of the remote cluster
kubectl ctx [...]

helm repo add argo \
    https://argoproj.github.io/argo-helm

helm repo update

helm upgrade --install \
    argocd argo/argo-cd \
    --namespace argocd \
    --create-namespace \
    --set server.ingress.hosts="{argo-cd.$INGRESS_HOST.nip.io}" \
    --set server.ingress.ingressClassName=$INGRESS_CLASS \
    --values argocd/values.yaml \
    --wait

cat argocd/app.yaml

kubectl apply --filename argocd/app.yaml

echo "http://argo-cd.$INGRESS_HOST.nip.io"

# Open it in a browser

# Use `admin` as a user and `admin123` as the password

############################################
# Manage TLS Certificates With CertManager #
############################################

cat production/cert-manager.yaml

cat issuers/cluster-issuer.yaml

#########################################
# Manage Infrastructure With Crossplane #
#########################################

cat production/apps.yaml

cat apps/silly-demo-db.yaml

k9s

# From k9s: `:rdsinstance`

# From k9s: `:dbsubnetgroup`

# From k9s: `:q`

kubectl get managed

###################################################
# Manage Applications With Crossplane Or KubeVela #
###################################################

cat apps/silly-demo.yaml

k9s

# From k9s: `:ns` and choose `production`

# From k9s: `:deploy`

# From k9s: `:service`

# From k9s: `:ing`

# From k9s: `:q`

###########################################################
# Collect And Observe Metrics With Prometheus And Grafana #
###########################################################

cat production/prometheus.yaml

k9s

# From k9s: `:ns` and choose `monitoring`

# From k9s: `:ing`

# Open `prometheus-server` `HOST` in a browser

# Open `prometheus-alertmanager` `HOST` in a browser

# From k9s: `:q`

cat production/grafana.yaml

k9s

# From k9s: `:ns` and choose `monitoring`

# From k9s: `:ing`

# Open `grafana` `HOST` in a browser

# From k9s: `:q`

kubectl --namespace monitoring \
    get secret grafana \
    --output jsonpath="{.data.admin-password}" \
    | base64 --decode

# User: admin; Password: the output from the previous command

# Open https://grafana.com/grafana/dashboards

# Add Prometheus datasource in Grafana
# URL: http://prometheus-server

# Import dashboard 6417

###################################################
# Collect And Observe Logs With Loki And Promtail #
###################################################

cat production/loki.yaml

# Add Loki datasource in Grafana
# URL: http://loki:3100

# Import dashboard 13407

################################################################################
# Manage Policies Through Admission Controllers With Kyverno Or OPA Gatekeeper #
################################################################################

cat production/kyverno.yaml

###########
# Destroy #
###########

rm production/apps.yaml

git add .

git commit -m "Remove apps"

git push

kubectl get managed

# Wait until all the resources are deleted (excluding `object` and `release`)

# Reset or destroy the clusters
