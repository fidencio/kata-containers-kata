#!/usr/bin/env bats
# Copyright (c) 2023 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

load "${BATS_TEST_DIRNAME}/lib.sh"
load "${BATS_TEST_DIRNAME}/../../confidential/lib.sh"

# Allow to configure the runtimeClassName on pod configuration.
RUNTIMECLASS="${RUNTIMECLASS:-kata-qemu}"
test_tag="[cc][agent][kubernetes][containerd]"
original_kernel_params=$(get_kernel_params)

setup() {
    start_date=$(date +"%Y-%m-%d %H:%M:%S")

    kubernetes_delete_all_cc_pods_if_any_exists || true

    echo "Prepare containerd for Confidential Container"
    SAVED_CONTAINERD_CONF_FILE="/etc/containerd/config.toml.$$"
#    configure_cc_containerd "$SAVED_CONTAINERD_CONF_FILE"

    echo "Reconfigure Kata Containers"
    switch_image_service_offload on
    clear_kernel_params
    add_kernel_params "${original_kernel_params}"

    setup_proxy
    switch_measured_rootfs_verity_scheme none

}

@test "$test_tag Test can getevidence" {

    if [ "${AA_KBC}" = "offline_fs_kbc" ]; then
        setup_offline_fs_kbc_aa_files_in_guest
    elif [ "${AA_KBC}" = "cc_kbc" ]; then
        # CC KBC is specified as: cc_kbc::http://host_ip:port/, and 60000 is the default port used
        # by the service, as well as the one configured in the Kata Containers rootfs.
	CC_KBS_IP=${CC_KBS_IP:-"$(hostname -I | awk '{print $1}')"}
	CC_KBS_PORT=${CC_KBS_PORT:-"60000"}
	add_kernel_params "agent.aa_kbc_params=cc_kbc::http://${CC_KBS_IP}:${CC_KBS_PORT}/"
    fi

    local base_config="${FIXTURES_DIR}/pod-config-aa.yaml.in"

    local pod_config=$(mktemp "$(basename ${base_config}).XXX")
    RUNTIMECLASS="$RUNTIMECLASS" envsubst \$RUNTIMECLASS < "$base_config" > "$pod_config"
    echo "$pod_config"

    kubernetes_create_cc_pod $pod_config
    rm $pod_config

   # Wait 5s for connecting with remote KBS
    sleep 5

    kubectl logs aa-test-cc
    kubectl logs aa-test-cc | grep -q "aatest"
}

teardown() {
    # Print the logs and cleanup resources.
    echo "-- Kata logs:"
    sudo journalctl -xe -t kata --since "$start_date" -n 100000

    # Allow to not destroy the environment if you are developing/debugging
    # tests.
    if [[ "${CI:-false}" == "false" && "${DEBUG:-}" == true ]]; then
        echo "Leaving changes and created resources untoughted"
        return
    fi

    kubernetes_delete_all_cc_pods_if_any_exists || true

    clear_kernel_params
    add_kernel_params "${original_kernel_params}"
    switch_image_service_offload off
    disable_full_debug
}

