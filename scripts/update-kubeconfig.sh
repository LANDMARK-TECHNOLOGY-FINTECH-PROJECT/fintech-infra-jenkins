#!/bin/bash
response="$(aws eks list-clusters --region us-west-2 --output text | grep -i class40-prod-chris 2>&1)" 
if [[ $? -eq 0 ]]; then
    echo "Success: class40-prod-chris exist"
    aws eks --region us-west-2 update-kubeconfig --name class40-prod-chris && export KUBE_CONFIG_PATH=~/.kube/config

else
    echo "Error: class40-prod-chris does not exist"
fi