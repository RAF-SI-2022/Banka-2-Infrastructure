k config set-context --current --namespace=banka-2-prod ; cd  ~ ; rm -rf Banka-2-Backend ; rm -rf Banka-2-Infrastructure ; git clone --branch sprint-6 https://github.com/RAF-SI-2022/Banka-2-Backend.git ; git clone https://github.com/RAF-SI-2022/Banka-2-Infrastructure.git ; export ENV=prod; export NAMESPACE=banka-2-prod; export SIDE=backend;export SERVICES="flyway users main otc client"; cd Banka-2-Backend; export INFRA_SRC=~/Banka-2-Infrastructure/; rsync -av --exclude='.git' ${INFRA_SRC} . ; chmod +x kubernetes/remove.sh ; kubernetes/remove.sh ; chmod +x kubernetes/upgrade.sh ; kubernetes/upgrade.sh ;