#!/bin/bash
source ./config.sh

# 인스턴스 중지
gcloud compute instances stop $VM_NAME1 \
   --zone=asia-east2-a \
   --quiet

# 인스턴스 중지까지 소요되는 시간만큼 대기
sleep 30
# --------------------------------------
# 옵션: 인스턴스의 이름 / 인스턴스의 AZ(가용영역) // 이미지 그룹명 / 이미지 리전 / 이미지 라벨
gcloud compute images create st5-custom-img \
   --source-disk=$VM_NAME1 \
   --source-disk-zone=asia-east2-a \
   --family=st5-board-img-grp \
   --storage-location=asia-east2 \
   --labels=username=st5,classname=msp06 \
   --quiet

# --------------------------------------
# 이미지 생성 시간만큼 대기
sleep 180

# 인스턴스 재시작
gcloud compute instances start $VM_NAME1 \
   --zone=asia-east2-a \
   --quiet