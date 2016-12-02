# Example CIVET recipes
Example recipes and scripts for use with [CIVET](https://github.com/idaholab/civet)

These are example recipes taken from [MOOSE](https://github.com/idaholab/moose).
These would be triggered on the repo `github.com/gituser/gitrepo` and would test MOOSE.
To test another repo you would change the `APPLICATION_REPO` in the `.cfg` files.

It sets up 3 basic recipes.
1. `Test`: Fetches MOOSE, builds it, and runs through various tests. This would automatically be triggered on pull requests and pushes to the `devel` branch.
2. `Merge`: Does the actual merge from the `devel` branch to the `master` branch only if `Test` passes.
3. `Valgrind`: Tests MOOSE with valgrind. This would automatically be triggered on pushes to the `master` branch. Typically after a succesfull `Merge`.
  Additionally, this can be manually added to pull requests.
