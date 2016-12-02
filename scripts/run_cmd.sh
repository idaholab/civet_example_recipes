#!/bin/bash
#REQUIRED: APPLICATION_REPO
#REQUIRED : RUN_CMD: run command
#OPTIONAL: APP_SUBDIR : subdir to run command in
REPO_DIR=$BUILD_ROOT/$APPLICATION_NAME
init_script || exit 1

SUBDIR=$REPO_DIR/$APP_SUBDIR
cd "$SUBDIR"
exitIfReturnCode $?

print_and_run $RUN_CMD
exitIfReturnCode $?

printf "\nSuccessfully ran $RUN_CMD\n"

exit 0
