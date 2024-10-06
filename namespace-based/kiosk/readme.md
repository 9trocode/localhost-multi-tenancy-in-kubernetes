 # Using Kiosk for soft multi tenancy 

 Kiosk during it's time was the popular go to for Multi Tenancy in Kubernetes but it's no longer actively maintained. My one cent about kiosk, the naming convention should be more relatable & easier to understand

 Learn More about KiOSK here [Manual Setup](https://github.com/loft-sh/kiosk/blob/master/README.md)


## Extra: User Management & Authentication
**kiosk does **not** provide a built-in user management system.** 

To manage users in your cluster, you can either use vendor-neutral solutions such as [dex](https://github.com/dexidp/dex) or [DevSpace Cloud](https://devspace.cloud/) or alternatively, if you are in a public cloud, you may be able to use provider-specific solutions such as [AWS IAM for EKS](https://docs.aws.amazon.com/eks/latest/userguide/security-iam.html) or [GCP IAM for GKE](https://cloud.google.com/kubernetes-engine/docs/how-to/iam).

### Using ServiceAccounts For Authentication
If you like to use ServiceAccounts for a small and easy to set up authentication and user management, you can use the following instructions to create new users / kube-configs.

> Use `bash` to run the following commands.

#### 1. Create a ServiceAccount
```bash
USER_NAME="john"
kubectl -n kiosk create serviceaccount $USER_NAME
```

#### 2. Create Kube-Config For ServiceAccount
```bash
# If not already set, then:
USER_NAME="john"

KUBECONFIG_PATH="$HOME/.kube/config-kiosk"

kubectl config view --minify --raw >$KUBECONFIG_PATH
export KUBECONFIG=$KUBECONFIG_PATH

CURRENT_CONTEXT=$(kubectl config current-context)
kubectl config rename-context $CURRENT_CONTEXT kiosk-admin

CLUSTER_NAME=$(kubectl config view -o jsonpath="{.clusters[].name}")
ADMIN_USER=$(kubectl config view -o jsonpath="{.users[].name}")

SA_NAME=$(kubectl -n kiosk get serviceaccount $USER_NAME -o jsonpath="{.secrets[0].name}")
SA_TOKEN=$(kubectl -n kiosk get secret $SA_NAME -o jsonpath="{.data.token}" | base64 -d)

kubectl config set-credentials $USER_NAME --token=$SA_TOKEN
kubectl config set-context kiosk-user --cluster=$CLUSTER_NAME --user=$USER_NAME
kubectl config use-context kiosk-user

# Optional: delete admin context and user
kubectl config unset contexts.kiosk-admin
kubectl config unset users.$ADMIN_USER

export KUBECONFIG=""
```

#### 3. Use ServiceAccount Kube-Config
```bash
# If not already set, then:
KUBECONFIG_PATH="$HOME/.kube/config-kiosk"

export KUBECONFIG=$KUBECONFIG_PATH

kubectl ...
```

#### 4. Reset Kube-Config
```bash
export KUBECONFIG=""

kubectl ...
```

<br>