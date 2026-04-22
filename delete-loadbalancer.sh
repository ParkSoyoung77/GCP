#!/bin/bash

# 변수 설정
REGION="asia-east2"
MIG_NAME="st5-mig"
TEMPLATE_NAME="st5-template"
LB_NAME="st5-url-map" # URL Map 이름이 보통 LB의 기준이 됩니다.

echo "🧹 [1/3] 로드밸런서(LB) 리소스 삭제 시작..."

# 10. 전달 규칙 삭제
gcloud compute forwarding-rules delete st5-http-rule --global --quiet

# 9. 외부 IP 주소 삭제
gcloud compute addresses delete st5-lb-ip --global --quiet

# 8. HTTP 프록시 삭제
gcloud compute target-http-proxies delete st5-http-proxy --quiet

# 7. URL 맵 삭제
gcloud compute url-maps delete st5-url-map --quiet

# 6 & 5. 백엔드 서비스 삭제
gcloud compute backend-services delete st5-backend --global --quiet

# 4. 상태 확인(Health Check) 삭제
gcloud compute health-checks delete st5-hc --global --quiet

echo "✅ 로드밸런서 리소스 정리 완료."

echo "🧹 [2/3] 관리형 인스턴스 그룹(MIG) 삭제 시작..."

# 1. MIG 삭제 (오토스케일링은 MIG와 함께 삭제됨)
# 주의: list 명령어는 복수형 --regions를 사용해야 에러가 안 납니다.
if gcloud compute instance-groups managed list --regions=$REGION --filter="name=$MIG_NAME" --format="value(name)" | grep -q "$MIG_NAME"; then
    gcloud compute instance-groups managed delete $MIG_NAME --region=$REGION --quiet
    echo "✅ MIG ($MIG_NAME) 삭제 완료."
else
    echo "ℹ️ 삭제할 MIG가 존재하지 않습니다."
fi

echo "🧹 [3/3] 인스턴스 템플릿 삭제 시작..."

# 0. 인스턴스 템플릿 삭제
if gcloud compute instance-templates list --filter="name=$TEMPLATE_NAME" --format="value(name)" | grep -q "$TEMPLATE_NAME"; then
    gcloud compute instance-templates delete $TEMPLATE_NAME --quiet
    echo "✅ 템플릿 ($TEMPLATE_NAME) 삭제 완료."
else
    echo "ℹ️ 삭제할 템플릿이 존재하지 않습니다."
fi

echo "🚀 모든 리소스가 완벽하게 정리되었습니다!"