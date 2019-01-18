MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := help
.PHONY: run
.DEFAULT_GOAL := help

SHELL = /bin/bash -o pipefail

## display this help message
help:
	@awk '/^##.*$$/,/^[~\/\.a-zA-Z_-]+:/' $(MAKEFILE_LIST) | awk '!(NR%2){print $$0p}{p=$$0}' | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' | sort

## setup virtualenv
venv:
	pipenv install

## fetch twitter likes from last known id
fetch:
	pipenv run python get_favs.py

## list database
list-db:
	echo list | gdbmtool favs
