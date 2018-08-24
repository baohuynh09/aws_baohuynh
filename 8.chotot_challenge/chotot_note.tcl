"-----------------------------------------------------"
"               Global variable                       "
"-----------------------------------------------------"
bucket_name=bucket.chotot.vpc
CHOTOT_DNS_ZONE=chotot.vpc
CHOTOT_CLUSTER_NAME=cluster.chotot.vpc
export KOPS_STATE_STORE=s3://${bucket_name}


# Delete the whole stack
kops delete cluster --name=${CHOTOT_CLUSTER_NAME} --yes

"-----------------------------------------------------"
"   Create S3 bucket for storing state of KOPS        "
"-----------------------------------------------------"

#Create bucket to store state of KOPS
aws s3api create-bucket --bucket ${bucket_name} --create-bucket-configuration LocationConstraint=us-west-2
aws s3api put-bucket-versioning --bucket ${bucket_name} --versioning-configuration Status=Enabled

"-----------------------------------------------------"
"   Deployment cluster using Kubernetes        "
"-----------------------------------------------------"
kops create cluster \
--cloud=aws --zones=us-west-2a \
--node-count=3 \
--node-size=t2.micro --master-size=t2.micro \
--dns-zone=${CHOTOT_DNS_ZONE} --dns private \
--name=${CHOTOT_CLUSTER_NAME}

#Update details before actually deploy
kops edit cluster --name ${CHOTOT_CLUSTER_NAME}

#Actually deploy
kops update cluster --name ${CHOTOT_CLUSTER_NAME} --yes

# Delete the whole stack
kops delete cluster --name=${CHOTOT_CLUSTER_NAME} --yes

Note: if --dns public : FAIL as not registered any domain on public DNS (like google)
         --dns private: command in (*) must be execute in local private PVC machine

"-----------------------------------------------------"
"       Deployment containers on cluster              "
"-----------------------------------------------------"
kubectl run sample-nginx --image=nginx --replicas=2 --port=80

kubectl | get        | node
        | describe   | pods -o yaml
        |            | rs
        |            | deployments
        |            | services
		|            | cluster


kubectl |            | node
        |            | pods -o yaml
        | logs       | rs
        | delete     | deployment
        |            | services -o wide
		|            | cluster

# Find the master hostname by:
kubectl cluster-info
kubectl apply -f   <path_to_the_file_online/offline>

# Expose the deployments as service. This will create an ELB in front of those 2 containers and allow us to publicly access them
kubectl expose deployment sample-nginx --port=80 --type=LoadBalancer
---> wait quite long for Loadbancing to be up

--------------------------------------------------------
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
>>> deploy UI dashboard to 'master' node

view:
https://<kubernetes-master-hostname>/ui
------------------------------------------------------------

<---- EXECUTE ON MASTER NODE ----->
"Create persistent storage for mysql database on master"
kubectl create -f local-volume.yml
kubectl get pv   (pv = persistent volume)

"Create pass for mysql"
kubectl create secret generic mysql-pass --from-literal=password=ROOT_PASSWORD


"Create mysql database"
kubectl create -f mysql-deployment.yaml
kubectl create -f wordpress-deployment.yaml

"Actually deployment"
kubectl get services ---> check service for wordpess UP ?

"Install redirection plugin"
abc.com/careers --> abc.com

-------
"TODO"
-------
- Create replica when using services (currently, only one node get deployed)
  Answer: maybe not ? since each EC2 requires 2 EBS for PersistentStorage of WP + mysql
          investigate how to do the replication
- Think about load-balancing by creating more replica of wordpress ? --> deployment.yaml ?


ip-172-20-42-59.us-west-2.compute.internal    node    < has pxctl
ip-172-20-51-205.us-west-2.compute.internal   node    < has pxctl
ip-172-20-58-59.us-west-2.compute.internal    master



# Create role for CRD
Notice: clone the latest etcd-operator repo  (https://github.com/coreos/etcd-operator)
+ cd <clone_repo>/example/rbac/
+ ./create_role

# Install etcd-operator & etcd-cluster
+ Install etcd-operator:
  kubectl create -f example/deployment.yaml
+ Check if CRD is registered (Custom Resource Definition):
  kubectl get customresourcedefinitions
+ Create an etcd cluster:
  kubectl create -f example/example-etcd-cluster.yaml
+ Get pods to check if it's ok:
  kubectl get pods

# Get Endpoint of etcd on each host
+ kb get services
+ kb describe services example-etcd-cluster
Ex:  100.96.1.15:2379,100.96.2.13:2379,100.96.2.14:2379

# Create spec files for installing portworx as a Daemonset on Kubernetes:
https://install.portworx.com/1.4/
--> get the IP etcd cluster endpoint above
+ kubectl apply -f <px_spec>
+ Check if pxctl is run on each worker nodes
  ssh admin@... "sudo /opt/pwx/bin/pxctl status"
  --> will give info about share storage by portworx

 + Delete portworx deployment:
  kubectl delete -f <px_spec>
  
# Create template volume (vol-0db5187885f23a56f)
+ export VOLUMEID=$(aws ec2 create-volume \
  --size 20 \
  --volume-type gp2 \
  --region us-west-2 \
  --availability-zone us-west-2a \
  --output text \
  --query 'VolumeId')
  
# Create a replicated volume for mysql
+ ssh admin@ip-172-20-42-59.us-west-2.compute.internal  \
  sudo /opt/pwx/bin/pxctl volume create \
  --size=5 \
  --repl=2 \
  --fs=ext4 \
  mysql-disk

