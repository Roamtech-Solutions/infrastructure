ALLOWED_ENVS := management development

# Check if ENV is set and valid
ifndef ENV
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif
ifneq ($(filter $(ENV),$(ALLOWED_ENVS)),$(ENV))
  $(error ENV must be one of: $(ALLOWED_ENVS))
endif

.PHONY: init
init:
	terraform -chdir=terraform init -reconfigure -backend-config="prefix=$(ENV)"

.PHONY: plan
plan: init
	terraform -chdir=terraform plan -var-file=vars/$(ENV).tfvars

.PHONY: apply
apply: init
	terraform -chdir=terraform apply -var-file=vars/$(ENV).tfvars

