#!/bin/bash

# 1. VPC 생성
gcloud compute networks create st5-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=regional \
    --mtu=1460 \
    --description="Educational Network (VPC)"

sleep 2

# 2. Proxy-only Subnet 생성 (Active)
gcloud compute networks subnets create st5-proxy-only-subnet \
    --purpose=REGIONAL_MANAGED_PROXY \
    --role=ACTIVE \
    --network=st5-vpc \
    --region=asia-east2 \
    --range=10.0.0.0/24 \
    --description="ALB Proxy Subnet"

sleep 2

# 3. Proxy-backup Subnet 생성 (Backup)
gcloud compute networks subnets create st5-proxy-backup-subnet \
    --purpose=REGIONAL_MANAGED_PROXY \
    --role=BACKUP \
    --network=st5-vpc \
    --region=asia-east2 \
    --range=10.0.1.0/24 \
    --description="ALB Proxy Backup Subnet"

sleep 2

# 4. Public Subnet (Bastion 등 외부 노출용)
gcloud compute networks subnets create st5-public-subnet \
    --network=st5-vpc \
    --range=10.0.2.0/24 \
    --region=asia-east2 \
    --description="Bastion or Public Instance Subnet"

sleep 2

# 5. Private(App) Subnet (GKE 포드/서비스 범위 포함)
gcloud compute networks subnets create st5-private-subnet \
    --network=st5-vpc \
    --range=10.0.11.0/24 \
    --region=asia-east2 \
    --secondary-range=st5-pod-range=10.1.0.0/16,st5-svc-range=10.2.0.0/20 \
    --enable-private-ip-google-access \
    --description="Application Instance Private Subnet"

sleep 2

# 6. Private(DB) Subnet (NAT 미적용 의도 반영)
gcloud compute networks subnets create st5-db-subnet \
    --network=st5-vpc \
    --range=10.0.21.0/24 \
    --region=asia-east2 \
    --enable-private-ip-google-access \
    --description="Database Cluster Private Subnet"

sleep 2

# 7. NAT Router 생성
gcloud compute routers create st5-nat-router \
    --network=st5-vpc \
    --region=asia-east2 \
    --description="NAT Router for Private Subnet"

sleep 2

# 8. Cloud NAT 생성
gcloud compute routers nats create st5-nat \
    --router=st5-nat-router \
    --region=asia-east2 \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges

# 방화벽 규칙 생성
# 외부에서 SSH(22번 포트) 접속 허용
gcloud compute firewall-rules create st5-allow-ssh-ingress \
    --network=st5-vpc \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=ssh-server \
    --description="Allow SSH from anywhere"

sleep 2

# 외부에서 ALB(80/443 포트)는 구글에서 관리하여 방화벽 규칙은 필요없습니다.

# LB에서 헬스체크를 위한 방화벽 규칙 생성: 별도 연결이 없어도 구글에서 자동 연결 함.
gcloud compute firewall-rules create allow-gcp-health-check \
    --network=st5-vpc \
    --action=ALLOW \
    --direction=INGRESS \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --rules=tcp:80

sleep 2

# 외부에서 Web(80/443 포트) 접속 허용
gcloud compute firewall-rules create st5-allow-web-ingress \
    --network=st5-vpc \
    --allow=tcp:80 \
    --source-ranges=0.0.0.0/0,10.0.0.0/24,130.211.0.0/22,35.191.0.0/16 \
    --target-tags=web-server \
    --description="Allow Web from ALB Proxy Subnet"

sleep 2

# 외부에서 fastAPI(8000번 포트) 접속 허용
gcloud compute firewall-rules create st5-allow-was-ingress \
    --network=st5-vpc \
    --allow=tcp:8000 \
    --source-ranges=10.0.11.0/24,10.1.0.0/16,10.2.0.0/20 \
    --target-tags=was-server \
    --description="Allow fastAPI from Web Server Subnet"

sleep 2

# 외부에서 MySQL(3306번 포트) 접속 허용
gcloud compute firewall-rules create st5-allow-mysql-ingress \
    --network=st5-vpc \
    --allow=tcp:3306 \
    --source-ranges=10.0.11.0/24,10.1.0.0/16,10.2.0.0/20 \
    --target-tags=mysql-server \
    --description="Allow MySQL from App Subnet"

sleep 2