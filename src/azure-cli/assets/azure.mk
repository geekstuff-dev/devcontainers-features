#!make

.PHONY: az-login
az-login:
	@test -n "${AZURE_SUBSCRIPTION_ID}"
	@test -z "${AZURE_TENANT_ID}" || az login --tenant ${AZURE_TENANT_ID} -o none
	@test -n "${AZURE_TENANT_ID}" || az login -o none
	@az account set --subscription="${AZURE_SUBSCRIPTION_ID}"
	@az config set core.display_region_identified=no
