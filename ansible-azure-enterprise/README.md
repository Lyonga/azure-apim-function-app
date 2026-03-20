# Ansible Azure Enterprise

## Purpose

This repository configures Azure virtual machines after Terraform creates them.

Simple way to think about it:

- Terraform builds the server.
- Ansible configures the server.

This repository is the guest operating system baseline for Linux and Windows
servers in an Azure landing zone.

## What This Repository Does

It applies a repeatable server baseline such as:

- operating system hardening
- certificate trust
- proxy settings
- logging and audit configuration
- Azure Monitor Agent
- endpoint protection
- backup agent
- vulnerability scanner
- service accounts
- CIS-inspired controls
- optional runtimes such as Java, IIS, .NET, SQL tools, and `nginx`

## What This Repository Does Not Do

It does not create Azure infrastructure.

It expects these to already exist:

- virtual machines
- network access from the Ansible control node to the virtual machines
- Azure tags used by the dynamic inventory
- internal package locations, MSI paths, and secrets needed by enterprise
  agents

## Quick Start For New Engineers

If you are new to this tool, read in this order:

1. This README
2. [ansible.cfg](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/ansible.cfg)
3. One inventory file such as [inventories/dev/azure_rm.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/inventories/dev/azure_rm.yml)
4. One environment variable set:
   - [inventories/dev/group_vars/all.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/inventories/dev/group_vars/all.yml)
   - [inventories/dev/group_vars/linux.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/inventories/dev/group_vars/linux.yml)
   - [inventories/dev/group_vars/windows.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/inventories/dev/group_vars/windows.yml)
5. One entry playbook:
   - [playbooks/bootstrap-linux.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/playbooks/bootstrap-linux.yml)
   - [playbooks/bootstrap-windows.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/playbooks/bootstrap-windows.yml)
   - [playbooks/site.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/playbooks/site.yml)
6. One role, starting with:
   - [roles/common_baseline](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/common_baseline)
   - [roles/linux_baseline](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/linux_baseline)
   - [roles/windows_baseline](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/windows_baseline)

## Repository Map

This is the main folder layout and what each part is for.

### Root files

- [ansible.cfg](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/ansible.cfg)
  - default Ansible behavior for this repository
  - points to the inventory, roles path, collections path, and vault identity files
- [README.md](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/README.md)
  - the operator guide for the repository

### `inventories/`

This holds the environment-specific inventory and variables.

- `inventories/dev`
- `inventories/qa`
- `inventories/prod`

Each environment folder contains:

- `azure_rm.yml`
  - dynamic Azure inventory configuration
- `group_vars/all.yml`
  - shared values for all hosts in that environment
- `group_vars/linux.yml`
  - Linux-only values
- `group_vars/windows.yml`
  - Windows-only values
- `group_vars/vault.yml`
  - secrets, usually encrypted with Ansible Vault

### `playbooks/`

This holds the main entry points teams run.

- `bootstrap-linux.yml`
- `bootstrap-windows.yml`
- `site.yml`
- `patch-linux.yml`
- `patch-windows.yml`
- `validate.yml`
- `emergency-lockdown.yml`

### `roles/`

This holds the reusable building blocks.

Each role usually owns one area, such as:

- baseline
- hardening
- logging
- monitoring
- backup
- vulnerability management
- certificate trust
- runtimes

### `vars/`

This holds shared values used by the playbooks.

- [vars/global.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/vars/global.yml)
  - shared toggles such as Java, IIS, SQL tools, and reverse proxy
- [vars/compliance.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/vars/compliance.yml)
  - compliance and security settings reused across environments

### `collections/`

This holds Ansible collection requirements.

- [collections/requirements.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/collections/requirements.yml)

### `scripts/`

Utility scripts for inventory checks or release-related support.

### `ci/`

Pipeline helpers and CI-related assets.

## How A Run Works

This is the most important section for onboarding.

When someone runs a playbook, the repository works in this order.

### Step 1. `ansible.cfg` sets the defaults

[ansible.cfg](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/ansible.cfg)
defines:

- which inventory is used by default
- where Ansible should look for roles
- where Ansible should look for collections
- enabled inventory plugins
- SSH and connection settings
- fact caching
- vault identity files

Why this matters:

- engineers do not need to remember the same flags every time
- the repository behaves consistently across teams and environments

### Step 2. The inventory discovers Azure VMs

The inventory file such as
[inventories/dev/azure_rm.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/inventories/dev/azure_rm.yml)
uses the Azure dynamic inventory plugin.

That file decides:

- which Azure resource groups are searched
- which running VMs are included
- how hosts are grouped
- which Azure metadata becomes host variables

The inventory groups hosts from tags and metadata, for example:

