#!/bin/bash

# 변수 설정
source ./config.sh

echo "🚀 Nginx Docker 인스턴스를 생성 중입니다..."

gcloud compute instances create $VM_NAME3 \
    --zone=asia-east2-a \
    --network-interface=subnet=st5-private-subnet \
    --machine-type=e2-medium \
    --tags=web-server,ssh-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --boot-disk-size=20GB \
    --labels=username=st5,classname=msp06 \
    --metadata-from-file startup-script=init-scripts.sh

echo "✅ 인스턴스 생성 완료!"
echo "💡 참고: 이 인스턴스는 외부 IP가 없으므로 ALB를 통해 접속하거나 Bastion을 통해 확인하세요."

sleep 180

# 인스턴스 중지
gcloud compute instances stop $VM_NAME3 \
   --zone=asia-east2-a \
   --quiet

# 인스턴스 중지까지 소요되는 시간만큼 대기
sleep 30
# --------------------------------------
# 옵션: 인스턴스의 이름 / 인스턴스의 AZ(가용영역) // 이미지 그룹명 / 이미지 리전 / 이미지 라벨
gcloud compute images create st5-custom-img2 \
   --source-disk=$VM_NAME3 \
   --source-disk-zone=asia-east2-a \
   --family=st5-board-img-grp \
   --storage-location=asia-east2 \
   --labels=username=st5,classname=msp06 \
   --quiet

# --------------------------------------
# 이미지 생성 시간만큼 대기
sleep 180

# 인스턴스 재시작
gcloud compute instances start $VM_NAME3 \
   --zone=asia-east2-a \
   --quiet

sleep 30

echo "🚀 Nginx Docker 인스턴스를 생성 중입니다..."

gcloud compute instances create $VM_NAME4 \
    --zone=asia-east2-a \
    --network-interface=subnet=st5-private-subnet \
    --machine-type=e2-medium \
    --tags=web-server,ssh-server \
    --image=st5-custom-img2 \
    --boot-disk-size=20GB \
    --labels=username=st5,classname=msp06

echo "✅ 인스턴스 생성 완료!"
echo "💡 참고: 이 인스턴스는 외부 IP가 없으므로 ALB를 통해 접속하거나 Bastion을 통해 확인하세요."

