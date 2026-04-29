# === Environment configuration === #

ALLOWED_ENVS := management development staging production

# Check if ENV is set and valid
ifndef ENV
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif
ifneq ($(filter $(ENV),$(ALLOWED_ENVS)),$(ENV))
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif

export ENVIRONMENT := $(ENV)

# === Google Cloud Platform === #
export MANAGEMENT_PROJECT_ID := management-b6d6
export REGION := europe-west1
PROJECT_ID_development := development-30af
PROJECT_ID_staging := staging-3924
PROJECT_ID_production := production-e6a8

PROJECT_ID := $(PROJECT_ID_$(ENVIRONMENT))

GAR_BASE := $(REGION)-docker.pkg.dev/$(MANAGEMENT_PROJECT_ID)/$(SERVICE_GROUP)

STATE_BUCKET := $(MANAGEMENT_PROJECT_ID)-tfstate




# === Module === #

ifeq ($(ENV),management)
  ALLOWED_MODS := $(notdir $(patsubst %/,%,$(wildcard terraform/modules/management/*/)))
  MOD ?= core
else
  ALLOWED_MODS := $(notdir $(patsubst %/,%,$(wildcard terraform/modules/environment/*/)))
  MOD ?= service-group
endif

ifneq ($(filter $(MOD),$(ALLOWED_MODS)),$(MOD))
  $(error For the $(ENV) environment, MOD is '$(MOD)', but must be one of: $(ALLOWED_MODS))
endif

# === Service Group === #

ifneq ($(ENV),management)
  ifeq ($(MOD),service-group)
    ifndef SG
      $(error SG (service group) not provided)
    endif
  endif
endif

# === Terraform arguments === #
 
# State prefix and directory depends on environment, module and service group
ifeq ($(ENV),management)
  CHDIR := terraform/modules/$(ENV)/$(MOD)
  PREFIX := $(ENV)/$(MOD)
  VARS_DIR := ../../../vars/$(ENV)
  VARS := \
	-var-file=$(VARS_DIR)/common.tfvars \
	-var-file=$(VARS_DIR)/$(MOD).tfvars
  # If it is not one of the following modules
  ifneq ($(filter-out core data-analytics,$(MOD)),)
    VARS := -var="project_id=$(MANAGEMENT_PROJECT_ID)"
  endif
else
  CHDIR := terraform/modules/environment/$(MOD)
  PREFIX := $(ENV)/$(MOD)
  VARS_DIR := ../../../vars/$(ENV)

  # --- Service Group --- #
  ifdef SG
    PREFIX := $(PREFIX)/$(SG)
    VARS_DIR := $(VARS_DIR)/service-group
    VARS := \
      -var="management_project_id=$(MANAGEMENT_PROJECT_ID)" \
      -var="environment=$(ENV)" \
      -var="service_group=$(SG)" \
      -var-file=$(VARS_DIR)/$(SG).tfvars
  else
    VARS := \
      -var="management_project_id=$(MANAGEMENT_PROJECT_ID)" \
      -var-file=$(VARS_DIR)/../common.tfvars \
      -var-file=$(VARS_DIR)/common.tfvars \
      -var-file=$(VARS_DIR)/$(MOD).tfvars
  endif

endif

# === Terraform Recipes === #

.PHONY: init
init:
	terraform -chdir=$(CHDIR) init \
		-reconfigure \
		-backend-config="bucket=$(STATE_BUCKET)" \
		-backend-config="prefix=$(PREFIX)"

.PHONY: init-migrate
init-migrate:
	terraform -chdir=$(CHDIR) init \
		-migrate-state \
		-backend-config="bucket=$(STATE_BUCKET)" \
		-backend-config="prefix=$(PREFIX)"

.PHONY: init-upgrade
init-upgrade:
	terraform -chdir=$(CHDIR) init -upgrade \
		-reconfigure \
		-backend-config="bucket=$(STATE_BUCKET)" \
		-backend-config="prefix=$(PREFIX)"

.PHONY: plan
plan: init
	terraform -chdir=$(CHDIR) plan $(VARS) $(TF_ARGS)

.PHONY: apply
apply: init
	terraform -chdir=$(CHDIR) apply -auto-approve $(VARS) $(TF_ARGS)

.PHONY: refresh
refresh: init
	terraform -chdir=$(CHDIR) refresh $(VARS)

.PHONY: destroy
destroy: init
	terraform -chdir=$(CHDIR) destroy $(VARS)

.PHONY: output
output: init
	terraform -chdir=$(CHDIR) output

.PHONY: import
import: init
	terraform -chdir=$(CHDIR) import $(VARS) -target=$(IMPORT_TO) $(IMPORT_TO) $(IMPORT_FROM)

.PHONY: target
apply-target: init
	terraform -chdir=$(CHDIR) apply -auto-approve $(VARS) -target=$(TARGET)

.PHONY: state-list
state-list: init
	terraform -chdir=$(CHDIR) state list

.PHONY: build
build:
	docker compose -f services\$(SG).yaml \
		--env-file services\.env.$(ENV) build

.PHONY: push
push:
	docker compose -f services\$(SG).yaml \
		--env-file services\.env.$(ENV) push \
		--ignore-push-failures

.PHONY: gke-connect
gke-connect:
	gcloud container clusters get-credentials \
		europe-west1 \
		--region $(REGION) \
		--project $(PROJECT_ID)

.PHONY: kafka-reset
kafka-reset: gke-connect
	kubectl -n ${SG} get kafkanodepools
	kubectl -n ${SG} delete --ignore-not-found kafkanodepools/broker
	kubectl -n ${SG} delete --ignore-not-found kafkanodepools/controller
	kubectl -n ${SG} delete --ignore-not-found pvc/data-0-paykit-broker-0 
	kubectl -n ${SG} delete --ignore-not-found pvc/data-0-paykit-controller-1
	helm -n ${SG} upgrade ${SG} helm/charts/service-group --reuse-values

