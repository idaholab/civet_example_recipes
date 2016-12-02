#!/bin/bash
#REQUIRED: APPLICATION_REPO
#OPTIONAL: EXTRA_ARGS: additional options to configure libmesh
init_script || exit 1

if [ -d "$MOOSE_REPO/libmesh" ]; then
  cd "$MOOSE_REPO/libmesh"
  exitIfReturnCode $?
  print_and_run git clean -xffdq
  exitIfReturnCode $?
fi

cd "$MOOSE_REPO/scripts"
exitIfReturnCode $?

if [ "$EXTRA_ARGS" != "" ]; then
  printf "Configuring libmesh with extra args: $EXTRA_ARGS\n"
fi

print_and_run ./update_and_rebuild_libmesh.sh --with-metis=PETSc --with-vtk-lib="$VTKLIB_DIR" --with-vtk-include="$VTKINCLUDE_DIR" $LIBMESH_OPTIONS $EXTRA_ARGS
exitIfReturnCode $?

printf "\nSuccessfully built libmesh.\n"

exit 0
