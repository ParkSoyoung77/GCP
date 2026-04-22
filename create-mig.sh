#!/bin/bash

source ./config.sh

# 인스턴스 탬플릿 구성
gcloud compute instance-templates create st5-template \
   --network=st5-vpc \
   --subnet=st5-private-subnet \
   --region=asia-east2 \
   --machine-type=e2-medium \
   --image-family=st5-board-img-grp \
   --image-project=$PROJECT_ID \
   --tags=web-server,was-server,ssh-server \
   --labels=username=st5,classname=msp06 \
   --quiet

# ----------------------------------
# 관리형 인스턴스 그룹(MIG) 생성
# 옵션: 인스턴스에 부여할 이름 / 사용할 탬플릿의 이름 / 유지할 개수 / 리전
# labels 속성을 지원하지 않음.
gcloud compute instance-groups managed create st5-mig \
   --base-instance-name=st5-mig-vm \
   --template=st5-template \
   --size=2 \
   --region=asia-east2 \
   --quiet
# ----------------------------------
# 오토스케일링 설정
# 리전 단위
gcloud compute instance-groups managed set-autoscaling st5-mig \
   --max-num-replicas=2 \
   --min-num-replicas=1 \
   --target-cpu-utilization=0.6 \
   --cool-down-period=60 \
   --region=asia-east2 \
   --quiet