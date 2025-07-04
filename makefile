ALLOWED_ENVS := management development

# Check if ENV is set and valid
ifndef ENV
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif
ifneq ($(filter $(ENV),$(ALLOWED_ENVS)),$(ENV))
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif

# Management environment is built out of the module folder
ifeq ($(ENV),management)
CHDIR := terraform/modules/management
VARS := ../../vars
else
CHDIR := terraform
VARS := vars
endif

.PHONY: init
init:
	terraform -chdir=$(CHDIR) init -reconfigure -backend-config="prefix=$(ENV)"

.PHONY: plan
plan: init
	terraform -chdir=$(CHDIR) plan -var-file=$(VARS)/$(ENV).tfvars

.PHONY: apply
apply: init
	terraform -chdir=$(CHDIR) apply -var-file=$(VARS)/$(ENV).tfvars

.PHONY: destroy
destroy: init
	terraform -chdir=$(CHDIR) destroy -var-file=$(VARS)/$(ENV).tfvars

.PHONY: destroy-cluster
destroy-cluster: init
	terraform -chdir=$(CHDIR) destroy -var-file=$(VARS)/$(ENV).tfvars -target=module.gke


.PHONY: output
output: init
	terraform -chdir=$(CHDIR) output


.PHONY: helm-external-secrets
helm-external-secrets:
	helm install external-secrets external-secrets/external-secrets \
	    -n external-secrets \
	    --create-namespace \
	    -f helm/values/external-secrets.yaml \
	    --set-json 'serviceAccount.annotations={"iam.gke.io/gcp-service-account": "external-secrets@PROJECT_ID.iam.gserviceaccount.com"}'

