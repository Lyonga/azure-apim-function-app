# Ansible Azure Enterprise

## Purpose

This repository applies the guest operating system baseline for Azure virtual
machines after Terraform has created the infrastructure.

It is the operating-system layer of the landing zone pattern:

- Terraform creates subscriptions, resource groups, networks, private
  connectivity, and virtual machines.
- Ansible connects to those virtual machines and applies the server baseline.

For a new engineer, the simplest way to think about this repository is:

- Terraform decides where the server lives.
- Ansible decides how the server is configured.

## Why This Repository Exists

Financial companies usually need more than a basic package install on Linux and
Windows servers. They need a repeatable baseline that can be applied across
many subscriptions, environments, and application teams.

This repository exists to standardize that baseline:

- operating system hardening
- corporate certificate trust
- proxy configuration
- logging and audit forwarding
- Azure Monitor Agent deployment
- endpoint protection
- backup agent installation
- vulnerability scanner installation
- service account creation
- CIS-inspired controls
- optional application runtimes and server features

Without a repository like this, each application team tends to configure
servers differently. That leads to audit gaps, inconsistent patching, and
slower onboarding.

## What This Repository Owns

This repository owns guest configuration only.

It does not create Azure infrastructure. It assumes the following already
exist:

- Azure virtual machines
- network access from the Ansible control node to those virtual machines
- Azure tags that allow the dynamic inventory to group hosts correctly
- the private package paths, URLs, or repositories needed for enterprise
  agents

## What It Reads From

This repository reads its deployment model from four main places:

- `inventories/<env>/azure_rm.yml`
  - Azure dynamic inventory configuration
  - determines which VMs are in scope and how they are grouped
- `inventories/<env>/group_vars/all.yml`
  - environment-wide operational settings such as proxy, monitoring, backup,
    and scanner paths
- `inventories/<env>/group_vars/linux.yml`
  - Linux-specific baseline settings
- `inventories/<env>/group_vars/windows.yml`
  - Windows-specific baseline settings

It also reads shared defaults from:

- `vars/global.yml`
- `vars/compliance.yml`

## How The Inventory Works

The inventory uses the Azure dynamic inventory plugin in
[azure_rm.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/inventories/dev/azure_rm.yml).

This is important because the playbooks do not rely on a hand-maintained host
file. Instead, they discover running VMs directly from Azure and group them by
metadata.

The current grouping model uses:

- `tags.environment`
- `tags.application`
- `tags.role`
- `tags.osfamily`
- `location`

Why this matters:

- platform teams can target a whole environment without updating static files
- workload teams can target one application or server role
- the same playbooks work across dev, qa, and prod

The inventory currently prefers private IP addresses first and falls back to a
public IP only when needed. That is the right default for enterprise Azure
estates.

## How The Repository Is Wired

This section explains what happens when a team runs a playbook.

The important idea is that the repository is layered:

1. `ansible.cfg` sets the default behavior.
2. the selected inventory discovers hosts from Azure
3. inventory variables and shared variables define the deployment inputs
4. the playbook chooses which roles run and in what order
5. each role loads its own tasks, files, templates, defaults, and handlers
6. validation confirms the expected end state

### 1. `ansible.cfg` sets the default run behavior

[ansible.cfg](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/ansible.cfg)
defines the baseline runtime behavior for the whole repository.

This includes:

- the default inventory path
- the roles path
- the Ansible collections path
- enabled inventory plugins
- SSH settings
- fact caching
- vault identity files

Why this matters:

- teams do not need to repeat the same command flags every time
- inventory and vault usage stay consistent across environments

### 2. The inventory discovers hosts from Azure

The inventory file under `inventories/<env>/azure_rm.yml` uses the Azure
dynamic inventory plugin.

That file decides:

- which Azure resource groups are searched
- how running VMs are grouped
- which host variables are generated from Azure metadata

For example, the inventory creates groups from tags such as:

- `environment`
- `application`
- `role`
- `osfamily`

That is why a playbook can target groups like:

- `linux`
- `windows`
- `env_prod`
- `role_domaincontroller`

without anyone maintaining a static host list.

### 3. Variables are loaded from several layers

The repository uses several variable sources, each with a clear purpose.

