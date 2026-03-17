# Dev Platform V2 Connectivity

## Purpose

This stack is the shared network foundation for the dev platform plane.

It owns the hub-side networking and the shared private DNS estate that other
platform and workload stacks consume.

For the broader design rationale, see `terraform/README-v2.md`.

## What This Stack Does

- creates the dev platform connectivity resource group
- creates the hub VNet through the `vnet-hub` module
- provisions the shared private DNS zones used for private endpoints
- links the hub VNet to those private DNS zones
- optionally validates that its explicit `subscription_id` matches the central
  subscription catalog

## What It Consumes

- explicit workload-independent naming and location variables
- optional `global/subscriptions` remote state for subscription validation
- no downstream platform stack state is required

## Child Modules And Resources

- `module "tags"`
  - builds the standard platform tagging model
- `module "resource_group"`
  - creates the connectivity resource group
- `module "hub_network"`
  - creates the hub VNet and hub subnets
  - optionally includes firewall-related assets through the shared hub module
- `module "private_dns"`
  - creates the private DNS zones
  - links those zones to the hub VNet

## What It Serves To Other Stacks

This stack publishes the platform network facts that downstream stacks need:

- `resource_group_name`
  - used by identity and workload stacks for DNS zone VNet links and hub peering
- `hub_vnet_id`
- `hub_vnet_name`
- `hub_subnet_ids`
- `firewall_private_ip`
- `private_dns_zone_ids`
- `private_dns_zone_names`

Consumers:

- `platform-v2/identity`
- `workload-v2/finserv-api`

## Code Map

- `data.tf`: optional subscription-catalog validation
- `main.tf`: tags, RG, hub VNet, private DNS
- `outputs.tf`: hub and DNS outputs consumed by child stacks
- `dev.tfvars`: environment-specific naming and address space

## How To Extend It

- add hub-side shared services such as Bastion, Firewall, DNS resolver, or
  additional routing when needed
- keep spoke-local constructs out of this root
- publish any new shared network dependency as an output before expecting
  workload stacks to consume it

## Best-Practice Context

This is the correct place for shared hub networking and shared private DNS. A
centralized connectivity plane makes private endpoint resolution, peering, and
inspection patterns much easier to standardize across landing zones.