- `tags.environment` -> `env_dev`, `env_prod`
- `tags.application` -> `app_finserv-api`
- `tags.role` -> `role_domaincontroller`, `role_web`, `role_app`
- OS type -> `linux`, `windows`

That is why teams can target groups instead of writing host lists by hand.

### Step 3. Variables are loaded

Variables come from several places.

Use them like this:

- `inventories/<env>/group_vars/all.yml`
  - environment-specific settings used by most roles
  - example: proxy, package URLs, backup agent toggle, scanner toggle
- `inventories/<env>/group_vars/linux.yml`
  - Linux-specific baseline values
  - example: package list, SSH settings, open port allowlist
- `inventories/<env>/group_vars/windows.yml`
  - Windows-specific baseline values
  - example: features, Chocolatey packages, remoting settings
- `inventories/<env>/group_vars/vault.yml`
  - secrets
  - example: domain join credentials, local admin passwords
- [vars/global.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/vars/global.yml)
  - shared repository-wide toggles
  - example: install Java, install IIS, install SQL tools
- [vars/compliance.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/vars/compliance.yml)
  - shared compliance settings
- `roles/<role>/defaults/main.yml`
  - safe fallback values for that role

Simple rule for new engineers:

- change `group_vars` when the value is environment-specific
- change `vars/global.yml` when the value should apply everywhere
- change role defaults only when you are changing the shared role behavior
- put secrets in `vault.yml`, not in plain text files

Practical override path:

- use `roles/<role>/defaults/main.yml` for safe built-in fallback values
- use `vars/global.yml` for shared repository settings
- use `inventories/<env>/group_vars/*.yml` for environment overrides
- use `-e` only for one-off run-time overrides

Example one-off override:

```bash
ansible-playbook -i inventories/dev/azure_rm.yml playbooks/bootstrap-linux.yml -e "linux_java_required=true"
```

Use `-e` carefully. It is best for short-lived testing, not as a long-term
configuration source.

### Step 4. The playbook chooses which roles run

The playbook is the main orchestration layer.

It decides:

- which hosts are targeted
- which shared variable files are loaded
- which roles run
- the order the roles run in
- any rollout controls such as batching or change-freeze checks

That order matters.

Example:

- certificate trust and proxy settings should exist before some agent downloads
- baseline and hardening should happen before final validation

### Step 5. Roles run their own tasks

Each role is a reusable unit with one job.

Most roles follow this structure:

- `defaults/main.yml`
  - role-specific fallback values
- `tasks/main.yml`
  - role entry point
- `tasks/linux.yml` or `tasks/windows.yml`
  - OS-specific tasks
- `handlers/main.yml`
  - delayed actions such as restarts
- `templates/`
  - configuration files built from variables
- `files/`
  - static files copied as-is

Examples:

- [roles/common_baseline/tasks/main.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/common_baseline/tasks/main.yml)
  - includes Linux or Windows tasks based on the host OS
- [roles/common_baseline/tasks/linux.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/common_baseline/tasks/linux.yml)
  - installs Linux baseline packages and settings
- [roles/common_baseline/tasks/windows.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/common_baseline/tasks/windows.yml)
  - installs Windows baseline packages and settings
- [roles/cert_trust/tasks/main.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/cert_trust/tasks/main.yml)
  - routes to Linux or Windows trust tasks
- [roles/cert_trust/tasks/linux.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/cert_trust/tasks/linux.yml)
  - copies CA files and triggers a trust refresh

### Step 6. Handlers and templates finish the job

Handlers run when a task reports a change and a follow-up action is needed.

Common examples:

- restart a service
- reload an agent
- refresh certificate trust

Templates are used when the output file depends on variables.

Common examples:

- proxy configuration
- log forwarding configuration
- backup agent configuration
- reverse proxy configuration

### Step 7. Validation confirms the end state

The run usually ends with the `validation` role or
[playbooks/validate.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/playbooks/validate.yml).

This checks that important services and settings exist after the run.

Why this matters:

- teams get a clear pass/fail result
- it is easier for junior engineers to trust the result
- it reduces the chance of partial configuration drift

## How The Main Playbooks Wire Everything Together

This section explains the entry playbooks in plain language.

### `playbooks/bootstrap-linux.yml`

Purpose:

- build the full Linux baseline for any Linux hosts returned by the selected
  inventory

How it is wired:

- targets the `linux` host group from the dynamic inventory
- loads:
  - `vars/global.yml`
  - `vars/compliance.yml`
- automatically also uses inventory `group_vars`
- then runs roles in this order:
  - `common_baseline`
  - `cert_trust`
  - `linux_baseline`
  - `linux_hardening`
  - `endpoint_proxy`
  - `audit_logging`
  - `azure_monitor_agent`
  - `defender_for_endpoint`
  - `backup_agent`
  - `vulnerability_scanner`
  - `service_accounts`
  - `cis_controls`
  - `java_runtime`
  - `sql_client_tools`
  - `nginx_reverse_proxy`
  - `validation`

