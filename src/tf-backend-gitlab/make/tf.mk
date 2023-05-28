#!make

.PHONY: tf-init
tf-init:
	terraform init -input=false

.PHONY: tf-init-upgrade
tf-init-upgrade:
	terraform init --upgrade -input=false

.PHONY: tf-validate
tf-validate:
	@terraform validate

.PHONY: tf-plan
tf-plan:
	@terraform plan

.PHONY: tf-apply
tf-apply:
	@terraform apply

.PHONY: tf-destroy
tf-destroy:
	@terraform destroy

.PHONY: tf-output
tf-output: tf-init
	@terraform output

