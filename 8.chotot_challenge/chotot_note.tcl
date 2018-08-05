"-----------------------------------------------------"
"               Global variable                       "
"-----------------------------------------------------"
bucket_name=bucket.chotot.vpc
CHOTOT_DNS_ZONE=chotot.vpc
CHOTOT_CLUSTER_NAME=cluster.chotot.vpc


"-----------------------------------------------------"
"   Create S3 bucket for storing state of KOPS        "
"-----------------------------------------------------"

#Create bucket to store state of KOPS
aws s3api create-bucket --bucket ${bucket_name} --create-bucket-configuration LocationConstraint=us-west-2

aws s3api put-bucket-versioning --bucket ${bucket_name} --versioning-configuration Status=Enabled

#define env var for kops_state_store
export KOPS_STATE_STORE=s3://${bucket_name}


"-----------------------------------------------------"
"   Deployment cluster using Kubernetes        "
"-----------------------------------------------------"
kops create cluster \
--cloud=aws --zones=us-west-2a \
--node-count=2 \
--node-size=t2.micro --master-size=t2.micro \
--dns-zone=${CHOTOT_DNS_ZONE} --dns private \
--name=${CHOTOT_CLUSTER_NAME}

#Update details before actually deploy
kops edit cluster --name ${CHOTOT_CLUSTER_NAME}

#Actually deploy
kops update cluster --name ${CHOTOT_CLUSTER_NAME} --yes

---
Suggestions:
 * validate cluster: kops validate cluster
 * list nodes: kubectl get nodes --show-labels
 * ssh to the master: ssh -i ~/.ssh/id_rsa admin@api.cluster.chotot.vpc

# Delete the whole stack
kops delete cluster --name=${CHOTOT_CLUSTER_NAME} --yes

Note: if --dns public : FAIL as not registered any domain on public DNS (like google)
           --dns private: command in (*) must be execute in local private PVC machine


"-----------------------------------------------------"
"       Deployment containers on cluster              "
"-----------------------------------------------------"
kubectl run sample-nginx --image=nginx --replicas=2 --port=80
kubectl get pods
kubectl get deployments

# Expose the deployments as service. This will create an ELB in front of those 2 containers and allow us
# to publicly access them
kubectl expose deployment sample-nginx --port=80 --type=LoadBalancer
kubectl get services -o wide




