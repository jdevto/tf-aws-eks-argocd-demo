# tf-aws-eks-argocd-demo

Terraform demo for Amazon EKS with Argo CD GitOps.

## What this demo does

- **Terraform** provisions:
  - VPC (from local module `modules/vpc`)
  - EKS (from local module `modules/eks`, using native AWS resources)
  - Argo CD (installed via Helm) + **bootstraps only the Argo CD `Application` CR**
- **Argo CD** then fully manages **two sample web apps**:
  - **demo-web** (nginx-based) from `k8s-app/nginx-demo`
  - **go-demo** (Go-based with rate limiting) from `k8s-app/go-demo`
  - Both include `Deployment` and `Service` type `LoadBalancer` (AWS ELB created/managed by Kubernetes)

## Repo structure

```text
.
├── main.tf
├── providers.tf
├── versions.tf
├── variables.tf
├── outputs.tf
├── locals.tf
├── modules
│   ├── vpc
│   ├── eks
│   └── argocd
└── k8s-app
    ├── nginx-demo
    └── go-demo
```

## Prereqs

- Terraform >= 1.6
- AWS credentials configured (env vars, shared config, or SSO)
- `kubectl`
- `aws` CLI

## Configure the Git repo URL (important)

Argo CD needs a real Git repo URL that contains this repo content.

Recommended: pass it on apply:

```bash
terraform apply -var='repo_url=https://github.com/<you>/<this-repo>.git'
```

The Argo CD Applications will point at `k8s-app/nginx-demo` and `k8s-app/go-demo` in that repo.

## Run the demo

```bash
terraform init
terraform apply
```

Then configure kubectl (adjust region/name if you changed defaults in `variables.tf`):

```bash
aws eks update-kubeconfig --region ap-southeast-2 --name eks-argocd-demo
kubectl get nodes
```

## Get Argo CD UI URL and Credentials

Get the Argo CD server LoadBalancer URL:

```bash
kubectl get svc -n argocd argocd-server
```

Get the Argo CD admin credentials via Terraform outputs:

```bash
terraform output argocd_username
terraform output argocd_password
```

Or get both at once:

```bash
echo "Username: $(terraform output -raw argocd_username)"
echo "Password: $(terraform output -raw argocd_password)"
```

## Verify the sample app LoadBalancers

```bash
# Check nginx-based demo-web
kubectl get svc demo-web

# Check Go-based go-demo (with rate limiting: 100 req/min)
kubectl get svc go-demo
```

## Clean destroy (including LBs)

```bash
terraform destroy
```

Because Terraform bootstraps the Argo CD `Application` (and sets the Argo finalizer), Argo CD will prune the app resources (and the AWS ELB created by the Service) before Argo CD/EKS/VPC are destroyed.

If you hit `Kubernetes cluster unreachable` during destroy, do a 2-phase destroy (addons first, then infra):

```bash
terraform destroy -target=module.argocd -auto-approve
terraform destroy -auto-approve
```

Note: the Application is applied/deleted via `kubectl` from Terraform (to avoid CRD planning issues), so `terraform apply/destroy` should be run from a machine that has `aws` + `kubectl` available and valid AWS credentials.
