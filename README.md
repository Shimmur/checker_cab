# CheckerCab

`assert_values_for` and friends.

[View the full documentation on
Hex](community.hexdocs.pm/checker_cab/api-reference.html).

## Explanation
### What is Checker Cab?
Checker Cab facilitates deep map comparisons within unit tests.

### How Will Checker Cab Improve My Unit Tests?
Checker Cab helps alleviate tedium in these testing scenarios:
  * Selective comparison on fields between maps.
  * Phoenix Controller tests where expected input is an atom-keyed map such as a
  struct and expected output is a string-keyed map such as a JSON response, but
  keys are otherwise the same name.
  * Comparisons between DateTime values and ISO-8601-formatted strings as values
    in otherwise-equivalent maps.
  * Identify exactly which value did not match between maps with many keys.
  * Update tests to account for new values added to a struct (or map used as a
    record).

When relying on this library for unit tests, it becomes easier to write more
thorough tests with the same amount of effort or less.

### Example
Assuming a `User` struct and a `Factory` module that may build parameters, a
controller test may look like this:

```elixir
  test "success: it returns a 200 and a newly updated `User`", %{conn: conn, user: %User{id: id}} do
    %User{} = expected_updates = MyApp.Factory.build(:user, id: id)

    conn = post(conn, Routes.user_path(conn, :update), user: expected_user)
    assert %{"id" => ^id} = json_response(conn, 200)["data"]
  end
```
This is a nice basis for a test to exercise HTTP response codes, but this does
not assert that actual values have been set. The assertions could be added
individually, with an assertion made for each field in the `User` struct.
However, this can bloat a test over time at the expense of test clarity. Let's
see it with Checker Cab instead.

```elixir
  test "success: it returns a 200 and a newly updated `User`", %{conn: conn, user: %User{id: id}} do
    %User{} = expected_updates = MyApp.Factory.build(:user, id: id)

    conn = post(conn, Routes.user_path(conn, :update), user: expected_user)
    ## new stuff
    assert returned_user = %{"id" => ^id} = json_response(conn, 200)["data"]

    ## note: assert_values_for/1 and fields_for/1 are provided by CheckerCab.
    assert_values_for(
      expected: expected_updates,
      actual: {returned_user, :string_keys},
      fields: fields_for(User)
    )
  end
```
Regardless of how many fields the `User` struct may have or have added to it,
the assertions lock down that the returned user will have all fields in the
`User` struct and the values will be the same. The test is self-updating and
will assist in catching regressions if the `update` function begins to set other
values or if the view code does not capture newly-added fields to the `User`
schema.

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
