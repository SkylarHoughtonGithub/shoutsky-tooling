#! /bin/bash
#source: https://archive.eksworkshop.com/beginner/190_efs/efs-csi-driver/
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.3"
