MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := help
.PHONY: help venv fetch dump
.DEFAULT_GOAL := help

SHELL = /bin/bash -o pipefail

venv = ~/.virtualenvs/twitter-likes
python := $(venv)/bin/python
pip := $(venv)/bin/pip

## display this help message
help:
	@awk '/^##.*$$/,/^[~\/\.a-zA-Z_-]+:/' $(MAKEFILE_LIST) | awk '!(NR%2){print $$0p}{p=$$0}' | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' | sort

$(pip):
	# create new virtualenv $(venv) containing pip
	$(if $(value VIRTUAL_ENV),$(error Cannot create a virtualenv when running in a virtualenv. Please deactivate the current virtual env $(VIRTUAL_ENV)),)
	python3 -m venv --clear $(venv)

$(venv): requirements.txt $(pip)
	$(pip) install -r requirements.txt
	touch $(venv)


## set up python virtual env and install requirements
venv: $(venv)

## fetch twitter likes from last known id
fetch: $(venv)
	$(python) get_favs.py
	echo count | gdbmtool favs.db

## list database
dump-db:
	echo list | gdbmtool favs.db

## list handle and tweet text
text:
	cat favs.ndjson | jq -r '[.user.screen_name, .full_text] | @tsv'

## list newest tweets first
text-newest:
	cat favs.ndjson | jq -s -c -r 'sort_by(.created_at | strptime("%a %b %d %H:%M:%S %z %Y") | mktime) | reverse | .[] | [.created_at, .user.screen_name, .full_text] | @tsv'

## search favs.ndjson, eg: make find text=moat
find:
	grep -i $(text) favs.ndjson | jq -C '{link: ("https://twitter.com/"+.user.screen_name+"/status/"+.id_str)} + . | {full_text,created_at,link}'	