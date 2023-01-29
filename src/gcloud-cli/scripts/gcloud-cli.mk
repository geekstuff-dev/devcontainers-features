#!make

.PHONY: gcp-full-login
gcp-full-login: gcp-login gcp-default-login

.PHONY: gcp-login
gcp-login:
	gcloud auth login

.PHONY: gcp-default-login
gcp-default-login:
	gcloud auth application-default login
