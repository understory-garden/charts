#! /bin/sh

set -ex

if ! (output=$(git status --porcelain) && [ -z "$output" ]); then
  echo "Cowardly refusing to create git tag while repo is dirty"
  exit 1
fi

dir=${1%/}
repo=$(git rev-parse --show-toplevel)/docs

helm lint --debug $dir
helm package $dir
chart=$(find . -name "$dir-*.tgz" | sed "s|^\./||")
if ([ -z "$chart" ]); then
  echo "Could not find packaged chart. This likely means the directory name and the name in the Chart.yaml do not match. You may want to clean up any generated helm files before re-running."
  exit 1
fi
mv $chart $repo
helm repo index $repo --url https://itme.github.io/charts/

git_tag=${chart%.tgz}
git add -A $repo
git commit -m "Release $git_tag"
git tag $git_tag
git push --tags
