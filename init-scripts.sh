#!/bin/bash

# 1. 패키지 업데이트 및 필요 도구 설치
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# 2. Docker 설치 (기존 로직 유지)
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 3. 작업 디렉토리 설정 (std05 계정에 맞춰 수정)
TARGET_DIR="/home/std05/app"
mkdir -p $TARGET_DIR
cd $TARGET_DIR

# 4. docker-compose 파일 다운로드 (파일명 수정: docker-compose.yaml)
wget -O docker-compose.yaml https://raw.githubusercontent.com/ParkSoyoung77/aa/main/docker-compose.yaml

# 5. 실행 중인 컨테이너 정리 및 재생성 (단순화)
echo "Stopping and restarting containers..."
docker compose down --remove-orphans
docker compose -p st5-project up -d --pull always

# 6. (선택) std05 사용자가 docker를 sudo 없이 쓸 수 있게 권한 부여
usermod -aG docker std05