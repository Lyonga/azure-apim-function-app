#!/usr/bin/env bash
set -euo pipefail
ansible-playbook -i inventories/prod/azure_rm.yml playbooks/site.yml --check --diff
