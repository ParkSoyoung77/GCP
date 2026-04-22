# 1. 인스턴스 템플릿 생성 (VM 설계도 - 기존 init.sh 포함)
gcloud compute instance-templates create st5-template \
    --machine-type=e2-medium \
    --network=st5-vpc \
    --subnet=st5-public-subnet \
    --tags=http-server \
    --metadata-from-file startup-script=init-scripts.sh

# 2. 관리형 인스턴스 그룹(MIG) 생성
gcloud compute instance-groups managed create st5-mig \
    --base-instance-name=st5-web \
    --template=st5-template \
    --size=2 \
    --zone=asia-east2-a

# 3. 오토스케일링 설정 (예: CPU 60% 넘으면 최대 5대까지 증설)
gcloud compute instance-groups managed set-autoscaling st5-mig \
    --max-num-replicas=5 \
    --target-cpu-utilization=0.6 \
    --cool-down-period=60 \
    --zone=asia-east2-a

# 4. 포트 이름 정의 (MIG용)
gcloud compute instance-groups managed set-named-ports st5-mig \
    --named-ports http:80 \
    --zone=asia-east2-a

# -----------------------------------------------
# 5. 상태 확인 생성 (Nginx가 잘 떠있는지 확인용)
gcloud compute health-checks create http st5-hc \
    --port 80 --global

# 6. 백엔드 서비스 생성
gcloud compute backend-services create st5-backend \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=st5-hc \
    --global

# 7. 백엔드 서비스에 인스턴스 그룹(Backend) 연결
gcloud compute backend-services add-backend st5-backend \
    --instance-group=st5-mig \
    --instance-group-zone=asia-east2-a \
    --global


# 8. URL 맵 생성 (들어오는 요청을 백엔드로 전달)
gcloud compute url-maps create st5-url-map \
    --default-service=st5-backend

# 9. 대상 HTTP 프록시 생성
gcloud compute target-http-proxies create st5-http-proxy \
    --url-map=st5-url-map

# 10. 전역 고정 IP 할당 (선택 사항이지만 권장)
gcloud compute addresses create st5-lb-ip --global

# 11. 전달 규칙 생성 (실제 외부 IP와 연결되는 지점)
gcloud compute forwarding-rules create st5-http-rule \
    --address=st5-lb-ip \
    --global \
    --target-http-proxy=st5-http-proxy \
    --ports=80