Why this is useful:

- it gives teams one standard Linux build playbook
- most Linux baseline work happens here

### `playbooks/bootstrap-windows.yml`

Purpose:

- build the full Windows baseline for any Windows hosts returned by the
  selected inventory

How it is wired:

- first play:
  - targets the `windows` host group
  - loads:
    - `vars/global.yml`
    - `vars/compliance.yml`
  - automatically also uses inventory `group_vars`
  - then runs:
    - `common_baseline`
    - `cert_trust`
    - `domain_join`
    - `windows_baseline`
    - `windows_hardening`
    - `endpoint_proxy`
    - `audit_logging`
    - `azure_monitor_agent`
    - `defender_for_endpoint`
    - `backup_agent`
    - `vulnerability_scanner`
    - `service_accounts`
    - `cis_controls`
    - `dotnet_runtime`
    - `sql_client_tools`
    - `iis_baseline`
    - `validation`
- second play:
  - targets `windows:&role_domaincontroller`
  - loads the same shared vars
  - runs `ad_foundation`

Why there are two plays:

- most Windows servers need the normal baseline
- only domain controller hosts should manage AD OUs and groups

### `playbooks/site.yml`

Purpose:

- production rollout with extra safety controls

How it is wired:

- Linux play:
  - targets `linux:&env_prod`
  - uses rolling batches
  - checks `change_freeze`
  - runs the Linux production role chain
- Windows play:
  - targets `windows:&env_prod`
  - uses rolling batches
  - checks `change_freeze`
  - runs the Windows production role chain
- AD play:
  - targets `windows:&env_prod:&role_domaincontroller`
  - checks `change_freeze`
  - runs `ad_foundation`

Why this exists:

- production needs stricter rollout control than a simple bootstrap

### `playbooks/patch-linux.yml`

Purpose:

- patch Linux systems and reboot when required

### `playbooks/patch-windows.yml`

Purpose:

- install Windows updates and reboot when required

### `playbooks/validate.yml`

Purpose:

- run only the validation role
- useful after a rollout or during troubleshooting

### `playbooks/emergency-lockdown.yml`

Purpose:

- apply emergency restrictions quickly
- this should be reviewed carefully before use because it is intentionally
  disruptive

## Main Roles And What They Are For

### Baseline roles

- `common_baseline`
  - shared setup used by both Linux and Windows
- `linux_baseline`
  - Linux operating system baseline
- `windows_baseline`
  - Windows operating system baseline
- `linux_hardening`
  - Linux hardening controls
- `windows_hardening`
  - Windows hardening controls

### Security and operations roles

- `cert_trust`
  - installs corporate trust certificates
- `endpoint_proxy`
  - configures approved proxy settings
- `audit_logging`
  - configures audit and log forwarding
- `azure_monitor_agent`
  - installs Azure Monitor Agent
- `defender_for_endpoint`
  - enables or validates endpoint protection
- `backup_agent`
  - installs and configures the backup agent
- `vulnerability_scanner`
  - installs the vulnerability scanner agent
- `service_accounts`
  - creates approved service accounts
- `cis_controls`
  - applies CIS-inspired controls
- `validation`
  - checks the expected end state

### Optional workload roles

- `domain_join`
  - joins Windows systems to Active Directory
- `ad_foundation`
  - creates baseline AD OUs and security groups on domain controller hosts
- `java_runtime`
  - installs Java on Linux
- `dotnet_runtime`
  - installs the .NET hosting bundle on Windows
- `sql_client_tools`
  - installs SQL tools on Linux or Windows
- `nginx_reverse_proxy`
  - enables the Linux reverse proxy pattern
- `iis_baseline`
  - installs IIS on Windows

## Typical Installables For A Financial-Company Baseline

This repository already covers most of the installables a financial company
would normally expect at the OS layer.

### Linux

- `chrony` / `chronyd`
- `rsyslog`
- `audit` / `auditd`
- `curl`
- `jq`
- `unzip`
- `openssl`
- `ca-certificates`
- `python3-pip`
- `bind-utils`
- `nmap-ncat`
- optional Java runtime
- optional SQL client tools
- optional `nginx`

### Windows

- `RSAT-AD-PowerShell`
- `.NET Framework 4.5` core feature
- Chocolatey packages:
  - `7zip`
  - `notepadplusplus`
  - `sysinternals`
  - `microsoft-edge`
- optional IIS
- optional .NET hosting bundle
- optional SQL tools
- optional AD foundation for domain controller hosts

### Enterprise agents and controls

