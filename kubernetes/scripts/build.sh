##########################################################################
# Environment/namespace vars, should be predefined before running script #
##########################################################################

if [[ -z "${ENV}" ]]; then
  echo "ENV not declared"
  exit 1
fi
if [[ -z "${SIDE}" ]]; then
  echo "SIDE not declared"
  exit 1
fi
if [[ -z "${NAMESPACE}" ]]; then
  echo "NAMESPACE not declared"
  exit 1
fi
if [[ -z "${SERVICES}" ]]; then
  echo "SERVICES not declared"
  exit 1
fi

################################
# Build and push Docker images #
################################

commit_hash=$(git rev-parse HEAD)
tag_name=$(git tag --points-at HEAD)

##############################
# Define all image tags here #
##############################

image_tags="latest"
image_tags+=" ${commit_hash}"
image_tags+=" ${tag_name}"
image_tags=$(echo $image_tags | xargs)

services=$(echo ${SERVICES} | xargs)
for service in $services
do
  echo "Building image for service '${service}'"
  if [[ docker pull harbor.k8s.elab.rs/banka-2/${service}:${commit_hash} ]]; then
    echo "Image ${service}:${commit_hash} already found"
    docker tag harbor.k8s.elab.rs/banka-2/${service}:${commit_hash} harbor.k8s.elab.rs/banka-2/${service}:builder
  else
    docker build -t harbor.k8s.elab.rs/banka-2/${service}:builder -f ./docker/${service}.Dockerfile .
  fi
  
  for tag in $image_tags
  do
    docker tag harbor.k8s.elab.rs/banka-2/${service}:builder harbor.k8s.elab.rs/banka-2/${service}:${tag}
    docker push harbor.k8s.elab.rs/banka-2/${service}:${tag}
  done
done