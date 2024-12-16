kubectl create -f manifest.yaml
# pod "demo-server" created
# huinya code
#
kubectl get pod -l app=demo-server

# huinya code
#
kubectl create -f service.yaml
service "demo-server-lb" created


kubectl apply -f demo-deploy.yaml
deployment "demo-server" created

