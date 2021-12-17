# CheckerCab

`assert_values_for` and friends.

[View the full documentation on Hex](community.hexdocs.pm/checker_cab/api-reference.html).

## Installation

Add it to your deps.

```elixir
def deps do
  [
    ## check hex.pm for the latest version
    {:checker_cab, "~> 0.2.0", organization: "community", runtime: false, only: [:test]},
  ]
end
```

## Integrating into a test suite
Import `CheckerCab` to your test case file:
```elixir
## test/support/test_case.ex
defmodule YourApp.TestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import CheckerCab
    end
  end
end
```

Ensure the test case file is compiled for the `test` environment:

```elixir
## mix.exs
defmodule YourApp.MixProject
  use Mix.Project

  def project do
    [
      app: :your_app,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
    ]
  end

  ## skipping for brevity

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
```

And finally, ensure the test case file is used in a test:

```elixir
## test/your_app/contrived_example_test
defmodule YourApp.ContrivedExampleTest do
  use YourApp.TestCase

  ## tests go here.
end

```

That's it. You're ready to take advantage of the splendors of `CheckerCab`. Honk Honk 🚕

## Contributing
### Releasing a new version

To release a new version of this library, you have to

  * Bump the version
  * Update the changelog
  * Release on Hex

#### Updating version and changelog

To bump the version, update it in [`mix.exs`](./mix.exs). We use semantic versioning (`MAJOR.MINOR.PATCH`) which means:

  * Bump the `MAJOR` version only if there are breaking changes (first get approval from the maintainers)
  * Bump the `MINOR` version if you introduced new features
  * Bump the `PATCH` version if you fixed bugs

In the same code change that updates the version (such as a PR), also update the [`CHANGELOG.md`](./CHANGELOG.md) file with a new entry.

#### Publish on Hex

To publish this package:

  * Make sure you're authenticated as a local user with `mix hex.user auth`
  * Run `mix hex.publish`
