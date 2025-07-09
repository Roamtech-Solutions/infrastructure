ALLOWED_ENVS := management development staging

# Check if ENV is set and valid
ifndef ENV
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif
ifneq ($(filter $(ENV),$(ALLOWED_ENVS)),$(ENV))
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif

VAR_FILES := \
	-var-file=../../vars/common.tfvars \
	-var-file=../../vars/$(ENV).tfvars

# Management environment is built out of the module folder
ifeq ($(ENV),management)
CHDIR := terraform/modules/management
else
CHDIR := terraform/modules/environment
endif

.PHONY: init
init:
	terraform -chdir=$(CHDIR) init \
		-reconfigure \
		-backend-config="prefix=$(ENV)"

.PHONY: init-upgrade
init-upgrade:
	terraform -chdir=$(CHDIR) init -upgrade \
		-reconfigure \
		-backend-config="prefix=$(ENV)"

.PHONY: bootstrap
bootstrap: init
	terraform -chdir=$(CHDIR) apply $(VAR_FILES) \
		-target=module.project
	terraform -chdir=$(CHDIR) apply $(VAR_FILES) \
		-target=module.network
	terraform -chdir=$(CHDIR) apply $(VAR_FILES)

.PHONY: plan
plan: init
	terraform -chdir=$(CHDIR) plan $(VAR_FILES)

.PHONY: apply
apply: init
	terraform -chdir=$(CHDIR) apply $(VAR_FILES)

.PHONY: destroy
destroy: init
	terraform -chdir=$(CHDIR) destroy $(VAR_FILES)

.PHONY: destroy-cluster
destroy-cluster: init
	terraform -chdir=$(CHDIR) destroy $(VAR_FILES) -target=module.gke

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

