#!/bin/bash
#REQUIRED: APPLICATION_REPO
init_script || exit 1

cd "$MOOSE_REPO/framework"
exitIfReturnCode $?

print_and_run make $DEFAULT_MAKE_ARGS
exitIfReturnCode $?

printf "\nSuccessfully built the MOOSE framework.\n"

exit 0
