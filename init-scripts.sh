#!/bin/bash
FLAG_FILE="/var/log/first-boot-done"

if [ -f "$FLAG_FILE" ]; then
    echo "이미 초기 설정이 완료되었습니다. 스크립트를 종료합니다."
    exit 0
fi

# 1. 패키지 업데이트 및 필요 도구 설치
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
# sudo apt install -y nginx

# 2. Docker 공식 GPG 키 및 저장소 추가
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# 3. Docker 설치
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

mkdir -p /home/st5-user/app
cd /home/st5-user/app

# 4. 컨테이너가 이미 실행 중인지 확인
if [ ! "$(docker ps -a -q -f name=nginx-container)" ]; then
    echo "Creating new nginx-container..."
#    docker network create --driver bridge docker-network || true
#    docker run -d --name nginx-container -p 80:80 --network docker-network --restart always soyoung0/nginx:docker-spa
     # github 파일 주소
     wget -O board.yaml https://raw.githubusercontent.com/ParkSoyoung77/
     sleep 2
     # 기존 컨테이너 삭제
     docker compose down --remove-orphans
     # 최신 이미지를 pull 받으면서 새로 실행
     docker compose -p st5-project up -d --pull always

else
    echo "nginx-container already exists. Starting it if it is stopped..."
    # docker start nginx-container
    docker compose start
fi
