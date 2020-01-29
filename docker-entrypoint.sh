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

_install_terraform_autocomplete() {
	# Use logical combination to prevent the shell from exiting if the grep
	# command does not find "terraform" in .bashrc
    grep terraform /root/.bashrc >/dev/null || \
		( \
			echo Installing terraform autocomplete && \
	    	terraform -install-autocomplete \
		)
}

_main() {
	_install_terraform_autocomplete

	# Run terraform with arguments received by CMD
    exec "$@"
}

if ! _is_sourced; then
	_main "$@"
fi
