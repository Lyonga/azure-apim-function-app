# Dev Platform V2 Connectivity

## Purpose

This stack is the shared network foundation for the `dev` platform plane.

It owns the hub-side networking and the shared Private DNS zones that other
platform and workload stacks consume.

For the broader design rationale, see `terraform/README-v2.md`.

## Why This Stack Exists

- Workloads should not each create their own hub network.
- Private endpoint DNS works best when it is managed centrally.
- Shared network services need a separate lifecycle from application resources.

## What This Stack Owns

- the connectivity resource group
- the hub VNet
- the hub subnets
- the shared Private DNS zones
- the hub VNet links to those Private DNS zones

## What It Reads From

- direct environment inputs such as names, address spaces, and location
- optional `global/subscriptions` remote state for subscription validation

This stack does not depend on identity, management, or workload state.

## Main Inputs

- `subscription_id`
  - Makes the target subscription explicit and supports catalog validation.
- `location`
  - Defines where the platform network resources will live.
- naming inputs
  - Keep the hub VNet, resource group, and DNS naming consistent.
- hub address-space and subnet inputs
  - Define the network layout that downstream spokes will connect to.
- private DNS zone inputs
  - Define which centrally managed private service zones this platform should
    publish.

## What This Stack Does

- creates the connectivity resource group
- builds standard tags
- creates the hub VNet through the shared `vnet-hub` module
- creates the shared Private DNS zones
- links the hub VNet to those zones
- optionally validates that its subscription matches the central subscription
  catalog

## What Other Stacks Use From It

- `platform-v2/identity`
  - Uses the hub VNet and DNS information for peering and DNS linking.
- `workload-v2/*`
  - Use the hub VNet, DNS zones, and hub-side network metadata to attach their
    spokes and private endpoints.

This stack is one of the main shared-service providers in the platform layer.

## Main Building Blocks

- `module "tags"`
  - Builds the standard platform tag set.
- `module "resource_group"`
  - Creates the connectivity resource group.
- `module "hub_network"`
  - Creates the hub VNet and hub subnets.
- `module "private_dns"`
  - Creates the shared private DNS zones and hub links.

## Code Map

- `data.tf`
  - Optional subscription catalog validation.
- `main.tf`
  - Creates the resource group, hub network, and shared DNS.
- `outputs.tf`
  - Publishes hub and DNS outputs for downstream stacks.
- `dev.tfvars`
  - Supplies environment-specific naming and address space values.

## How To Extend It

- Add Bastion, Firewall, DNS resolver, or routing assets here if they are
  shared platform services.
- Keep spoke-local networking out of this root.
- Publish any new shared network fact as an output before expecting another
  stack to consume it.

## Best-Practice Notes

This is the right place for shared hub networking and shared Private DNS.

Keeping connectivity centralized makes it much easier for new engineers to see:

- where shared routing lives
- where private endpoint DNS is managed
- which outputs workload stacks should depend on
