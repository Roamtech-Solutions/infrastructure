# === General Configurations === #

MANAGEMENT_PROJECT_ID := management-b6d6
STATE_BUCKET := $(MANAGEMENT_PROJECT_ID)-tfstate


# === Environment configuration === #

ALLOWED_ENVS := management development staging production

# Check if ENV is set and valid
ifndef ENV
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif
ifneq ($(filter $(ENV),$(ALLOWED_ENVS)),$(ENV))
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif


# === Module configuration === #

ALLOWED_MODS := $(shell ls -d terraform/modules/environment/*/ | cut -f4 -d'/')

MOD ?= service-group
ifneq ($(filter $(MOD),$(ALLOWED_MODS)),$(MOD))
 $(error MOD must be one of: $(ALLOWED_MODS))
endif


# === Service Group === #

ALLOWED_SGS := $(shell ls terraform/vars/$(ENV)/service-group | sed 's/.tfvars//g')
ifeq ($(MOD),service-group)
  ifneq ($(filter $(SG),$(ALLOWED_SGS)),$(SG))
    $(error SG must be one of: $(ALLOWED_SGS))
  endif
endif


# === Terraform arguments === #
 
# State prefix and directory depends on environment, module and service group
ifeq ($(ENV),management)
  CHDIR := terraform/modules/management
  PREFIX := $(ENV)
  VARS := 
  VARS_DIR := ../../vars
  VARS := \
	-var-file=$(VARS_DIR)/common.tfvars \
	-var-file=$(VARS_DIR)/$(ENV).tfvars
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
	terraform -chdir=$(CHDIR) plan $(VARS)

.PHONY: apply
apply: init
	terraform -chdir=$(CHDIR) apply -lock-timeout=5m -auto-approve $(VARS)

.PHONY: destroy
destroy: init
	terraform -chdir=$(CHDIR) destroy -auto-approve $(VARS)

.PHONY: output
output: init
	terraform -chdir=$(CHDIR) output

