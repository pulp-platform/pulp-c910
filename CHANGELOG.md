# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## v0.2.0 - 2025-05-20
### Added
- OpenC910 with the following modifications
  - Replaced SRAM modules with tc_sram
  - Replaced internal SoC components with Cheshire ones, including ciu, l2c, clint, plic, and debug modules
  - Modified system memory mapping for Cheshire compatibility
  - Modified memory interface and LSU for Cheshire compatibility
  - Modified T-Head customised CSRs for Cheshire compatibility
- This version is compatible with Cheshire SoC, and can boot Linux with its SDK

## v0.1.0 - 2023-12-04
### Added
- OpenC910 with the following modifications:
  - Explicit header includes in SV files
  - tb extended with elf preloading and UART logging functionality
  - SW-writeable mrvbr CSR
  - Custom fence.t instruction
  - Fixed multiple intc signal drivers
  - Prefixed module names to avoid name collisions
  - Added debug probes
- Simulation and emulation infrastructure
