
### Primary Resources deployed by this code
`VPC with 3 subnets(Public,Private and Intra), bastion, mongodb, secretsmanager for mongo secret, EKS, EKS-ALB addon, OIDC Provider for RBAC, S3 Bucket(Public), Cluster Role for Pods `
 ` Modules and Git Repos are locally downloaded to avoid any git pinning and custom code changes`
 
### Process 

Infra:- 

1) Create a bucket for terraform tfstate and updte it in provider-backend.tf (can be automated)
2) validate lab-variables.auto.tfvars with required inputs
3) ` Terraform init`
   `Terraform apply`

## EKS

### Make sure you have eksctl and kubectl 
`curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version`



## Testing
1) Update kubeconfig
`aws eks update-kubeconfig --region us-west-2 --name eks-lab`

2) Apply yaml config to deploy web app  - port 80
` update security group ID in annotation (tem workaround) with name alb_security_group_eks_custom from vpc security groups- alb.ingress.kubernetes.io/security-groups: sg-02c626328ebe4b8aa`
`kubectl apply -f eks/2048_full.yaml`
`kubectl get ingress/ingress-2048 -n game-2048`

#### https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html


3) privileged container deployment 

`kubectl apply -f eks/shell-demo.yaml`
`kubectl exec --stdin --tty shell-demo -- /bin/bash`

The roles defined in lab-eks-pod-cluster-admin aka eks-service-account-role have s3:GetBucket", "s3:GetObject", "s3:PutObject access on * 
### Example test - 
`apt-get update`
`apt-get install -y awscli`
`touch test-rbac`
`aws s3api put-object --bucket test44242 --key test-rbac --body ./test-rbac`
####  lab-eks-pod-cluster-admin service account was mapped toa custom cluster-admin role with admin privilages 
### Test 
`kubectl exec --stdin --tty shell-demo -- /bin/bash`
`apt-get update`
`apt-get install -y curl`
`curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`
`install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl`


3) helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/jenkins

###  Future Improvements
1) Currently Code is not configured with CI/CD, but can be easily ported to Cloud*
2) ec2-ley is required and can be created manually. Though its is not mandatory and can use sesion manager to login to bastion 
3) container to mongodb connection, which is optonal was not configured. Priority given to IAC, basic Security that was not defined per lab excercise. This can be connected based on app
4) Tags can be appended to IAM and S3 to support multi env deploymenet within same AWS Account


### Troubleshooting commands

`aws secretsmanager delete-secret --secret-id mongoadminUserpassword --force-delete-without-recovery --region us-west-2`

### Secrets manager should be in place before mongo and bastion works

### Login to bastion using ssm 

`aws ssm start-session --target i-04103fb0104ed83e7 --region us-west-2`
sudo su - ec2-user 


### Modules refrenced and used from 
1) https://github.com/terraform-aws-modules/terraform-aws-eks
2) https://github.com/bootlabstech/terraform-aws-fully-loaded-eks-cluster
3) https://github.com/KPRepos/terraform-ecs-app


## Userdata scripts

1) templates/app_user_data.sh = This is mongodb userdata that creates an admin password retreived from secrets manager and creates a dummy collection of data such that backups can work.

2) templates/bastion_user_data.sh = This is for bastion ec2, which will create a cron job to connect to mongodb and initaie backup, mongodb password info will be retrieved from secrets manager.
