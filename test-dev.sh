k config set-context --current --namespace=banka-2-dev ; cd  ~ ; rm -rf Banka-2-Infrastructure ; git clone https://github.com/RAF-SI-2022/Banka-2-Infrastructure.git ; export ENV=dev; export NAMESPACE=banka-2-dev; export SIDE=backend; export SERVICES="flyway users main otc client"; export TEST_SERVICES="users main otc client"; cd Banka-2-Infrastructure; chmod +x kubernetes/test.sh ; kubernetes/test.sh ;