## ===== **NOTE** =====
This project has been forked in order to speed up development.

This kernel will purely be an experimental sandbox for modern technologies such as USB or virtualization (Intel VT-d/x, AMD IOMMU, etc)

**Integrated features:**
- None

**Planned features:**
- Unknown

The rest of this README below starting with the logo is here to credit the original author of this kernel, but it does not apply to this project!

![alt text](slate.png "slate")

[![Build Status](https://travis-ci.org/404meemr/slate.svg?branch=master)](https://travis-ci.org/404meemr/slate)

### About
Slate is a simple, 64 bit x86 operating system that aims to implement some terrbile form of livepatching, where an image can be pulled from some source (some disk, some server) and then applied as the new kernel. 

### Features
- 64 bit Higher Half Long Mode
- Memory Management
- COM1 Serial
- VESA
- ACPI
- APICs
- HPET
- LAPIC Timer
- PCI
- UBSAN
- SMP
- Disk
    - VFS

### Planned Features
These are in order of implementation.
- Disk
    - AHCI
    - EXT2
- Scheduler (CFS)
- Syscalls
- Binary and ELF loading
- Userspace
- mlibc
- Intel HD Audio

### Building and Running

Prerequisites:
- nasm
- parted
- losetup
- mkfs
- make
- clang
- qemu

```
make [FS="ext2|echfs"] [-j<n>]
```
