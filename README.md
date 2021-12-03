# CheckerCab

`assert_values_for` and friends.


## Contributing
### Releasing a new version

To release a new version of this library, you have to

  * Bump the version
  * Update the changelog
  * Release on Hex

#### Updating version and changelog

To bump the version, update it in [`mix.exs`](./mix.exs). We use semantic versioning (`MAJOR.MINOR.PATCH`) which means:

  * Bump the `MAJOR` version only if there are breaking changes (first get approval from the platform pod)
  * Bump the `MINOR` version if you introduced new features
  * Bump the `PATCH` version if you fixed bugs

In the same code change that updates the version (such as a PR), also update the [`CHANGELOG.md`](./CHANGELOG.md) file with a new entry.

#### Publish on Hex

To publish this package:

  * Make sure you're authenticated as a local user with `mix hex.user auth`
  * Run `mix hex.publish`
