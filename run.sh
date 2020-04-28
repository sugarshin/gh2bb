#!/bin/bash
set -eu

. .env

_repo_type=${1} # ref: https://developer.github.com/v3/repos/#parameters-2
_per_page=${2:-100}

function mv_gh2bb() {
  repo=${1}
  echo ">>> ${repo}"
  rm -rf "${repo}"
  git clone -q --depth 1 git@github.com:${GITHUB_TARGET_USERNAME}/${repo}.git "${repo}"
  cd "${repo}"
  git fetch -q origin --prune
  git reset -q --hard origin/HEAD
  slug=$(echo "${repo}" | sed -e 's/[^._a-zA-Z0-9-]/-/g' | tr '[:upper:]' '[:lower:]')
  repo_path="${BITBUCKET_USERNAME}/${GITHUB_TARGET_USERNAME}__${slug}"
  curl -XPOST "https://bitbucket.org/api/2.0/repositories/${repo_path}" \
    --fail \
    --user "${BITBUCKET_USERNAME}:${BITBUCKET_APP_PASSWORD}" \
    -H 'Content-Type: application/json' \
    -d '{"is_private":true}' || true
  rm -rf .git
  git init -q
  git add .
  git commit -q -m "Updates"
  git remote add bb git@bitbucket.org:${repo_path}.git || true
  git push -q bb HEAD --force
  cd -
  rm -rf "${repo}"
}

function print_targets() {
  echo ''
  echo '=============='
  echo "${1}"
  echo '=============='
  echo ''
}

function mv_gh2bb_all() {
  page=${1:-1}
  REPOS=$(curl -sSL "https://api.github.com/${GITHUB_TARGET_TYPE}/${GITHUB_TARGET_USERNAME}/repos?type=${_repo_type}&per_page=${_per_page}&page=${page}" \
    -H 'Accept: application/vnd.github.v3+json' \
    -H "Authorization: bearer ${GITHUB_ACCESS_TOKEN}" | jq -r '.[].name')

  if [ -n "$REPOS" ]; then
    print_targets "$REPOS"

    for repo in ${REPOS[@]}; do mv_gh2bb "${repo}"; done

    page=$((++page))

    mv_gh2bb_all ${page}
  else
    echo 'successfully completed!'
  fi
}

function main() {
  mv_gh2bb_all
}

main
