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

## Publication

If you use PULP C910 in your work, please cite the following publication:

```
@inproceedings{fu2025ramping,
  author    = {Zexin Fu and Riccardo Tedeschi and Gianmarco Ottavi and Nils Wistoff and C{\'e}sar Fuguet and Davide Rossi and Luca Benini},
  title     = {Ramping Up Open-Source {RISC-V} Cores: Assessing the Energy Efficiency of Superscalar, Out-of-Order Execution},
  booktitle = {Proceedings of the 22nd ACM International Conference on Computing Frontiers (CF '25)},
  year      = {2025},
  pages     = {12--20},
  publisher = {ACM},
  address   = {Cagliari, Italy},
  doi       = {10.1145/3719276.3725186}
}
```

The following publication demonstrates the use of the PULP C910 core for research on secure out-of-order execution:
```
@inproceedings{wistoff2024fencets,
  author    = {Nils Wistoff and Gernot Heiser and Luca Benini},
  editor    = {Massimo Ruo Roch and Francesco Bellotti and Riccardo Berta and Maurizio Martina and Paolo Motto Ros},
  title     = {fence.t.s: Closing Timing Channels in High-Performance Out-of-Order Cores Through ISA-Supported Temporal Partitioning},
  booktitle = {Applications in Electronics Pervading Industry, Environment and Society},
  year      = {2024},
  pages     = {269--276},
  publisher = {Springer Nature Switzerland},
  address   = {Cham},
  isbn      = {978-3-031-84100-2},
  doi       = {10.1007/978-3-031-84100-2_32}
}
```
