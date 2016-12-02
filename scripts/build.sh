#!/bin/bash
#REQUIRED: APPLICATION_REPO
#OPTIONAL: APP_SUBDIR : subdir to do make in
#OPTIONAL: MAKE_ARGS : additional arguments to make
init_script || exit 1

SUBDIR=$REPO_DIR/$APP_SUBDIR
cd "$SUBDIR"
exitIfReturnCode $?

print_and_run make $DEFAULT_MAKE_ARGS $MAKE_ARGS
exitIfReturnCode $?

printf "\nSuccessfully built $APP_SUBDIR $DEFAULT_MAKE_ARGS $MAKE_ARGS\n"

exit 0
