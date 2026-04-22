source ./config.sh

# gke 클러스터 생성 명령어
# 원하는 리전 선택: --node-locations asia-east2-a, asia-east2-b
gcloud container clusters create st5-cluster \
   --region asia-east2 \
   --network st5-vpc \
   --subnetwork st5-private-subnet \
   --num-nodes 1 \
   --min-nodes 1 \
   --max-nodes 6 \
   --enable-autoscaling \
   --machine-type e2-medium \
   --disk-size 20 \
   --enable-ip-alias \
   --workload-pool="${PROJECT_ID}.svc.id.goog"


# 클러스터 수량 조정
gcloud container clusters update st5-cluster \
   --region asia-east2 \
   --num-nodes 1 \
   --min-nodes 1 \
   --max-nodes 3 \
   --enable-autoscaling

# 클러스터 삭제
gcloud container clusters delete st5-cluster --region asia-east2

# ############################################################
# 클러스터 관리를 kubectl로 하고자 할 경우 
# ===========================================================
# GKE 관리 전용 서비스 설치: config controller (18분 내외)
gcloud anthos config controller create st5-manager \
    --location asia-east2 \
    --network default \
    --master-ipv4-cidr-block 192.168.10.0/28

# 리스트 검색
gcloud anthos config controller list --location asia-east2

# 관리 환경 접속 설정
gcloud anthos config controller get-credentials st5-manager \
   --location asia-east2

# 클러스터 생성
kubectl apply -f create-cluster.yaml