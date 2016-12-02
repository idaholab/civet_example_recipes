#!/bin/bash
#REQUIRED: APPLICATION_REPO
#OPTIONAL: BRANCH_NAME: branch to checkout, default is master
init_script || exit 1

branch=${BRANCH_NAME:-"master"}

cd "$REPO_DIR"
exitIfReturnCode $?

reset_repo $branch

print_and_run git checkout "$branch"
exitIfReturnCode $?

printf "\nSuccessfully checked out $APPLICATION_NAME\n"

exit 0
