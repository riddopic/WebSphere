
# CHANGELOG for WebSphere cookbook

v0.2.2 (2015-02-24)
-------------------

- Update local `.kitchen.yml` file to use the new repo `10.8.132.23`. This can
  be overridden in the `.kitchen.local.yml`.
- General code cleanup, removal of white spaces, methods and files no longer
  needed by the cookbook and remove incorrect reference to the winini cookbook.
- Rename `lazypath` method to `lazy_eval`. It can be used with any attribute
  that makes use of the DelayedEvaluator.
- Swap the `name` parameter of `websphere_profile` resource to be the `url` as
  it is always provided.
- Split the AppClient, Plugin and Customization toolbox offerings into separate
  cookbooks to be more modular.
- Added `update_all` and `update` action the the `websphere_package` resource.
- Added `repository_auth` resource to authenticate with remote IBM repositories
  and allow for updates to local repo.
- Flatten the array of provided repositories.
- Change the way packages are installed to avoid CHEF-3694. Group all
  prerequisite packages common to all WebSphere recipes into this recipe.
- Rename the `install` recipe to `iim` to better reflect the purpose of the
  recipe.

v0.2.1 (2015-02-12)
-------------------

- Add initial Chefspec tests.

v0.2.0 (2015-02-12)
-------------------

- Initial Release.
