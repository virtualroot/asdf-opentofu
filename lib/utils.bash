#!/usr/bin/env bash

set -euo pipefail

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for opentofu.
GH_REPO="https://github.com/opentofu/opentofu"
TOOL_NAME="tofu"
TOOL_TEST="tofu version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if opentofu is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
	# TODO: Adapt this. By default we simply list the tag names from GitHub releases.
	# Change this function if opentofu has other means of determining installable versions.
	list_github_tags
}

get_platform() {
	local -r kernel="$(uname -s)"
	if [[ ${OSTYPE} == "msys" || ${kernel} == "CYGWIN"* || ${kernel} == "MINGW"* ]]; then
		echo windows
	else
		uname | tr '[:upper:]' '[:lower:]'
	fi
}

get_arch() {
	local -r machine="$(uname -m)"

	if [[ ${machine} == "arm64" ]] || [[ ${machine} == "aarch64" ]]; then
		echo "arm64"
	elif [[ ${machine} == *"arm"* ]] || [[ ${machine} == *"aarch"* ]]; then
		echo "arm"
	elif [[ ${machine} == *"386"* ]]; then
		echo "386"
	else
		echo "amd64"
	fi
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"
	local -r platform="$(get_platform)"
	local -r arch="$(get_arch)"

	url="$GH_REPO/releases/download/v${version}/tofu_${version}_${platform}_${arch}.zip"

	echo "* Downloading $TOOL_NAME release v$version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3}"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
