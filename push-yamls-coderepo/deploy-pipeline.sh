#!/bin/sh
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
usercred=$(aws iam create-service-specific-credential --user-name git-user --service-name codecommit.amazonaws.com)
GIT_USERNAME=$(echo $usercred | jq -r '.ServiceSpecificCredential.ServiceUserName')
GIT_PASSWORD=$(echo $usercred | jq -r '.ServiceSpecificCredential.ServicePassword')
CREDENTIAL_ID=$(echo $usercred| jq -r '.ServiceSpecificCredential.ServiceSpecificCredentialId')
test -n "$GIT_USERNAME" && echo GIT_USERNAME is "$GIT_USERNAME" || "echo GIT_USERNAME is not set"

test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || "echo AWS_REGION is not set"
git clone codecommit::$AWS_REGION://eksworkshop-app


cd eksworkshop-app
cp ../buildspec.yml .
cp ../buildspec-delete.yml .
yes | cp -r -i ../../eks-sample-apps/* .

# git pull 
git add --all
git commit -m "Initial commit."
git fetch
# git push
git push -f origin master

