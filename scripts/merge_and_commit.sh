#!/bin/bash
#REQUIRED: APPLICATION_REPO
init_script || exit 1

cd "$REPO_DIR"
exitIfReturnCode $?

clean_repo

print_and_run git checkout master
exitIfReturnCode $?

# It's possible that master was updated since this recipe started.  Before we merge,
# we need to make sure it's up to date.  Note: If we allow concurrent builds, we
# can't guarentee that there won't be a race condition.  This late pull however should
# minimize that scenario.  If it fails... No big deal
print_and_run git pull --rebase origin master
exitIfReturnCode $?

revs=$(git rev-list master..$head_sha)
if [ x"$revs" != "x" ]; then

  # Get the commit logs
  logs=$(git log master..$head_sha)
  # Replace the ticket references in github commits with dashes
  logs=$(echo "$logs" | perl -pe 's/#\d{3,}/#----/g')

  # Merge
  print_and_run git merge --no-ff "$head_sha"
  exitIfReturnCode $?

  printf "\nSuccessfully merged to local master.\nPushing...\n"

  # Commit the changes to the Github repo
  print_and_run git push origin master
  exitIfReturnCode $?

  printf "\nSuccessfully merged $base_ref branch with master.\n"
else
  printf "\nNothing to do!\n"
fi

git branch -d test >/dev/null 2>&1

exit 0
