# Ingress Controller

Reference Documentations:
https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.10/deploy/installation/
https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/

OpenIDConnect OAuth 2.0
```
eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster expense-dev \
    --approve
```


Installing Policies
```
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.10.0/docs/install/iam_policy.json
```

```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json
```


IAM authorization and Permissions

```
eksctl create iamserviceaccount \
--cluster=expense-dev \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::022499022353:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--region us-east-1 \
--approve
```

Install Helm:
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
to check, helm version
```

Installing drivers via helm chart
```
helm repo add eks https://aws.github.io/eks-charts
```

Final Installation
```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=expense-dev --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
```

checking the installation:
```
helm list -n kube-system
kubectl get pods -n kube-system
kubectl get svc -n kube-system

If installed successfully you are able to see aws-load-balancer-controller-xyz123
```

curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.10.0/docs/install/iam_policy.json