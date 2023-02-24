#!/bin/bash

template="jenkins-deployment-role-template.yml"
if [[ ! -f ${template} ]]; then
    echo "Jenkins role template not found"
    exit 1
fi

repo_name=$1
env_name=$2

repo_name=${repo_name//_/-}
stack_name="${repo_name}-jenkins-deployer-iam-role"
region="us-east-1"

aws cloudformation create-stack \
    --stack-name "${stack_name}" \
    --region "${region}" \
    --template-body file://${template} \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters "ParameterKey=AppName,ParameterValue=${repo_name}" "ParameterKey=EnvName,ParameterValue=${env_name}"