- Azure Monitor Agent
- Microsoft Defender for Endpoint / Windows Defender checks
- backup agent
- vulnerability scanner
- audit log forwarding
- proxy configuration
- service accounts
- CIS-inspired controls

## Important Variables And Where To Change Them

This is where engineers usually make changes.

### Environment-specific values

Change these in `inventories/<env>/group_vars/`:

- proxy settings
- package URLs
- MSI paths
- logging endpoints
- environment feature toggles

Main file:

- [inventories/dev/group_vars/all.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/inventories/dev/group_vars/all.yml)

### Linux-specific values

Change these in:

- [inventories/dev/group_vars/linux.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/inventories/dev/group_vars/linux.yml)

Typical changes:

- baseline package list
- SSH settings
- Linux security controls

### Windows-specific values

Change these in:

- [inventories/dev/group_vars/windows.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/inventories/dev/group_vars/windows.yml)

Typical changes:

- Windows features
- Chocolatey packages
- remoting settings

### Shared repository toggles

Change these in:

- [vars/global.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/vars/global.yml)

Typical changes:

- `linux_java_required`
- `windows_dotnet_required`
- `sql_client_tools_enabled`
- `nginx_reverse_proxy_enabled`
- `iis_baseline_enabled`

Use this file when the setting should be shared across environments.

Do not put secrets here. This file is for non-secret shared settings.

### Compliance settings

Change these in:

- [vars/compliance.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/vars/compliance.yml)

Use this file when the setting is part of the shared compliance model.

### Secrets

Store secrets in:

- `inventories/<env>/group_vars/vault.yml`

Examples:

- domain join credentials
- local admin passwords
- service account passwords

This is the right place for secret overrides by environment.

### Role-level defaults

Change role defaults only when you are intentionally changing the shared role
behavior for everyone.

Examples:

- [roles/common_baseline/defaults/main.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/common_baseline/defaults/main.yml)
- [roles/ad_foundation/defaults/main.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/ad_foundation/defaults/main.yml)

## What Is Ready Today

Ready once environment values are populated:

- Azure dynamic inventory
- Linux and Windows baseline playbooks
- production rollout playbook
- patch playbooks
- validation playbook
- enterprise roles for monitoring, protection, backup, scanning, and hardening

## What Must Be Replaced Before Production

- internal package URLs
- Windows MSI paths
- real backup and scanner package names if placeholders differ
- real proxy values
- real log forwarding destinations
- real corporate certificate files if the current files are placeholders
- real encrypted secrets in `vault.yml`

## Control Node Prerequisites

Before a team can run the playbooks, the control node needs:

- Python 3
- Ansible
- Azure CLI login or service principal authentication
- Ansible collections from
  [collections/requirements.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/collections/requirements.yml)
- PSRP support for Windows if the control node is Linux or macOS
- access to the vault password files referenced in
  [ansible.cfg](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/ansible.cfg)

Recommended setup:

```bash
cd ansible-azure-enterprise
python3 -m venv .venv
source .venv/bin/activate
pip install "ansible-core>=2.17,<2.19" pypsrp pywinrm
ansible-galaxy collection install -r collections/requirements.yml
az login
```

## Common Run Commands

Check the inventory:

```bash
ansible-inventory -i inventories/dev/azure_rm.yml --graph
```

List hosts:

```bash
ansible -i inventories/dev/azure_rm.yml all --list-hosts
```

Run Linux bootstrap:

```bash
ansible-playbook -i inventories/dev/azure_rm.yml playbooks/bootstrap-linux.yml
```

Run Windows bootstrap:

```bash
ansible-playbook -i inventories/dev/azure_rm.yml playbooks/bootstrap-windows.yml
```

Run production rollout:

```bash
ansible-playbook -i inventories/prod/azure_rm.yml playbooks/site.yml --check --diff
ansible-playbook -i inventories/prod/azure_rm.yml playbooks/site.yml
```

Run patching:

```bash
ansible-playbook -i inventories/prod/azure_rm.yml playbooks/patch-linux.yml
ansible-playbook -i inventories/prod/azure_rm.yml playbooks/patch-windows.yml
```

Run validation only:

```bash
ansible-playbook -i inventories/prod/azure_rm.yml playbooks/validate.yml
```

Target one application or host group:

```bash
ansible-playbook -i inventories/dev/azure_rm.yml playbooks/bootstrap-linux.yml --limit app_finserv-api
ansible-playbook -i inventories/dev/azure_rm.yml playbooks/bootstrap-windows.yml --limit role_domaincontroller
```

## Recommended Onboarding Path

For a junior engineer, the easiest way to understand the implementation is:

1. Read this README.
2. Read `ansible.cfg`.
3. Read one environment inventory.
4. Read the related `group_vars`.
5. Read one entry playbook.
6. Read the first few roles in that playbook in order.

That reading order matches how the repository actually runs.