#### Inventory `group_vars`

These are the first files most teams should learn:

- `inventories/<env>/group_vars/all.yml`
- `inventories/<env>/group_vars/linux.yml`
- `inventories/<env>/group_vars/windows.yml`
- `inventories/<env>/group_vars/vault.yml`

They answer questions like:

- Which proxy should servers use?
- Which package URL should the Azure Monitor Agent use?
- Should backup or vulnerability scanner roles run?
- What Linux packages make up the baseline?
- What Windows features and Chocolatey packages should be installed?
- What domain credentials should be used?

#### Shared `vars_files`

The playbooks also load shared variables from:

- [vars/global.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/vars/global.yml)
- [vars/compliance.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/vars/compliance.yml)

These files hold settings that are meant to be reused across all environments,
such as:

- optional runtime toggles
- compliance framework references
- shared security settings

#### Role defaults

Each role also has its own defaults in `roles/<role>/defaults/main.yml`.

Why this matters:

- a role can be reusable on its own
- the role keeps sensible defaults close to its implementation
- teams only override what they actually need

Example:

- [roles/common_baseline/defaults/main.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/common_baseline/defaults/main.yml)
- [roles/ad_foundation/defaults/main.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/ad_foundation/defaults/main.yml)

At a high level, think of the variable flow like this:

- inventory files decide environment-specific values
- shared `vars_files` decide repository-wide toggles and compliance settings
- role defaults provide safe fallbacks

### 4. The playbook chooses the execution order

The playbook is the orchestration layer.

Examples:

- [playbooks/bootstrap-linux.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/playbooks/bootstrap-linux.yml)
- [playbooks/bootstrap-windows.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/playbooks/bootstrap-windows.yml)
- [playbooks/site.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/playbooks/site.yml)

Each playbook decides:

- which hosts are in scope
- which shared variable files are loaded
- which roles run
- the order those roles run in
- any rollout controls such as serial batches or change-freeze checks

Why role order matters:

- proxy and certificate trust should exist before some agent downloads
- baseline and hardening should happen before final validation
- production runs may need stricter sequencing than development runs

### 5. Each role owns one functional area

The role is the main reusable unit in this repository.

Each role usually contains:

- `defaults/main.yml`
  - role-specific default values
- `tasks/main.yml`
  - the entry point for the role
- `tasks/linux.yml` or `tasks/windows.yml`
  - operating-system-specific implementation
- `handlers/main.yml`
  - delayed restarts or update actions
- `templates/`
  - generated config files
- `files/`
  - static files such as certificates

Examples:

- [roles/common_baseline/tasks/main.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/common_baseline/tasks/main.yml)
  - decides whether to include Linux or Windows tasks
- [roles/common_baseline/tasks/linux.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/common_baseline/tasks/linux.yml)
  - installs Linux packages and configures timezone and banner
- [roles/common_baseline/tasks/windows.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/common_baseline/tasks/windows.yml)
  - installs Windows features and packages
- [roles/cert_trust/tasks/main.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/cert_trust/tasks/main.yml)
  - routes to OS-specific certificate tasks
- [roles/cert_trust/tasks/linux.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/roles/cert_trust/tasks/linux.yml)
  - copies CA files and notifies the trust-update handler

This structure is what makes the repository understandable for new teams. Each
role has one job, and the playbook composes those jobs into a full server
baseline.

### 6. Handlers and templates finish the configuration

Handlers are used when a task changes something that requires a follow-up
action, such as:

- restarting a service
- refreshing certificate trust
- reloading an agent

Templates are used when a configuration file needs environment-aware content,
for example:

- proxy settings
- log forwarding configuration
- backup-agent configuration
- `nginx` configuration

This is why many roles have a `templates/` directory and a `handlers/main.yml`
file even when the main tasks are short.

### 7. Validation closes the loop

The repository ends with the `validation` role or the dedicated
[playbooks/validate.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/playbooks/validate.yml)
playbook.

That role checks that the expected services and settings exist after the run.

Why this matters:

- teams get a clear pass/fail signal
- it is easier to hand the tool to new engineers
- it reduces the chance that a playbook “succeeds” but leaves the host only
  partially configured

## Control Node Prerequisites

