# Example CIVET recipes
Example recipes and scripts for use with [CIVET](https://github.com/idaholab/civet)

These are example recipes taken from [MOOSE](https://github.com/idaholab/moose).
These would be triggered on the repo `github.com/gituser/gitrepo` and would test MOOSE.
To test another repo you would change the `APPLICATION_REPO` in the `.cfg` files.

It sets up 4 basic recipes.

1. `recipes/Basic.cfg`: Just runs a very basic command. For example, on `moosebuild.org` we run a `Pre check` that does some simple checks for code formatting, ticket reference, etc. This would automatically be triggered on pull requests and pushes to the `devel` branch.
2. `recipes/Test.cfg`: Fetches MOOSE, builds it, and runs through various tests. This would automatically be triggered on pull requests and pushes to the `devel` branch. It would not run unless `Basic` passed.
3. `recipes/Merge.cfg`: Triggered on a push to the `devel` branch. Typically after a pull request has been accepted. This does the actual merge from the `devel` branch to the `master` branch but only if `Test` passes.
4. `recipes/Valgrind.cfg`: Tests MOOSE with valgrind. This would automatically be triggered on pushes to the `master` branch. Typically after a succesfull `Merge`.
  Additionally, this can be manually added to pull requests. If added to a pull request then it would only run if `Basic` passed.

See `Recipe_Template.cfg` for a list of available options in the recipe file.

### License

Copyright 2016 Battelle Energy Alliance, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
