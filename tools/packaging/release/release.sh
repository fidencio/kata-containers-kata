#!/usr/bin/env bash
#
# Copyright (c) 2024 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

[ -n "${DEBUG:-}" ] && set -o xtrace

RELEASE_TYPE="${RELEASE_TYPE:-minor}"

function _die()
{
        echo >&2 "ERROR: $*"
        exit 1
}

function _info()
{
        echo "INFO: $*"
}

function _next_release_number()
{
	local current_release=$(git describe --tags --abbrev=0)
	local current_major
	local current_everything_else
	local next_major
	local next_minor

	read current_major current_minor current_everything_else < <(echo $current_release | ( IFS="." ; read major minor everything_else && echo ${major:0:1} ${minor:0:1} $everything_else ))

	case $RELEASE_TYPE in
		major)
			next_major=$(expr $current_major + 1)
			next_minor=0
			;;
		minor)
			next_major=$current_major
			# As we're moving from an alpha release to the new scheme,
			# this check is needed for the very first release, after
			# that it can be dropped and only the else part can be
			# kept.
			if grep -qE "alpha|rc" <<< $current_everything_else; then
				next_minor=$current_minor
			else
				next_minor=$(expr $current_minor + 1)
			fi
			;;
		*)
			_die "$RELEASE_TYPE is not a valid release type, it must be: major or minor"
			;;
	esac

	next_release_number="$next_major.$next_minor.0"
	echo $next_release_number
}

function _update_version_file()
{
	local new_relase=$(_next_release_number)
	echo "$new_release" > "$repo_root_dir/VERSION"
	git diff
	git add "$repo_root_dir/VERSION"
	git commit -s -m "release: Kata Containers $new_release"
	git push
}

function _create_new_release()
{
	local new_release=$(_next_release_number)
	gh release create $new_release --release-notes 
}

function main()
{
	action="${1:-}"

	case "${action}" in
		get-release-number) _next_release_number ;;
		update-version-file) _update_version_file ;;
		create-new-release) _create_new_release ;;
		*) >&2 echo "Invalid argument"; exit 2 ;;
	esac
}

main "$@"
