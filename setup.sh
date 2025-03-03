#!/bin/bash -e
set -e
BACKEND_BRANCH=main
FRONTEND_BRANCH=main
MODULE_BRANCH=main
LAUNCHSERVER_DOCKER_BRANCH=main
SIMPLECABINET_REMOTE=localhost:17549
SIMPLECABINET_PROTOCOL=http

SIMPLECABINET_REMOTE_URL=$SIMPLECABINET_PROTOCOL:\\/\\/$SIMPLECABINET_REMOTE

echo -e "\033[32mPhase 0: \033[33mDownload repositories\033[m";

if ! [ -d backend-src ]; then
    git clone --depth=1 -b $BACKEND_BRANCH https://github.com/SimpleCabinet/SimpleCabinetWebAPI.git backend-src
fi

if ! [ -d frontend-src ]; then
    git clone --depth=1 -b $FRONTEND_BRANCH https://github.com/SimpleCabinet/SimpleCabinetFrontend2.git frontend-src
fi

if ! [ -d module-src ]; then
    git clone --depth=1 -b $MODULE_BRANCH https://github.com/SimpleCabinet/SimpleCabinetModule.git module-src
fi

if ! [ -d dockered-src ]; then
    git clone --depth=1 -b $LAUNCHSERVER_DOCKER_BRANCH https://github.com/GravitLauncher/LauncherDockered.git dockered-src
    ln -s dockered-src/Dockerfile.launcher Dockerfile.launcher
    ln -s dockered-src/setup-docker.sh setup-docker.sh
fi

echo -e "\033[32mPhase 1: \033[33mBuild SimpleCabinet\033[m";

cd backend-src && ./gradlew assemble && cd ..
cd module-src && ./gradlew build && cd ..
cp frontend-src/.env.example frontend-src/.env
sed -i "s/URL=http:\/\/localhost:8080\//URL=$SIMPLECABINET_REMOTE_URL\/api\//" frontend-src/.env
mkdir backend-configuration
cp backend-src/src/main/resources/application.properties backend-configuration/application.properties
cp -r backend-src/src/main/resources/templates backend-configuration
sed -i "s/spring.datasource.url=jdbc:postgresql:\/\/localhost:5432\/simplecabinet/spring.datasource.url=jdbc:postgresql:\/\/postgres:5432\/simplecabinet/" backend-configuration/application.properties
sed -i "s/storage.file.remoteUrl=http:\/\/localhost:8080\/assets\//storage.file.remoteUrl=$SIMPLECABINET_REMOTE_URL\/userassets\//" backend-configuration/application.properties

echo -e "\033[32mPhase 1.1: \033[33mGenerate key pair\033[m";

openssl ecparam -name prime256v1 -genkey -noout -out private_key.pem
openssl ec -in private_key.pem -pubout -out public_key.pem
openssl pkcs8 -topk8 -nocrypt -in private_key.pem -outform DER -out backend-configuration/ecdsa
openssl ec -in private_key.pem -pubout -outform DER -out backend-configuration/ecdsa.pub

echo -e "\033[32mPhase 2: \033[33mBuild Docker containers\033[m";

sed -i "s/LAUNCHSERVER_ADDRESS_PLACEHOLDER/$SIMPLECABINET_REMOTE\/launcher/" docker-compose.yml || true
docker compose up -d --build

echo -e "\033[32mPhase 3: \033[33mSleep 40 seconds\033[m";

sleep 40

echo -e "\033[32mPhase 3.1: \033[33mRun basic initialization\033[m";

docker compose exec simplecabinet curl http://simplecabinet:8080/setup > setup.json
ADMIN_API_TOKEN=$(cat setup.json | jq ".accessToken")
docker compose cp module-src/build/libs/*.jar gravitlauncher:/app/data/modules/SimpleCabinet_module.jar
docker compose restart gravitlauncher

echo -e "\033[32mPhase 3.2: \033[33mSleep 10 seconds\033[m";

sleep 10

echo -e "\033[32mPhase 3.3: \033[33mRun 'simplecabinet install' command\033[m";

echo "cabinet install http://simplecabinet:8080 $ADMIN_API_TOKEN" | docker compose exec -T gravitlauncher socat UNIX-CONNECT:control-file -

echo -e "\033[32mPhase 4: \033[33mInstallation complete\033[m";
