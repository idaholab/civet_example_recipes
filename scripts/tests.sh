#!/bin/bash
#REQUIRED: APPLICATION_REPO
# OPTIONAL: TEST_DIR where to run run_tests
# OPTIONAL: TEST_ARGS additional arguments to run_tests
# OPTIONAL: TEST_NO_PYTHON don't use python
REPO_DIR=$BUILD_ROOT/$APPLICATION_NAME
init_script || exit 1

cd "$REPO_DIR/$TEST_DIR"
exitIfReturnCode $?

# We want $TEST_ARGS to be expanded, so don't use quotes
if [ "$TEST_NO_PYTHON" == "1" ]; then
  print_and_run ./run_tests $DEFAULT_TEST_ARGS $TEST_ARGS
  exitIfReturnCode $?
else
  print_and_run python2.7 ./run_tests $DEFAULT_TEST_ARGS $TEST_ARGS
  exitIfReturnCode $?
fi

printf "\nSuccessfully tested $APPLICATION_NAME.\n"

exit 0
