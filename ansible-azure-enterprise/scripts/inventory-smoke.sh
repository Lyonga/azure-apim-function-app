#!/usr/bin/env bash
set -euo pipefail
ansible-inventory -i inventories/prod/azure_rm.yml --graph
