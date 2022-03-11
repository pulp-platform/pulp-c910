# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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
