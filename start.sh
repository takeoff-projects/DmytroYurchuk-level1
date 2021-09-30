#!/bin/sh

gcloud builds submit --tag=gcr.io/roi-takeoff-user55/go-pets:v1.0 .

cd terraform && terraform init && terraform apply -auto-approve
