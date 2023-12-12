# PULP C910

<!-- Introduction -->
This repository hosts **PULP C910**, a superscalar out-of-order RISC-V core adapted from T-Head's openC910 (Alibaba Group) and integrated into the PULP ecosystem with several modifications.

---

## Directory Structure

<!-- Directory overview with explanations -->
```
├── .github/      # Continuous Integration and GitHub workflows
├── hw/           # Contains the wrappers of the C910 core
├── vendor/       # Third-party IP cores or external dependencies, including openC910
├── Bender.yml    # Dependencies
└── README.md
```

---


## Differences between Original C910 and PULP-C910

<!-- Highlighting the key architectural and integration differences -->
This repository adapts the original XuanTie C910 core to make it fully compatible with open-source SoC platforms, especially the [Cheshire SoC](https://github.com/pulp-platform/cheshire) and the PULP ecosystem.

### Major Modifications

- **Interrupt Handling**: Replaces the proprietary T-Head CLINT and PLIC with standard RISC-V versions.
- **AXI Compliance**: Removes non-standard AXI protocol extensions, e.g., decrement mode bursts, restoring full AXI protocol compliance.
- **Standardized Debug (WIP)**: In progress - aims to implement a fully RISC-V compliant debug module, including CSRs (`dcsr`, `dpc`, `dscratch`), debugmode exception handling, and `wfi` wake-up support.
- **SoC Integration**: Removes the C910's internal L2 cache and uses external L2 caches on Cheshire.
- **Linux Bootable**: Integrated into Cheshire SoC and verified to boot Linux on FPGA.

---

## License

<!-- Licensing information -->
Unless specified otherwise in the respective file headers, all code checked into this repository is made available under a permissive license. All hardware sources and tool scripts are licensed under the Solderpad Hardware License 0.51 (see LICENSE) or compatible licenses.
OpenC910 code is from Alibaba T-Head and licensed under Apache 2.0.

