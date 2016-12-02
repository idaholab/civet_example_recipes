#!/bin/bash
#REQUIRED: APPLICATION_REPO
init_script || exit 1

cd "$REPO_DIR"
exitIfReturnCode $?

reset_repo

printf "\n\nChecking out $head_ssh_url:$head_ref:$head_sha\n"

if beginswith "Pull" "$cause"; then
  print_and_run git checkout -b test "origin/$base_ref"
  exitIfReturnCode $?

  # Merge the branch in the pull request into this one:
  print_and_run git pull "$head_ssh_url" "$head_ref"
  exitIfReturnCode $?
  branch_name=${head_repo}/${head_ref}
  printf "\nPulled $branch_name into $base_ref for testing.\n"
else
  # Push and manual
  print_and_run git checkout -b test "$head_sha"
  exitIfReturnCode $?
  printf "\nCreated test branch for $head_sha\n"
fi

print_and_run git submodule update --init --recursive

print_and_run git submodule status --recursive

exit 0
