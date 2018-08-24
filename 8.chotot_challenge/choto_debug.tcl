kubectl get pods --all-namespaces
kube-system   portworx-427zl     0/1       Running   0          6m
kube-system   portworx-49h9p     0/1       Running   0          6m

# view logs of kube-system "namespace"
kubectl --namespace kube-system logs portworx-25dhw
kubectl --namespace kube-system describe pods portworx-25dhw
kubectl --namespace kube-system get pods portworx-25dhw -o yaml


		
aws efs create-file-system --creation-token $(uuid)    


-----
{
    "SizeInBytes": {
        "Value": 0
    },
    "CreationToken": "cea98976-a8e0-11e8-8981-028caf06c654",
    "Encrypted": false,
    "CreationTime": 1535254413.0,
    "PerformanceMode": "generalPurpose",
    "FileSystemId": "fs-18722bb1",
    "NumberOfMountTargets": 0,
    "LifeCycleState": "creating",
    "OwnerId": "495627566033"
}


+ aws efs create-mount-target \
        --file-system-id fs-18722bb1 \
        --subnet-id subnet-019427bc1d90f1091 \
        --security-groups sg-04b62fc4af711d0e3
-----
{
    "MountTargetId": "fsmt-6f95d4c6",
    "NetworkInterfaceId": "eni-0611c0546eaa8cc64",
    "FileSystemId": "fs-18722bb1",
    "LifeCycleState": "creating",
    "SubnetId": "subnet-019427bc1d90f1091",
    "OwnerId": "495627566033",
    "IpAddress": "172.20.63.77"
}

check until LifeCycleState=available
+ aws efs describe-mount-targets --file-system-id fs-18722bb1



aws ec2 authorize-security-group-ingress --group-id sg-04b62fc4af711d0e3 --protocol tcp --port 2049 --source-group sg-04b62fc4af711d0e3 --group-owner 495627566033


+ vi efs-provisioner.yaml --> 
    roleRef:
	 kind: ClusterRole
	 #name: efs-provisioner-runner <-- this one does not have permission 
	 #								 to get endpoint in name space kube-system
	 name: cluster-admin   

+ kubectl apply -f efs-provisioner.yaml
+ kubectl get pvc   
  --> efs STATUS is Bound -> ok


"-----------------------------------------------"
"                SECOND EFS						"
"-----------------------------------------------"
aws efs create-file-system --creation-token $(uuid)
{
    "SizeInBytes": {
        "Value": 0
    },
    "CreationToken": "acb15680-a95a-11e8-abbc-024ae44c014a",
    "Encrypted": false,
    "CreationTime": 1535306754.0,
    "PerformanceMode": "generalPurpose",
    "FileSystemId": "fs-94eab33d",
    "NumberOfMountTargets": 0,
    "LifeCycleState": "creating",
    "OwnerId": "49"
}


+ aws efs create-mount-target \
        --file-system-id fs-94eab33d \
        --subnet-id subnet-019427bc1d90f1091 \
        --security-groups sg-04b62fc4af711d0e3
---
{
    "MountTargetId": "fsmt-d0bafb79",
    "NetworkInterfaceId": "eni-0d356cae5104b5b0c",
    "FileSystemId": "fs-94eab33d",
    "LifeCycleState": "creating",
    "SubnetId": "subnet-019427bc1d90f1091",
    "OwnerId": "495627566033",
    "IpAddress": "172.20.59.233"
}


+ aws ec2 authorize-security-group-ingress --group-id sg-04b62fc4af711d0e3 --protocol tcp --port 2049 --source-group sg-04b62fc4af711d0e3 --group-owner 495627566033




"-------------INGRESS---------------"
kb create -f install/common/ns-and-sa.yaml
kb create -f install/common/default-server-secret.yaml
kb create -f install/common/nginx-config.yaml
kb create -f install/rbac/rbac.yaml
kb create -f install/deployment/nginx-ingress.yaml
kb create -f install/service/loadbalancer-aws-elb.yaml

kb describe pods nginx-ingress-89f96847c-vpjvf --namespace=nginx-ingress
kb get ingress,nodes,pods,services,deployments --all-namespaces
kb get all --all-namespaces


kubectl exec -it <pod_name> bash --namespace=<name_space>
kubectl exec -it  nginx-ingress-89f96847c-vpjvf bash --namespace=nginx-ingress

*****
+ kb describe service wordpress

Type:                     LoadBalancer
IP:                       100.69.71.187
LoadBalancer Ingress:     adce7524fa9d911e89065020c50b4de7-90585666.us-west-2.elb.amazonaws.com
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  31422/TCP
Endpoints:                100.96.1.19:80,100.96.2.17:80
*****

NAMESPACE     NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP        PORT(S)         AGE
default       service/kubernetes        ClusterIP      100.64.0.1      <none>             443/TCP         7h
default       service/wordpress         LoadBalancer   100.69.71.187   adce7524fa9d9...   80:31422/TCP    29m
default       service/wordpress-mysql   ClusterIP      None            <none>             3306/TCP        30m
kube-system   service/kube-dns          ClusterIP      100.64.0.10     <none>             53/UDP,53/TCP   7h




---
aa5d9cbdaa9cd11e89065020c50b4de7-1851362447.us-west-2.elb.amazonaws.com
kubectl create -f namespace.yaml
kubectl create -f rbac.yaml
kubectl create -f default-backend.yaml           
kubectl create -f nginx-ingress-controller.yaml  
                 This will create a deployment whose pods will have the ports 80 and 443 open for http and https respectively. 
kubectl create -f nginx-controller-service.yaml
					This expose this deployment so that it will have External IP through which users will connect to our app
kubectl apply -f nginx-contoller-patch.yaml
kubectl get pods --namespace=ingress-nginx-config


kubectl create -f coffee.yaml
kubectl create -f tea.yaml
kubectl create -f cafe-ingress.yaml
Attach to ingress-control to verify rules
kubectl exec -it  nginx-ingress-89f96847c-vpjvf bash --namespace=nginx-ingress

cat /etc/nginx/nginx.config
	server {
		server_name cafe.example.com ;
	...    
	location /tea
	...
	location /coffee 
	...

	
	
"----------- NETWORK -------------------"
kubectl exec my-nginx-3800858182-jr4a2 -- printenv | grep SERVICE
kubectl get nodes -o yaml | grep ExternalIP -C 1
kubectl get pods -o yaml | grep podIP


kb describe service nginx-ingress --namespace=nginx-ingress
Name:                     nginx-ingress
Namespace:                nginx-ingress
Labels:                   <none>
Annotations:              service.beta.kubernetes.io/aws-load-balancer-backend-protocol=tcp
                          service.beta.kubernetes.io/aws-load-balancer-proxy-protocol=*
Selector:                 app=nginx-ingress
Type:                     LoadBalancer
IP:                       100.65.88.56
LoadBalancer Ingress:     ac2b6a0fda9de11e89065020c50b4de7-247989881.us-west-2.elb.amazonaws.com
Port:                     http  80/TCP
TargetPort:               80/TCP
NodePort:                 http  30539/TCP
Endpoints:                100.96.1.21:80
Port:                     https  443/TCP
TargetPort:               443/TCP
NodePort:                 https  32666/TCP
Endpoints:                100.96.1.21:443

