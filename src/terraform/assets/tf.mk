#!make

.PHONY: terraform
terraform: tf-init-once tf-apply

.PHONY: tf-init
tf-init:
	terraform init -input=false

tf-init-once: TF_INIT_ONCE := /tmp/$(shell pwd | sha256sum | cut -d' ' -f1).tf-init-once
tf-init-once:
	@test -e ${TF_INIT_ONCE} || ( \
		$(MAKE) tf-init \
		&& touch ${TF_INIT_ONCE} \
	)

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
tf-apply: PARALLELISM ?= 10
tf-apply:
	@terraform apply -parallelism=${PARALLELISM}

.PHONY: tf-destroy
tf-destroy:
	@terraform destroy

.PHONY: tf-output
tf-output: tf-init
	@terraform output
