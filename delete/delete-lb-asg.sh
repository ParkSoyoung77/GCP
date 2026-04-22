#!/bin/bash

echo "🗑️ GCP 로드밸런서 및 인스턴스 그룹 삭제를 시작합니다..."

# 11. 전달 규칙 삭제
gcloud compute forwarding-rules delete st5-http-rule --global --quiet

# 10. 전역 고정 IP 삭제 (필요한 경우에만)
gcloud compute addresses delete st5-lb-ip --global --quiet

# 9. 대상 HTTP 프록시 삭제
gcloud compute target-http-proxies delete st5-http-proxy --quiet

# 8. URL 맵 삭제
gcloud compute url-maps delete st5-url-map --quiet

# 7. 백엔드 서비스 삭제
gcloud compute backend-services delete st5-backend --global --quiet

# 5. 상태 확인 삭제
gcloud compute health-checks delete st5-hc --global --quiet

# 2~3. 관리형 인스턴스 그룹 삭제 (오토스케일링도 함께 삭제됨)
gcloud compute instance-groups managed delete st5-mig --zone=asia-east2-a --quiet

# 1. 인스턴스 템플릿 삭제
gcloud compute instance-templates delete st5-template --quiet

echo "✅ 모든 리소스가 삭제되었습니다!"