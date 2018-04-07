#!/bin/bash
set -eu

. .env

_repo_type=$1

REPOS=$(curl "https://api.github.com/$GITHUB_TARGET_TYPE/$GITHUB_TARGET_USERNAME/repos?type=$_repo_type&per_page=100" \
  -H 'Accept: application/vnd.github.v3+json' \
  -H "Authorization: bearer $GITHUB_ACCESS_TOKEN" | jq -r '.[].name')

for repo in ${REPOS[@]}; do
  echo "> $repo"
  [ -d $repo ] || git clone git@github.com:$GITHUB_TARGET_USERNAME/$repo.git $repo
  cd $repo
  git fetch origin --prune
  git reset --hard origin/HEAD
  curl -XPOST https://bitbucket.org/api/2.0/repositories/${BITBUCKET_USERNAME}/${GITHUB_TARGET_USERNAME}_${repo} \
    --fail \
    --user $BITBUCKET_USERNAME:$BITBUCKET_PASSWORD \
    -H 'Content-Type: application/json' \
    -d '{"is_private":true}' || true
  git remote add bb git@bitbucket.org:$BITBUCKET_USERNAME/$repo.git || true
  git push bb --force
done
