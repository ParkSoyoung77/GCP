#!/bin/bash

echo "이미지 삭제중"
gcloud compute images delete st5-custom-img --quiet
echo "이미지 삭제 성공"