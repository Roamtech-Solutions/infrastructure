MANAGEMENT_PROJECT_ID := management-b6d6
STATE_BUCKET := $(MANAGEMENT_PROJECT_ID)-tfstate

ALLOWED_ENVS := management development staging production
ALLOWED_MODULES := $(shell ls -d terraform/modules/environment/*/ | cut -f4 -d'/')

# Check if ENV is set and valid
ifndef ENV
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif
ifneq ($(filter $(ENV),$(ALLOWED_ENVS)),$(ENV))
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif

# Layer check
MODULE ?= core
ifneq ($(filter $(MODULE),$(ALLOWED_MODULES)),$(MODULE))
  $(error MODULE must be one of: $(ALLOWED_MODULES))
endif


# State prefix and directory depends on environment and layer
ifeq ($(ENV),management)
CHDIR := terraform/modules/management
PREFIX := $(ENV)
VARS := 
VARS_DIR := ../../vars
VARS := \
	-var-file=$(VARS_DIR)/common.tfvars \
	-var-file=$(VARS_DIR)/$(ENV).tfvars
else
CHDIR := terraform/modules/environment/$(MODULE)
PREFIX := $(ENV)/$(MODULE)
VARS_DIR := ../../../vars/$(ENV)
VARS := \
	-var="management_project_id=$(MANAGEMENT_PROJECT_ID)" \
	-var-file=$(VARS_DIR)/../common.tfvars \
	-var-file=$(VARS_DIR)/common.tfvars \
	-var-file=$(VARS_DIR)/$(MODULE).tfvars
endif

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
		-backend-config="prefix=$(PREFIX)"

.PHONY: plan
plan: init
	terraform -chdir=$(CHDIR) plan $(VARS)

.PHONY: apply
apply: init
	terraform -chdir=$(CHDIR) apply -auto-approve $(VARS)

.PHONY: destroy
destroy: init
	terraform -chdir=$(CHDIR) destroy -auto-approve $(VARS)

.PHONY: output
output: init
	terraform -chdir=$(CHDIR) output

