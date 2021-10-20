#!/usr/bin/env bash

# Cleanup image from Gitlab registry. First parameter must be the full path to the iamge to be removed.

set -e

#set -x

URL=$1
LASTPART=${URL#*/}
TAG=${LASTPART#*:}
#REGISTRY_URL=${URL%%/*}
PROJECT=${LASTPART%%:*}

# Check parameter passed starts with REGISTRY_URL
[[ ! $1 == $CI_REGISTRY_IMAGE* ]] && echo "The image full path should start with $CI_REGISTRY_IMAGE" && exit 1

[ -z "$CI_ACCOUNT_LONG" ] && echo "You need to set the CI_ACCOUNT_LONG environment variable to '[user]:[password]' where user is a valid Gitlab user that has access to the Gitlab image you want to delete." && exit 1;

GITLAB_URL=$(echo $CI_PROJECT_URL | awk -F/ '{print $1"//"$3}')

# Authenticates with Gitlab Registry
# CI_ACCOUNT env var should contain "login:password" of a user that has access to repository
TOKEN=$(curl -s -u "$CI_ACCOUNT_LONG" "${GITLAB_URL}/jwt/auth?client_id=docker&offline_token=true&service=container_registry&scope=repository:${PROJECT}:pull,*" | sed -r "s/(\{\"token\":\"|\"\})//g")
#echo $TOKEN

# Obtain digest from tag name
#- echo curl -sI -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -H "Authorization: Bearer $TOKEN" https://${CI_REGISTRY}/v2/${CI_PROJECT_PATH}/manifests/$CI_COMMIT_REF_SLUG | grep -Fi Docker-Content-Digest | sed -e 's/Docker-Content-Digest: //' -e 's/\:/\\:/'
DIGEST=$(curl -sI -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -H "Authorization: Bearer $TOKEN" https://${CI_REGISTRY}/v2/${PROJECT}/manifests/$TAG | grep -Fi Docker-Content-Digest | sed -e "s/Docker-Content-Digest: //" -e "s/\:/\\:/" | sed 's/\r$//')

# Removes pipeline-built Docker image from Gitlab's registry
curl -X DELETE -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -H "Authorization: Bearer $TOKEN" https://${CI_REGISTRY}/v2/${PROJECT}/manifests/$DIGEST
