STATE_BUCKET = "management-1ddd-tfstate"

ALLOWED_ENVS := management development staging
ALLOWED_LAYERS := core infra k8s

# Check if ENV is set and valid
ifndef ENV
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif
ifneq ($(filter $(ENV),$(ALLOWED_ENVS)),$(ENV))
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif

# Layer check
LAYER ?= core
ifneq ($(filter $(LAYER),$(ALLOWED_LAYERS)),$(LAYER))
  $(error LAYER must be one of: $(ALLOWED_LAYERS))
endif


# State prefix and directory depends on environment and layer
ifeq ($(ENV),management)
CHDIR := terraform/modules/management
PREFIX := $(ENV)
VARS_DIR := ../../vars
else
CHDIR := terraform/modules/environment/$(LAYER)
PREFIX := $(ENV)/$(LAYER)
VARS_DIR := ../../../vars
endif

# Variable files specific to the environment
VAR_FILES := \
	-var-file=$(VARS_DIR)/common.tfvars \
	-var-file=$(VARS_DIR)/$(ENV).tfvars


.PHONY: init
init:
	terraform -chdir=$(CHDIR) init \
		-reconfigure \
		-backend-config="bucket=$(STATE_BUCKET)" \
		-backend-config="prefix=$(PREFIX)"

.PHONY: init-upgrade
init-upgrade:
	terraform -chdir=$(CHDIR) init -upgrade \
		-reconfigure \
		-backend-config="prefix=$(PREFIX)"

.PHONY: plan
plan: init
	terraform -chdir=$(CHDIR) plan $(VAR_FILES)

.PHONY: apply
apply: init
	terraform -chdir=$(CHDIR) apply $(VAR_FILES)

.PHONY: destroy
destroy: init
	terraform -chdir=$(CHDIR) destroy $(VAR_FILES)

.PHONY: output
output: init
	terraform -chdir=$(CHDIR) output

