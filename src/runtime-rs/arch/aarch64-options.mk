# Copyright (c) 2019-2022 Alibaba Cloud
# Copyright (c) 2019-2022 Ant Group
#
# SPDX-License-Identifier: Apache-2.0
#

MACHINETYPE :=
KERNELPARAMS := cgroup_no_v1=all
MACHINEACCELERATORS :=
CPUFEATURES := pmu=off

QEMUCMD := qemu-system-aarch64

# dragonball binary name
DBCMD := dragonball
FCCMD := firecracker
FCJAILERCMD := jailer
