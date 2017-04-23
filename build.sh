#!/bin/bash
#
# Run a build for all images.

set -uo pipefail

info() {
  printf "%s\n" "$@"
}

fatal() {
  printf "**********\n"
  printf "%s\n" "$@"
  printf "**********\n"
  exit 1
}

cd $(cd ${0%/*} && pwd -P);

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
  versions=( */ )
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do

  echo $version
  tag=$(cat $version/Dockerfile | grep "ENV NODE_VERSION" | cut -d' ' -f3)

  info "Building $tag..."
  docker build -t thebuccaneersden/rpi-node:$tag $version

  if [[ $? -gt 0 ]]; then
    fatal "Build of $tag failed!"
  else
    info "Build of $tag succeeded."
  fi

  variants=( slim onbuild )

  for variant in "${variants[@]}"; do
    info "Building $tag-$variant variant..."
    docker build -t thebuccaneersden/rpi-node:$tag-$variant $version/$variant

    if [[ $? -gt 0 ]]; then
      fatal "Build of $tag-$variant failed!"
    else
      info "Build of $tag-$variant succeeded."
    fi

  done

done

info "All builds successful!"

exit 0
