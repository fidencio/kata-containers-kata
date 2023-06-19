# Copyright Intel Corporation, 2022 IBM Corp.
#
# SPDX-License-Identifier: Apache-2.0

# Specify alternative base image, e.g. clefos for s390x
ARG BASE_IMAGE_NAME=ubuntu
ARG BASE_IMAGE_TAG=20.04
FROM $BASE_IMAGE_NAME:$BASE_IMAGE_TAG
ENV DEBIAN_FRONTEND=noninteractive
ARG KATA_ARTIFACTS_515=./kata-static-5.15.tar.xz
ARG KATA_ARTIFACTS_519=./kata-static-5.19.tar.xz
ARG KATA_ARTIFACTS_62=./kata-static-6.2.tar.xz
ARG DESTINATION_515=/opt/kata-artifacts-5.15
ARG DESTINATION_519=/opt/kata-artifacts-5.19
ARG DESTINATION_62=/opt/kata-artifacts-6.2

COPY ${KATA_ARTIFACTS_515} ${WORKDIR}
COPY ${KATA_ARTIFACTS_519} ${WORKDIR}
COPY ${KATA_ARTIFACTS_62} ${WORKDIR}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
apt-get update && \
apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl gpg xz-utils systemd && \
mkdir -p /etc/apt/keyrings/ && \
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg && \
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
apt-get update && \
apt-get install -y --no-install-recommends kubectl && \
apt-get clean && rm -rf /var/lib/apt/lists/ && \
mkdir -p ${DESTINATION_515} ${DESTINATION_519} ${DESTINATION_62} && \
tar xvf ${WORKDIR}/${KATA_ARTIFACTS_515} -C ${DESTINATION_515} && \
tar xvf ${WORKDIR}/${KATA_ARTIFACTS_519} -C ${DESTINATION_519} && \
tar xvf ${WORKDIR}/${KATA_ARTIFACTS_62} -C ${DESTINATION_62} && \
rm -f ${WORKDIR}/${KATA_ARTIFACTS_515} ${WORKDIR}/${KATA_ARTIFACTS_519} ${WORKDIR}/${KATA_ARTIFACTS_62}

COPY scripts ${DESTINATION}/scripts
