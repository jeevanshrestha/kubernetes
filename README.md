# AWS EKS Startup Setup Guide

This guide documents the process of setting up an Amazon EKS (Elastic Kubernetes Service) cluster from scratch using `eksctl`, including IAM configuration, node group creation, and EBS CSI driver installation.

## Cluster & NodeGroup Details

- Cluster Name: `jeevescluster`
- Region: `ap-southeast-2`
- Availability Zones: `ap-southeast-2a`, `ap-southeast-2b`
- NodeGroup Name: `jeeves-ng-public`
- Node Type: `t3.medium`
- SSH Key: `Kube-Demo`

## Step-by-Step Setup

### 1. Create EKS Cluster (Without Node Group)
```bash
eksctl create cluster   --name jeevescluster   --region=ap-southeast-2   --zones=ap-southeast-2a,ap-southeast-2b   --without-nodegroup
```

### 2. Associate IAM OIDC Provider
```bash
eksctl utils associate-iam-oidc-provider   --region ap-southeast-2   --cluster jeevescluster   --approve
```

### 3. Verify Cluster Creation
```bash
eksctl get cluster --region=ap-southeast-2
```

### 4. Create Node Group
```bash
eksctl create nodegroup   --cluster=jeevescluster   --region=ap-southeast-2   --name=jeeves-ng-public   --node-type=t3.medium   --nodes=2   --nodes-min=2   --nodes-max=4   --node-volume-size=20   --ssh-access   --ssh-public-key=Kube-Demo   --managed   --asg-access   --external-dns-access   --full-ecr-access   --appmesh-access   --alb-ingress-access
```

### 5. Verify Node Group
```bash
eksctl get nodegroup   --cluster=jeevescluster   --region=ap-southeast-2
```

## Amazon EBS CSI Driver Setup

### 6. Install EBS CSI Driver using kubectl
```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.44"
```

### 7. Create IAM Policy for EBS CSI Driver
Save the policy JSON file as `ebs-csi-policy.json` and then run:
```bash
aws iam create-policy   --policy-name Amazon_EBS_CSI_Driver_Policy   --policy-document file://ebs-csi-policy.json
```

### 8. Get Worker Node IAM Role
```bash
kubectl -n kube-system describe configmap aws-auth
```
Look for the node instance role name in the output, e.g.:
```
eksctl-jeevescluster-nodegroup-jee-NodeInstanceRole-6XcYAcKVCOQ7
```

### 9. Get the Policy ARN
```bash
aws iam list-policies --query "Policies[?PolicyName=='Amazon_EBS_CSI_Driver_Policy']"
```

### 10. Attach Policy to Node Role
```bash
aws iam attach-role-policy   --role-name eksctl-jeevescluster-nodegroup-jee-NodeInstanceRole-6XcYAcKVCOQ7   --policy-arn arn:aws:iam::480926032159:policy/Amazon_EBS_CSI_Driver_Policy
```

### 11. Verify Attached Policies
```bash
aws iam list-attached-role-policies   --role-name eksctl-jeevescluster-nodegroup-jee-NodeInstanceRole-6XcYAcKVCOQ7
```

## Tear Down Instructions

### Delete Node Group
```bash
eksctl delete nodegroup   --cluster=jeevescluster   --region=ap-southeast-2   --name=jeeves-ng-public   --disable-eviction
```

### Delete EKS Cluster
```bash
eksctl delete cluster   --name=jeevescluster   --region=ap-southeast-2
```

### Delete IAM Policy
```bash
aws iam delete-policy   --policy-arn arn:aws:iam::480926032159:policy/Amazon_EBS_CSI_Driver_Policy
```

## Final Notes

- Ensure that the `Kube-Demo` SSH key pair is created in the specified AWS region before running the node group setup.
- IAM OIDC provider must be associated with the cluster before installing the EBS CSI driver.
- Always verify IAM role names and ARNs before attaching or deleting policies.

## References

- https://eksctl.io/
- https://github.com/kubernetes-sigs/aws-ebs-csi-driver
- https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html
