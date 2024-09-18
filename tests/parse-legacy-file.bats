#!/usr/bin/env bats

# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2017 Jack Henry & Associates

setup() {
  ASDF_OPENTOFU="$(dirname "$BATS_TEST_DIRNAME")"
  PARSE_LEGACY_FILE="${ASDF_OPENTOFU}/bin/parse-legacy-file"
}

@test "supports legacy opentofu version 'required_version' with strict equality" {
  local -r expected_opentofu_version=0.13.7
  local -r tmpdir="$(mktemp -d)"
  local -r version_file="${tmpdir}/main.tofu"
  cat <<EOF >"${version_file}"
terraform {
  required_version = "= ${expected_opentofu_version}"
}
EOF

  local -r actual_opentofu_version="$(ASDF_OPENTOFU_THIS_PLUGIN=opentofu "${PARSE_LEGACY_FILE}" "${version_file}")"

  [[ ${actual_opentofu_version} == "${expected_opentofu_version}" ]]
}

@test "supports alternate file for opentofu version constraints" {
  local -r expected_opentofu_version=0.13.7
  local -r tmpdir="$(mktemp -d)"
  local -r version_file="${tmpdir}/versions.tofu"
  cat <<EOF >"${version_file}"
terraform {
  required_version = "= ${expected_opentofu_version}"
}
EOF

  local -r actual_opentofu_version="$(ASDF_OPENTOFU_VERSION_FILE=versions.tofu ASDF_OPENTOFU_THIS_PLUGIN=opentofu "${PARSE_LEGACY_FILE}" "${version_file}")"

  [[ ${actual_opentofu_version} == "${expected_opentofu_version}" ]]
}

@test "supports legacy opentofu version 'required_version' with strict equality, no equals literal" {
  local -r expected_opentofu_version=0.13.7
  local -r tmpdir="$(mktemp -d)"
  local -r version_file="${tmpdir}/main.tofu"
  cat <<EOF >"${version_file}"
terraform {
  required_version = "${expected_opentofu_version}"
}
EOF

  local -r actual_opentofu_version="$(ASDF_OPENTOFU_THIS_PLUGIN=opentofu "${PARSE_LEGACY_FILE}" "${version_file}")"

  [[ ${actual_opentofu_version} == "${expected_opentofu_version}" ]]
}

@test "supports legacy file .opentofu-version" {
  local -r expected_opentofu_version=0.13.7
  local -r tmpdir="$(mktemp -d)"
  local -r version_file="${tmpdir}/.opentofu-version"

  echo "${expected_opentofu_version}" >"${tmpdir}/.opentofu-version"

  local -r actual_opentofu_version="$(ASDF_OPENTOFU_THIS_PLUGIN=opentofu "${PARSE_LEGACY_FILE}" "${version_file}")"

  [[ ${actual_opentofu_version} == "${expected_opentofu_version}" ]]
}

@test "does not support 'not equal' version constraint expressions" {
  local -r tmpdir="$(mktemp -d)"
  local -r version_file="${tmpdir}/main.tofu"
  cat <<EOF >"${version_file}"
terraform {
  required_version = "!= 0.13.7"
}
EOF

  local -r actual_opentofu_version="$(ASDF_OPENTOFU_THIS_PLUGIN=opentofu "${PARSE_LEGACY_FILE}" "${version_file}")"

  [[ ${actual_opentofu_version} == "" ]]
}

@test "does not support 'greater than' version constraint expressions" {
  local -r tmpdir="$(mktemp -d)"
  local -r version_file="${tmpdir}/main.tofu"
  cat <<EOF >"${version_file}"
terraform {
  required_version = "> 0.13.7"
}
EOF

  local -r actual_opentofu_version="$(ASDF_OPENTOFU_THIS_PLUGIN=opentofu "${PARSE_LEGACY_FILE}" "${version_file}")"

  [[ ${actual_opentofu_version} == "" ]]
}

@test "does not support 'less than' version constraint expressions" {
  local -r tmpdir="$(mktemp -d)"
  local -r version_file="${tmpdir}/main.tofu"
  cat <<EOF >"${version_file}"
terraform {
  required_version = "< 0.13.7"
}
EOF

  local -r actual_opentofu_version="$(ASDF_OPENTOFU_THIS_PLUGIN=opentofu "${PARSE_LEGACY_FILE}" "${version_file}")"

  [[ ${actual_opentofu_version} == "" ]]
}

@test "does not support squiggly arrow version constraint expressions" {
  local -r tmpdir="$(mktemp -d)"
  local -r version_file="${tmpdir}/main.tofu"
  cat <<EOF >"${version_file}"
terraform {
  required_version = "~> 0.13.7"
}
EOF

  local -r actual_opentofu_version="$(ASDF_OPENTOFU_THIS_PLUGIN=opentofu "${PARSE_LEGACY_FILE}" "${version_file}")"

  [[ ${actual_opentofu_version} == "" ]]
}

@test "does not support compound version constraint expressions" {
  local -r tmpdir="$(mktemp -d)"
  local -r version_file="${tmpdir}/main.tofu"
  cat <<EOF >"${version_file}"
terraform {
  required_version = "> 0.13.0, < 0.14.0"
}
EOF

  local -r actual_opentofu_version="$(ASDF_OPENTOFU_THIS_PLUGIN=opentofu "${PARSE_LEGACY_FILE}" "${version_file}")"

  [[ ${actual_opentofu_version} == "" ]]
}

# https://github.com/asdf-community/asdf-hashicorp/pull/43#discussion_r816027246
@test 'does not get confused by multiple legacy version files for different plugins' {
  local -r expected_opentofu_version=0.13.7
  local -r tmpdir="$(mktemp -d)"
  local -r version_file="${tmpdir}/main.tofu"
  cat <<EOF >"${version_file}"
terraform {
  required_version = "= ${expected_opentofu_version}"
}
EOF

  echo 'foo' >"${tmpdir}/.opentofu-version"

  local -r actual_opentofu_version="$(ASDF_OPENTOFU_THIS_PLUGIN=opentofu "${PARSE_LEGACY_FILE}" "${version_file}")"

  [[ ${actual_opentofu_version} == "${expected_opentofu_version}" ]]
}

@test "does not output error if required_version is not specified" {
  local -r tmpdir="$(mktemp -d)"
  local -r version_file="${tmpdir}/main.tofu"
  touch "${version_file}"

  local -r actual_opentofu_version="$(ASDF_OPENTOFU_THIS_PLUGIN=opentofu "${PARSE_LEGACY_FILE}" "${version_file}" 2>&1)"

  [[ ${actual_opentofu_version} == "" ]]
}
