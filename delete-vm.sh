#!/bin/bash
# 삭제 대상 이름을 변수에 저장
# 변수 설정
source ./config.sh

if [ -n "$VM_NAME1" ]; then
  echo "🚀 $VM_NAME1  인스턴스들을 삭제합니다: $INSTANCES"
  # 변수에 담긴 모든 인스턴스 삭제
  gcloud compute instances delete $VM_NAME1 --zone=asia-east2-a --quiet
else
  echo "$VM_NAME1 인스턴스가 없습니다."
fi

if [ -n "$VM_NAME2" ]; then
  echo "🚀 $VM_NAME2 인스턴스들을 삭제합니다: $INSTANCES"
  # 변수에 담긴 모든 인스턴스 삭제
  gcloud compute instances delete $VM_NAME2 --zone=asia-east2-a --quiet
else
  echo "$VM_NAME2 인스턴스가 없습니다."
fi