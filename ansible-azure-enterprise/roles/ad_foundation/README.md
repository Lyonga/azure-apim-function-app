# ad_foundation

Enterprise Ansible role for creating baseline Active Directory organizational
units and security groups on a domain controller or management host with the
ActiveDirectory PowerShell module available.

This role is intentionally narrower than the external sample it was inspired
by. It creates reusable AD structure, but it does not seed named users or
static passwords. That is a safer pattern for regulated environments.

## What it does

- installs the NuGet provider and `ActiveDirectoryDsc` PowerShell module
  needed by many Windows AD automation patterns
- builds the domain base DN from `ad_domain_name`
- creates standard OUs such as `Staff`, `Admins`, `Guests`, `Servers`, and
  `Service Accounts`
- creates a `Groups` OU
- creates baseline security groups such as `Employees`, `Guests`,
  `ServerAdmins`, and `AppSupport`

## How to use it

Enable the role with:

```yaml
ad_foundation_enabled: true
```

Optionally override:

- `ad_foundation_ous`
- `ad_foundation_groups`
- `ad_foundation_domain_server`
- `ad_foundation_group_ou_name`
- `ad_foundation_install_dsc_module`

The role expects the following vault-backed values to already exist:

- `ad_domain_name`
- `ad_join_user`
- `ad_join_password`
