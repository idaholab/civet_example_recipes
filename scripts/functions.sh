#!/bin/bash

# Bad things can happen if BUILD_ROOT is not set
if [ -z "$BUILD_ROOT" ]; then
  echo "You need to set BUILD_ROOT"
  exit 1
fi

function command_exists()
{
  type "$1" &> /dev/null
}
export -f command_exists

function print_cmd()
{
  local p="$PWD/"
  local b="$BUILD_ROOT/"
  local cwd=${p/#$b/BUILD_ROOT/}
  # Use terminal color codes. 33 is yellow. 32 is green
  printf "\e[33m$cwd\e[0m: \e[32m$*\e[0m\n"
}
export -f print_cmd

function print_and_run()
{
  print_cmd $*
  "$@"
}
export -f print_and_run

function beginswith()
{
  case $2 in "$1"*)
    true;;
  *)
    false;;
  esac
}
export -f beginswith

function print_header()
{
  printf "Date: $(date)\n"
  printf "Machine: $(hostname)\n"
  if command_exists lsb_release; then
    # for linux based systems
    lsb_release -a
  elif command_exists systeminfo; then
    # for windows
    systeminfo | grep '^OS'
  elif command_exists sw_vers; then
    # for mac
    sw_vers
  else
    printf "Unknown OS\n"
  fi
  if [ -e /opt/moose/build ]; then
    printf "MOOSE Package: $(cat /opt/moose/build)\n"
  elif command_exists dpkg; then
    moose_env=$(dpkg -s moose-environment 2>&1 | grep Version)
    if [ -n "$moose_env" ]; then
      printf "MOOSE Package $moose_env\n"
    else
      printf "MOOSE Package Unknown. Probably where it was built.\n"
    fi
  else
    printf "Cannot find MOOSE Package version.\n"
  fi
  printf "Build Root: $BUILD_ROOT\n"
  printf "Trigger: $cause\n"
  printf "Step: $step_name ($step_position)\n"
  if command_exists module; then
    module list
  else
    # windows doesn't have modules
    printf "No module system in place\n"
  fi
  printf "Base commit: $base_ssh_url:$base_ref:$base_sha\n"
  printf "Head commit: $head_ssh_url:$head_ref:$head_sha\n"
  printf "\n"
}
export -f print_header

function check_debug()
{
  if [ "$DEBUG_SCRIPT" == "1" ]; then
    set -x
  fi
}
export -f check_debug

function exitIfReturnCode()
{
  if [ "$1" != "0" ]; then
    echo "ERROR: exiting with code $1"
    exit $1
  fi
}
export -f exitIfReturnCode

function set_repo_dir()
{
  if [ -z "$1" ]; then
    echo "Need an argument."
    return
  fi
  export APPLICATION_NAME=$(basename "$1" .git)
  export REPO_DIR=$BUILD_ROOT/$APPLICATION_NAME
}
export -f set_repo_dir

function ensure_app_repo_exists()
{
  # Make sure the directory exists
  if [ -z "$APPLICATION_REPO" ]; then
    printf "You need to set the APPLICATION_REPO environment variable\n"
    exit 1
  fi
  set_repo_dir "$APPLICATION_REPO"

  if [ ! -d "$REPO_DIR" ]; then
    cd "$BUILD_ROOT"
    exitIfReturnCode $?
    # Check it out
    printf "$APPLICATION_NAME directory doesn't exist, cloning from $APPLICATION_REPO ...\n"
    git clone "$APPLICATION_REPO"
    exitIfReturnCode $?

    cd "$APPLICATION_NAME"
    exitIfReturnCode $?
    printf "Updating submodules for $APPLICATION_NAME\n"
    git submodule update --init --recursive
    exitIfReturnCode $?
    git submodule status --recursive
    printf "$APPLICATION_NAME created\n"
  fi
}
export -f ensure_app_repo_exists

function init_jobs()
{
  local TEST_LOAD_ARGS=""
  local TEST_ARGS=""
  local MAKE_ARGS=""
  local MAKE_LOAD_ARGS=""

  # for backwards compatibility
  if [ -n "$MOOSE_JOBS" ]; then
    TEST_ARGS="-j $MOOSE_JOBS"
    MAKE_ARGS="-j $MOOSE_JOBS"
  fi

  if [ -n "$MAX_TEST_LOAD" ]; then
    TEST_LOAD_ARGS="-l $MAX_TEST_LOAD"
  fi
  if [ -n "$TEST_JOBS" ]; then
    TEST_ARGS="-j $TEST_JOBS"
  fi
  export DEFAULT_TEST_ARGS="$TEST_ARGS $TEST_LOAD_ARGS"
  export MOOSE_LOAD="$DEFAULT_TEST_ARGS" # used by test_subs target in modules Makefile

  if [ -n "$MAKE_JOBS" ]; then
    MAKE_ARGS="-j $MAKE_JOBS"
  fi
  if [ -n "$MAX_MAKE_LOAD" ]; then
    MAKE_LOAD_ARGS="-l $MAX_MAKE_LOAD"
  fi
  export DEFAULT_MAKE_ARGS="$MAKE_ARGS $MAKE_LOAD_ARGS"
}
export -f init_jobs

function init_script()
{
  check_debug
  print_header
  ensure_app_repo_exists
  init_jobs
}
export -f init_script

function clean_submodules()
{
  # make sure submodules are clean
  print_and_run git submodule foreach --recursive 'git reset --hard'
  exitIfReturnCode $?
  print_and_run git submodule update --init --recursive
  exitIfReturnCode $?
  print_and_run git submodule foreach --recursive 'git clean -xffdq'
  exitIfReturnCode $?
  print_and_run git submodule status --recursive
}
export -f clean_submodules

function clean_repo()
{
  # start with a hard reset in case there are any changes
  print_and_run git reset --hard
  exitIfReturnCode $?
  print_and_run git clean -xffdq
  exitIfReturnCode $?
  clean_submodules
}
export -f clean_repo

function reset_repo()
{
  local branch=${1:-"$base_ref"}
  # we need to reset first so that if there was a failed
  # merge or something we get to a decent state
  # before we do a checkout
  print_and_run git reset --hard
  exitIfReturnCode $?
  print_and_run git clean -xffdq
  exitIfReturnCode $?

  print_and_run git fetch origin
  exitIfReturnCode $?

  # go to master because the test branch might
  # have bad submodules
  print_and_run git checkout master
  exitIfReturnCode $?
  print_and_run git reset --hard origin/master
  exitIfReturnCode $?

  clean_repo

  print_and_run git checkout "$branch"
  exitIfReturnCode $?
  print_and_run git reset --hard "origin/$branch"
  exitIfReturnCode $?
  print_and_run git submodule update --init --recursive
  exitIfReturnCode $?
  print_and_run git branch -D test
}
export -f reset_repo
