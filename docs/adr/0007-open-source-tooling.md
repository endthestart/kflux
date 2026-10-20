# 0007: Open-source tooling only

Date: 2026-10-20. Status: accepted.

## Context

kflux's build and test scripts once included VMware support.

## Decision

Everything in the repository builds and tests with open-source tools: QEMU
(KVM, HVF or TCG), OVMF and pacstrap. The rule covers the repository, not the
infrastructure it runs on. Any self-hosted CI runner must be network-isolated:
its own VLAN, no access to the owner's home network, and an egress firewall
that allows only GitHub and package mirrors.

## Consequences

- Anyone can reproduce the image build and VM tests with free software.
- VM boot tests on CI need KVM: a hosted runner with nested KVM, or an
  isolated self-hosted QEMU/KVM runner.
