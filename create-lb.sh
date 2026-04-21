#!/bin/bash

# 1. 비관리형 인스턴스 그룹 생성 (Unmanaged Instance Group)
gcloud compute instance-groups unmanaged create st5-ig \
    --zone=asia-east2-a

# 2. 생성한 VM을 그룹에 소속시키기
gcloud compute instance-groups unmanaged add-instances st5-ig \
    --instances=st5-ex1-vm,st5-ex2-vm \
    --zone=asia-east2-a

# 3. 인스턴스 그룹에 포트 이름 정의
gcloud compute instance-groups unmanaged set-named-ports st5-ig \
    --named-ports http:80 \
    --zone=asia-east2-a

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
gcloud compute backend-services add-backend st5-backend \
    --instance-group=st5-ig \
    --instance-group-zone=asia-east2-a \
    --global


# 7. URL 맵 생성 (들어오는 요청을 백엔드로 전달)
gcloud compute url-maps create st5-url-map \
    --default-service=ist5-backend

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