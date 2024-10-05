 # Using KubeZoo for soft multi tenancy 

 Kubezoo seems to be the next easiest one to manage after capsule the setup is easier but could be better standardized using HELM but it comes with 0 management while still getting like a virtual cluster to share [Manual Setup](https://github.com/kubewharf/kubezoo/blob/8a3a05f83cfe0576c24d896d898683001bd833e5/docs/manually-setup.md)


 ### Create a tenant

```console
$ kubectl apply -f tenant.yaml --context zoo
tenant.tenant.kubezoo.io/team-sre019-dev-playground created
```

The tenant name must be a valid 6-character [RFC 1123][rfc1123-label] DNS label prefix (`[A-Za-z0-9][A-Za-z0-9\-]{5}`).

### Get the kubeconfigs of the tenant

```console
$ kubectl get tenant team-sre019-dev-playground --context zoo -o jsonpath='{.metadata.annotations.kubezoo\.io\/tenant\.kubeconfig\.base64}' | base64 --decode > 111111.kubeconfig
```