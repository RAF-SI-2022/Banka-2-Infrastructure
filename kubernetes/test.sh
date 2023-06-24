################################################################################
#                                                                              #
#                                    test.sh                                   #
#                                                                              #
# Tests the setup of the Kubernetes stack. DANGER: this script will WIPE all   #
# databases. PROCEED WITH CAUTION! Only run in DEV environment!                #
#                                                                              #
################################################################################

# Load services
chmod +x kubernetes/scripts/vars.sh
. kubernetes/scripts/vars.sh

# All microservices
if [[ -z "${SERVICES}" ]]; then
  echo "SERVICES not declared"
  exit 1
fi
# Externally installed services
if [[ -z "${EXTRA_SERVICES}" ]]; then
  echo "EXTRA_SERVICES not declared"
  exit 1
fi
# Services to be tested
if [[ -z "${TEST_SERVICES}" ]]; then
  echo "TEST_SERVICES not declared"
  exit 1
fi

# Number of attempts
max_attempts=10

# Interval between attempts (in seconds)
interval=30

# Current attempt
attempt=1

all_ready=true
while [ $attempt -le $max_attempts ]
do
  echo "Checking if services pods are running #$attempt"
  all_ready=true

  services=$(echo ${SERVICES} | xargs)
  for service in $services
  do

    # Regex of the pod
    regex="$service.*"

    # Fetch the status of the pod
    pod_status=$(kubectl get pods -n ${NAMESPACE} | grep -E "$regex" | awk '{print $3}')

    # Check if the pod is running or (successfully) completed
    if [ "$pod_status" != "Running" ] && [ "$pod_status" != "Completed" ]
    then
      echo "Pod ${service} invalid status: ${pod_status}"
      all_ready=false
      break
    fi
  done

  if [ "$all_ready" = true ]
  then
    break
  fi

  # Wait for the specified interval
  sleep $interval

  # Increase the attempt counter
  ((attempt++))
done

if [ "$all_ready" != true ]
then
  echo "Service pods did not reach the 'Running' status after $max_attempts attempts."
  exit 1
fi

cmd=$(cat <<-CMD
  export PYTHONUNBUFFERED=1;
  apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python;
  python3 -m ensurepip;
  pip3 install --no-cache --upgrade pip setuptools;
  cd src/main/resources;

  echo \"import os\" >> env_extr.py;
  echo \"import re\" >> env_extr.py;

  echo \"with open\('application.properties'\) as file:\" >> env_extr.py;
  echo \"    properties = [line.strip\(\) for line in file if '=' in line]\" >> env_extr.py;

  echo \"keys = [prop.split\('='\)[0] for prop in properties]\" >> env_extr.py;

  echo \"for key in keys:\" >> env_extr.py;
  echo \"    for name, value in os.environ.items\(\):\" >> env_extr.py;
  echo \"        if re.search\(key, value\) or re.search\(key, name\):\" >> env_extr.py;
  echo \"            print\(f\'{name}={value}\'\)\" >> env_extr.py;
  python3 env_extr.py > application-temp.properties;
  cd ../../..;
  mvn test -Dspring.profiles.active=temp -DargLine=-Dspring.profiles.active=temp
CMD
)

# Run test on each pod
test_services=$(echo $TEST_SERVICES | xargs)
for service in $test_services
do
  echo "Testing pod $service"

  # Regex of the pod
  regex="$service.*"

  # Fetch the status of the pod
  name=$(kubectl get pods -n ${NAMESPACE} | grep -E "$regex" | awk '{print $1}')

  if kubectl exec $name -- sh -c "$cmd"
  then
    echo "Pod $service passed tests"
  else
    echo "Pod $service failed tests"
    exit 1
  fi
done