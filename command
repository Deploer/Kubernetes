#!/bin/sh
kubectl create -f manifest.yaml
# pod "demo-server" created

kubectl get pod -l app=demo-server


kubectl create -f service.yaml
service "demo-server-lb" created


kubectl apply -f demo-deploy.yaml
deployment "demo-server" created

