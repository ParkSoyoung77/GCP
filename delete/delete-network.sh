#!/bin/bash

echo "🗑️ GCP VPC 및 네트워크 리소스 삭제를 시작합니다..."

# 1. Cloud NAT 삭제 (NAT Router보다 먼저 삭제)
echo "1. Deleting Cloud NAT..."
gcloud compute routers nats delete st5-nat \
    --router=st5-nat-router \
    --region=asia-east2 \
    --quiet 2>/dev/null

sleep 2

# 2. NAT Router 삭제
echo "2. Deleting NAT Router..."
gcloud compute routers delete st5-nat-router \
    --region=asia-east2 \
    --quiet 2>/dev/null

sleep 2

# 3. 모든 방화벽 규칙 삭제 (VPC 삭제를 방해하는 Health Check 규칙 포함)
echo "3. Deleting Firewall Rules..."
gcloud compute firewall-rules delete \
    st5-allow-ssh-ingress \
    st5-allow-web-ingress \
    st5-allow-was-ingress \
    st5-allow-mysql-ingress \
    allow-gcp-health-check \
    --quiet 2>/dev/null

# (참고) st5-allow-alb-ingress는 없을 경우 에러가 나므로 따로 처리하거나 무시합니다.
gcloud compute firewall-rules delete st5-allow-alb-ingress --quiet 2>/dev/null

sleep 2

# 4. 서브넷 삭제 (Proxy Backup을 먼저 지워야 Active 삭제 가능)
echo "4-1. Deleting Backup Subnets..."
gcloud compute networks subnets delete \
    st5-db-subnet \
    st5-private-subnet \
    st5-public-subnet \
    st5-proxy-backup-subnet \
    --region=asia-east2 \
    --quiet

sleep 3

echo "4-2. Deleting Active Proxy Subnet..."
gcloud compute networks subnets delete st5-proxy-only-subnet \
    --region=asia-east2 \
    --quiet

# 서브넷이 삭제되고 VPC가 완전히 비워질 때까지 대기
echo "Waiting for subnets to be fully purged..."
sleep 5

# 5. VPC 삭제
echo "5. Deleting VPC..."
gcloud compute networks delete st5-vpc --quiet

echo "✨ Cleanup Complete! 모든 네트워크 리소스가 정리되었습니다."