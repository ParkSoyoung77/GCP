#!/bin/bash

# 변수 설정
source ./config.sh

echo "🚀 Nginx Docker 인스턴스를 생성 중입니다..."

gcloud compute instances create $VM_NAME1 $VM_NAME2 \
    --zone=asia-east2-a \
    --network-interface=subnet=st5-private-subnet,no-address \
    --machine-type=e2-medium \
    --tags=web-server,ssh-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --metadata-from-file startup-script=init-scripts.sh

echo "✅ 인스턴스 생성 완료!"
echo "💡 참고: 이 인스턴스는 외부 IP가 없으므로 ALB를 통해 접속하거나 Bastion을 통해 확인하세요."

