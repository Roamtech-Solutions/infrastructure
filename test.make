DIRS := $(notdir $(patsubst %/,%,$(wildcard terraform/modules/management/*/)))

all:
	@echo "Found directories: $(DIRS)"

