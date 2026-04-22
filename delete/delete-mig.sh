#!/bin/bash

# 변수 설정 (리전으로 통일)
MIG_NAME="st5-mig"
TEMPLATE_NAME="st5-template"
REGION="asia-east2"

echo "🧹 Google Cloud 리소스 삭제를 시작합니다..."

# 1. 관리형 인스턴스 그룹(MIG) 삭제 (Region 단위)
# filter와 region 옵션을 사용하여 정확히 타겟팅합니다.
if gcloud compute instance-groups managed list --regions=$REGION --filter="name=$MIG_NAME" --format="value(name)" | grep -q "$MIG_NAME"; then
    echo "1/2: 관리형 인스턴스 그룹($MIG_NAME) 삭제 중..."
    gcloud compute instance-groups managed delete $MIG_NAME \
        --region=$REGION \
        --quiet
    echo "✅ MIG 삭제 완료."
else
    echo "ℹ️ 삭제할 MIG($MIG_NAME)가 존재하지 않습니다."
fi

# 2. 인스턴스 템플릿 삭제
if gcloud compute instance-templates list --filter="name=$TEMPLATE_NAME" --format="value(name)" | grep -q "$TEMPLATE_NAME"; then
    echo "2/2: 인스턴스 템플릿($TEMPLATE_NAME) 삭제 중..."
    gcloud compute instance-templates delete $TEMPLATE_NAME \
        --quiet
    echo "✅ 템플릿 삭제 완료."
else
    echo "ℹ️ 삭제할 템플릿($TEMPLATE_NAME)이 존재하지 않습니다."
fi

echo "🚀 모든 리소스가 성공적으로 정리되었습니다!"