Before a team can run these playbooks, the control node needs:

- Python 3
- Ansible
- Azure CLI authenticated to the target subscription or tenant
- Ansible collections from
  [collections/requirements.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/collections/requirements.yml)
- PSRP support for Windows remoting if the control node is Linux or macOS
- access to the inventory-scoped Ansible Vault password files defined in
  [ansible.cfg](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/ansible.cfg)

Recommended setup sequence:

```bash
cd ansible-azure-enterprise
python3 -m venv .venv
source .venv/bin/activate
pip install "ansible-core>=2.17,<2.19" pypsrp pywinrm
ansible-galaxy collection install -r collections/requirements.yml
az login
```

If your organization uses service principals in CI instead of interactive
login, the Azure inventory can also work with the usual Azure environment
variables because `auth_source` is set to `auto`.

## What Is Deployable Today

The repository is already structured like a production baseline and is
deployable once the environment-specific placeholders are replaced.

Deployable now:

- Azure dynamic inventory for `dev`, `qa`, and `prod`
- Linux baseline and hardening
- Windows baseline and hardening
- certificate trust deployment
- audit logging configuration
- proxy configuration
- Azure Monitor Agent deployment
- Microsoft Defender deployment checks
- backup agent installation
- vulnerability scanner installation
- service account creation
- CIS-inspired settings
- Linux and Windows patching playbooks
- validation and emergency lockdown playbooks

Not deployable without organization-specific values:

- agent package URLs under `group_vars/all.yml`
- Windows MSI paths for backup, scanners, and optional runtimes
- real internal package names for backup and vulnerability agents
- production log forwarding targets
- real corporate certificate files if the provided files are only placeholders
- domain join credentials in inventory vault files

## Typical Financial-Company Installables Covered Here

This repository already covers most of the installables and controls that are
normally expected on regulated Linux and Windows servers.

### Linux baseline

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
- login banner
- strict SSH and sudo posture
- optional Java runtime
- optional SQL client tools
- optional `nginx` reverse proxy

### Windows baseline

- `RSAT-AD-PowerShell`
- `.NET Framework 4.5` core feature
- Chocolatey packages:
  - `7zip`
  - `notepadplusplus`
  - `sysinternals`
  - `microsoft-edge`
- Windows Time service configuration
- firewall baseline
- PowerShell logging
- optional domain join
- optional IIS baseline
- optional .NET hosting bundle
- optional SQL client tools

### Enterprise operational agents and controls

- Azure Monitor Agent
- Microsoft Defender for Endpoint / Windows Defender checks
- backup agent
- vulnerability scanner
- audit log forwarding
- proxy configuration for controlled egress
- service account scaffolding
- CIS-inspired operating-system controls
- validation checks after configuration
- optional Active Directory OU and security group foundation on domain
  controller hosts

## Playbooks And When To Use Them

### `playbooks/bootstrap-linux.yml`

Use this to apply the full Linux server baseline to any Linux hosts returned by
the selected inventory.

It now applies:

- common baseline
- certificate trust
- Linux baseline and hardening
- proxy configuration
- audit logging
- Azure Monitor Agent
- endpoint protection
- backup agent
- vulnerability scanner
- service accounts
- CIS-inspired controls
- optional Java, SQL tools, and nginx
- validation

Why this exists:

- it gives teams a standard first-pass server build
- it makes non-production rollout easy without using the production-only site
  playbook

### `playbooks/bootstrap-windows.yml`

Use this to apply the full Windows server baseline to any Windows hosts
returned by the selected inventory.

It now applies:

- common baseline
- certificate trust
- optional domain join
- Windows baseline and hardening
- proxy configuration
- audit logging
- Azure Monitor Agent
- endpoint protection
- backup agent
- vulnerability scanner
- service accounts
- CIS-inspired controls
- optional .NET runtime, SQL tools, and IIS
- validation

If the inventory contains Windows hosts tagged with `role=domaincontroller`,
the playbook also runs an additional Active Directory foundation play that can
create baseline OUs and security groups through the `ad_foundation` role when
that role is enabled.

### `playbooks/site.yml`

Use this for the production baseline rollout.

This playbook is stricter than the bootstrap playbooks:

