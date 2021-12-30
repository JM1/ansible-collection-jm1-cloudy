# vim:set syntax=make:
# kate: syntax Makefile; tab-indents on; replace-tabs off;

read_yaml_key = $(shell python3 -c "import yaml; print(yaml.load(open('$(1)'), Loader=yaml.BaseLoader)['$(2)'])")

.DEFAULT_GOAL := all

CLTN_NAME := $(call read_yaml_key,"galaxy.yml","name")
CLTN_NAMESPACE := $(call read_yaml_key,"galaxy.yml","namespace")
CLTN_VERSION := $(call read_yaml_key,"galaxy.yml","version")
CLTN_FILE := $(CLTN_NAMESPACE)-$(CLTN_NAME)-$(CLTN_VERSION).tar.gz
CLTN_DIR := build
# NOTE: Keep lists of modules and roles in sync with README.md
CLTN_MODULES := 
CLTN_ROLES := $(shell cd roles && ls -1)

# Targets are sorted by name

all: lint build-collection
.PHONY: all

$(CLTN_DIR)/$(CLTN_FILE):
	@build_dir=$$(readlink -f $(CLTN_DIR) ); \
	[ ! -d .cache/build/ ] || rm -rf .cache/build/ && \
	mkdir -p .cache/build && \
	git archive master | tar -x -C .cache/build/ && \
	cd .cache/build/ && \
	ansible-galaxy collection build --output-path "$$build_dir"
# Build in a clean subdir without any ignored files and directories is required because Ansible Galaxy prior to 2.10
# does not support the 'build_ignore' flag in the collection metadata file 'galaxy.yml'.
# Ref.: https://docs.ansible.com/ansible/latest/dev_guide/collections_galaxy_meta.html

build-collection: $(CLTN_DIR)/$(CLTN_FILE)
.PHONY: build-collection

help-modules:
ifneq ($(CLTN_MODULES),)
	@ansible-doc --type module $(addprefix "$(CLTN_NAMESPACE).$(CLTN_NAME).",$(CLTN_MODULES))
endif
.PHONY: help-modules

install-required-collections:
	ansible-galaxy collection install --requirements-file requirements.yml
.PHONY: install-required-collections

install-required-roles:
	ansible-galaxy role install --role-file requirements.yml
.PHONY: install-required-roles

install-requirements: install-required-collections install-required-roles
.PHONY: install-requirements

lint: lint-ansible-lint lint-flake8 lint-yamllint
.PHONY: lint

# NOTE: Keep linting targets and its options in sync with official Ansible Galaxy linters at
#       https://github.com/ansible/galaxy/blob/master/galaxy/importer/linters/__init__.py

lint-ansible-lint: # lint roles
ifneq ($(CLTN_ROLES),)
	@ansible-lint \
		-p \
		$(addprefix "roles/",$(CLTN_ROLES)) \
		|| { [ "$?" = 2 ] && true; }
# ansible-lint exit code 1 is app exception, 0 is no linter err, 2 is linter err
endif
.PHONY: lint-ansible-lint

lint-flake8: # lint modules, module_utils, plugins and roles
# NOTE: Flake8 project options have been moved to file .flake8 and hence cmd line arg '--isolated' has been dropped
# NOTE: Option '--exit-zero' has been dropped because make is supposed to stop if there are errors
	@flake8 .
.PHONY: lint-flake8

lint-yamllint: # lint apbs und roles
ifneq ($(CLTN_ROLES),)
	@yamllint \
		-f parsable \
		-c '.yamllint.yml' \
		-- \
		$(addprefix "roles/",$(CLTN_ROLES))
endif
.PHONY: lint-yamllint

publish-collection:
	@ansible-galaxy collection publish $(CLTN_DIR)/$(CLTN_FILE)
.PHONY: publish-collection
