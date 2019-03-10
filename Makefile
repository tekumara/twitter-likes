MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := help
.PHONY: help venv fetch dump
.DEFAULT_GOAL := help

SHELL = /bin/bash -o pipefail

venv = ~/.virtualenvs/twitter-likes
python := $(venv)/bin/python

## display this help message
help:
	@awk '/^##.*$$/,/^[~\/\.a-zA-Z_-]+:/' $(MAKEFILE_LIST) | awk '!(NR%2){print $$0p}{p=$$0}' | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' | sort

$(venv): requirements.txt
	$(if $(value VIRTUAL_ENV),$(error Cannot create a virtualenv when running in a virtualenv. Please deactivate the current virtual env $(VIRTUAL_ENV)),)
	python3 -m venv --clear $(venv) && $(venv)/bin/pip install -r requirements.txt

## set up python virtual env and install requirements
venv: $(venv)

## fetch twitter likes from last known id
fetch:
	$(python) get_favs.py
	echo count | gdbmtool favs.db

## list database
dump:
	echo list | gdbmtool favs.db