- targets `env_prod`
- uses rolling batches
- honors change freeze controls

It is the right playbook when the team wants a controlled production rollout
instead of a simple baseline application.

### `playbooks/patch-linux.yml`

Use this for Linux package patching and reboot orchestration.

### `playbooks/patch-windows.yml`

Use this for Windows Update patching and reboot orchestration.

### `playbooks/validate.yml`

Use this when you only want post-configuration validation checks.

### `playbooks/emergency-lockdown.yml`

Use this when the environment needs a rapid restrictive response. Review it
carefully before use because this kind of playbook is intentionally disruptive.

## Main Roles And Why They Matter

### Baseline roles

- `common_baseline`
  - timezone, banner, shared account setup, and common platform defaults
- `linux_baseline`
  - Linux service and host baseline
- `windows_baseline`
  - Windows feature and package baseline
- `linux_hardening`
  - SSH posture, auditd, sudo path, core dump controls
- `windows_hardening`
  - firewall, logging, RDP posture, Windows feature reduction

### Security and operations roles

- `cert_trust`
  - installs corporate trust roots so internal TLS endpoints work
- `endpoint_proxy`
  - configures system proxy settings required in tightly controlled egress
    environments
- `audit_logging`
  - forwards logs and applies audit controls expected by security teams
- `azure_monitor_agent`
  - enables Azure monitoring integration
- `defender_for_endpoint`
  - ensures endpoint protection is present and running
- `backup_agent`
  - installs and configures backup software
- `vulnerability_scanner`
  - installs and starts the vulnerability management agent
- `service_accounts`
  - creates known service accounts in a standardized way
- `cis_controls`
  - applies a baseline set of CIS-inspired settings
- `validation`
  - confirms the expected services and connectivity settings exist after the
    run

### Optional application roles

- `domain_join`
  - joins Windows systems to Active Directory when enabled
- `ad_foundation`
  - installs supporting AD automation components and creates baseline Active
    Directory OUs and security groups on domain controller hosts when enabled
- `java_runtime`
  - installs Java on Linux when required by the workload
- `dotnet_runtime`
  - installs the .NET hosting bundle when required
- `sql_client_tools`
  - installs SQL tooling on Linux or Windows when needed
- `nginx_reverse_proxy`
  - enables a Linux reverse proxy pattern when the workload needs it
- `iis_baseline`
  - enables the standard IIS feature set when the workload is Windows-hosted

These optional roles are important because financial companies often want one
shared baseline repository, but not every server should carry every runtime.
The toggles let the team keep one pattern without turning every VM into the
same build.

## Important Inputs And Why They Matter

### Inventory-wide inputs in `group_vars/all.yml`

- `proxy_enabled`, `proxy_url`, `no_proxy_list`
  - needed when servers must egress through an approved enterprise proxy
- `monitoring_enabled`
  - controls whether the Azure Monitor Agent path runs
- `defender_enabled`
  - controls endpoint protection tasks
- `backup_agent_enabled`
  - controls backup agent installation
- `vuln_scanner_enabled`
  - controls vulnerability agent installation
- `audit_logging_enabled`
  - controls audit and log-forwarding configuration
- `service_accounts_enabled`
  - controls managed service account scaffolding
- `cis_controls_enabled`
  - controls CIS-inspired hardening tasks
- `ama_*`, `backup_agent_*`, `vuln_scanner_*`
  - these are the values most teams need to replace first because they point to
    actual installer locations

### Shared defaults in `vars/global.yml`

- `linux_java_required`
  - enables Java runtime installation when the workload needs it
- `windows_dotnet_required`
  - enables .NET hosting bundle installation
- `sql_client_tools_enabled`
  - enables SQL tooling for DB support workloads
- `nginx_reverse_proxy_enabled`
  - enables the Linux reverse-proxy role
- `iis_baseline_enabled`
  - enables the IIS role for Windows web workloads

Why these are in shared vars:

- they describe workload shape, not just environment
- teams can turn them on intentionally instead of having hidden package drift

### Active Directory foundation defaults

The `ad_foundation` role keeps its toggle and object lists inside the role
defaults so it can stay optional and easy to remove if a team does not want
Ansible managing AD structure.

Important values:

