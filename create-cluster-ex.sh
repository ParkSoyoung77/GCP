source ./config.sh

# gke 클러스터 생성 명령어
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
   --workload-pool=${PROJECT_ID}.svc.id.goog


# 클러스터 수량 조정
gcloud container clusters update st5-cluster \
   --region asia-east2 \
   --num-nodes 1 \
   --min-nodes 1 \
   --max-nodes 3 \
   --enable-autoscaling

# 클러스터 삭제
gcloud container clusters delete st5-cluster --region asia-east2