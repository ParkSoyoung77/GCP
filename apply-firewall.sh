#!/bin/bash

gcloud compute instances add-tags st5-vm \
     --tags=ssh-server \
     --zone=asia-east2-a

sleep 2

gcloud compute instances add-tags st5-vm \
     --tags=web-server \
     --zone=asia-east2-a

sleep 2

gcloud compute instances add-tags st5-vm  \
     --tags=was-server \
     --zone=asia-east2-a

sleep 2

gcloud compute instances add-tags st5-vm \
     --tags=mysql-server \
     --zone=asia-east2-a