- `ad_foundation_enabled`
  - turns the role on
- `ad_foundation_ous`
  - defines the baseline OU structure
- `ad_foundation_groups`
  - defines the baseline security groups

This role only targets Windows hosts in the `role_domaincontroller` inventory
group, so normal member servers do not try to manage directory structure.

## How To Run It

### 1. Test inventory resolution

```bash
ansible-inventory -i inventories/dev/azure_rm.yml --graph
```

### 2. Preview which hosts are in scope

```bash
ansible -i inventories/dev/azure_rm.yml all --list-hosts
```

### 3. Run Linux bootstrap

```bash
ansible-playbook -i inventories/dev/azure_rm.yml playbooks/bootstrap-linux.yml
```

### 4. Run Windows bootstrap

```bash
ansible-playbook -i inventories/dev/azure_rm.yml playbooks/bootstrap-windows.yml
```

### 5. Run production rollout with safety controls

```bash
ansible-playbook -i inventories/prod/azure_rm.yml playbooks/site.yml --check --diff
ansible-playbook -i inventories/prod/azure_rm.yml playbooks/site.yml
```

### 6. Patch servers

```bash
ansible-playbook -i inventories/prod/azure_rm.yml playbooks/patch-linux.yml
ansible-playbook -i inventories/prod/azure_rm.yml playbooks/patch-windows.yml
```

### 7. Re-run validation only

```bash
ansible-playbook -i inventories/prod/azure_rm.yml playbooks/validate.yml
```

Useful targeting examples:

```bash
ansible-playbook -i inventories/dev/azure_rm.yml playbooks/bootstrap-linux.yml --limit app_finserv-api
ansible-playbook -i inventories/dev/azure_rm.yml playbooks/bootstrap-windows.yml --limit region_eastus2
ansible-playbook -i inventories/prod/azure_rm.yml playbooks/site.yml --limit public_facing
```

## Where Teams Usually Need To Customize First

When onboarding this pattern into a real organization, these are usually the
first files that need review:

- [inventories/dev/group_vars/all.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/inventories/dev/group_vars/all.yml)
  - replace package URLs, MSI paths, proxy values, and logging endpoints
- [inventories/dev/group_vars/linux.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/inventories/dev/group_vars/linux.yml)
  - confirm the Linux package baseline and security posture match the enterprise
- [inventories/dev/group_vars/windows.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/inventories/dev/group_vars/windows.yml)
  - confirm Windows features, Chocolatey packages, and remoting settings
- [vars/global.yml](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/ansible-azure-enterprise/vars/global.yml)
  - decide which optional runtime roles should be enabled for which workload
- `roles/cert_trust/files/`
  - replace certificate placeholders with the real corporate root and
    intermediate CAs

## Recommended Team Onboarding Order

For a new engineer, the fastest way to understand this repository is:

1. Read this README.
2. Read the environment inventory under `inventories/<env>/azure_rm.yml`.
3. Read `group_vars/all.yml` for that environment.
4. Read the bootstrap playbook for the operating system you care about.
5. Read the roles in this order:
   - `common_baseline`
   - OS baseline
   - OS hardening
   - logging / monitoring / defender / backup / scanner
   - validation

This sequence explains the pattern from discovery, to inputs, to execution, to
role implementation.

## Guidance From The External References Reviewed

The external references the team provided were useful mainly for confirming the
right operating model:

- role-based Ansible composition is easier to scale than large task files
- Azure dynamic inventory is the right fit for multi-environment VM estates
- Terraform and Ansible should stay separate, with Terraform creating the VM
  and Ansible applying the guest baseline
- the most useful reusable baseline content is security, observability,
  hardening, and operational agents rather than app-specific deployment logic

That is already the direction of this repository, so the changes here focus on
making the bootstrap path and documentation match that intent.

## Final Recommendation

This repository is a strong starting point for an enterprise server baseline.

The best way to use it across the organization is:

- keep the core baseline roles shared
- keep optional runtimes behind clear toggles
- keep environment-specific agent URLs and secrets in inventory vars and vault
  files
- let Terraform decide which VMs exist
- let Ansible decide how those VMs are configured

That separation is easier for new engineers to understand and easier for a
platform team to scale across more landing zones.
