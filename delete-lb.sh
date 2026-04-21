#!/bin/bash

# 10. 전달 규칙 삭제 (Forwarding Rule)
gcloud compute forwarding-rules delete st5-http-rule --global --quiet
sleep 2
# 9. 전역 고정 IP 삭제
gcloud compute addresses delete st5-lb-ip --global --quiet
sleep 2
# 8. 대상 HTTP 프록시 삭제
gcloud compute target-http-proxies delete st5-http-proxy --quiet
sleep 2
# 7. URL 맵 삭제
gcloud compute url-maps delete st5-url-map --quiet
sleep 2
# 6. 백엔드 서비스 삭제
gcloud compute backend-services delete st5-backend --global --quiet
sleep 2
# 4. 상태 확인 삭제
gcloud compute health-checks delete st5-hc --quiet
sleep 2
# 1-3. 인스턴스 그룹 삭제 
# (비관리형 그룹은 그룹만 삭제해도 내부 VM은 삭제되지 않고 그룹에서 빠지기만 합니다.)
gcloud compute instance-groups unmanaged delete st5-ig \
    --zone=asia-east2-a --quiet

echo "✅ 모든 로드밸런서 관련 자원이 삭제되었습니다."