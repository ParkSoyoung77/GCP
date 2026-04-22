#!/bin/bash

source ./config.sh

# 0. 인스턴스 탬플릿 구성
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

# 1. 관리형 인스턴스 그룹(MIG) 생성
# 옵션: 인스턴스에 부여할 이름 / 사용할 탬플릿의 이름 / 유지할 개수 / 리전
# labels 속성을 지원하지 않음.
gcloud compute instance-groups managed create st5-mig \
   --base-instance-name=st5-mig-vm \
   --template=st5-template \
   --size=2 \
   --region=asia-east2 \
   --quiet

# 2. 오토스케일링 설정
# 리전 단위
gcloud compute instance-groups managed set-autoscaling st5-mig \
   --max-num-replicas=2 \
   --min-num-replicas=1 \
   --target-cpu-utilization=0.6 \
   --cool-down-period=60 \
   --region=asia-east2 \
   --quiet

# 3. 인스턴스 그룹에 포트 이름 정의
gcloud compute instance-groups managed set-named-ports st5-mig \
    --named-ports http:80 \
    --region=asia-east2
# ----------------------------------------------------------------
# 4. 상태 확인 생성 (Nginx가 잘 떠있는지 확인용)
gcloud compute health-checks create http st5-hc \
    --port 80 --global

# 5. 백엔드 서비스 생성
gcloud compute backend-services create st5-backend \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=st5-hc \
    --global

# 6. 백엔드 서비스에 인스턴스 그룹(Backend) 연결
# 추가 할 경우, 이름 변경: 5번 백엔드 서비스명과 일치
# 모든 옵션은 MIG와 일치시켜야 함.
gcloud compute backend-services add-backend st5-backend \
    --instance-group=st5-mig \
    --instance-group-region=asia-east2 \
    --global


# 7. URL 맵 생성 (들어오는 요청을 백엔드로 전달)
gcloud compute url-maps create st5-url-map \
    --default-service=st5-backend

# 8. 대상 HTTP 프록시 생성
gcloud compute target-http-proxies create st5-http-proxy \
    --url-map=st5-url-map

# 9. 전역 고정 IP 할당 (선택 사항이지만 권장)
gcloud compute addresses create st5-lb-ip --global

# 10. 전달 규칙 생성 (실제 외부 IP와 연결되는 지점)
gcloud compute forwarding-rules create st5-http-rule \
    --address=st5-lb-ip \
    --global \
    --target-http-proxy=st5-http-proxy \
    --ports=80