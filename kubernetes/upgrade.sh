################################################################################
#                                                                              #
#                                  upgrade.sh                                  #
#                                                                              #
# Installs or upgrades the Kubernetes configuration of the project. NOTE! This #
# shell script must be run from the project root folder, NOT the /kubernetes   #
# folder. The script will access the relevant folders on its own.              #
#                                                                              #
################################################################################

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

chmod +x kubernetes/scripts/vars.sh
chmod +x kubernetes/scripts/build.sh
chmod +x kubernetes/scripts/deploy.sh
. kubernetes/scripts/vars.sh
bash kubernetes/scripts/build.sh
bash kubernetes/scripts/deploy.sh $1