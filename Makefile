SHELL := /bin/bash

start: 
	gcloud builds submit --tag=gcr.io/roi-takeoff-user55/go-website:v1.0 .
	./start.sh

stop:
	./stop.sh