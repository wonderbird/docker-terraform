#!/usr/bin/env bash
set -Eeuo pipefail

# This file has been adopted wildly from
# https://github.com/docker-library/postgres/blob/master/docker-entrypoint.sh

# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}

_main() {
    # Run terraform with arguments received by CMD
    exec "$@"
}

if ! _is_sourced; then
	_main "$@"
fi
