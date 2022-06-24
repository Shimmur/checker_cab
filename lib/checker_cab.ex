defmodule CheckerCab do
  @moduledoc """
  Documentation for CheckerCab.

  This documentation assumes these functions are used in the context of unit
  tests.
  """
  import ExUnit.Assertions, only: [assert: 2, flunk: 1]

  @type option :: {:convert_dates, boolean()}

  @type comparable_input :: map() | {map(), :string_keys | :atom_keys}

  @type inputs :: [
          expected: comparable_input(),
          actual: comparable_input(),
          fields: list(atom()),
          skip_fields: list(atom()),
          opts: list(option)
        ]

  @doc """
  Returns the keys of a map or struct.

  ## Examples

      iex> fields_for(%{"string_key1" => :value, "string_key2" => :value})
      ["string_key1", "string_key2"]

      iex> fields_for(%{atom_key1: :value, atom_key2: :value})
      [:atom_key1, :atom_key2]

  Returns a list of defined keys from struct arguments (`:__struct__` is not
  returned)

      iex> fields_for(%StructModule{})
      [:key1, :key2, :key3]

  Returns a list of defined keys from `Ecto.Schema` arguments, but does not
  return virtual fields.

      iex> fields_for(%EctoSchemaModule{})
      [:id, :field1, :field2, :field3]

  Additionally, the function accepts the module name of an `Ecto.Schema`.
  This does not work with structs.

      iex> fields_for(EctoSchemaModule)
      [:id, :field1, :field2, :field3]
  """
  @spec fields_for(map() | struct() | Ecto.Schema.t() | module()) :: list(atom() | String.t())
  def fields_for(%schema_name{__meta__: _}) do
    schema_name.__schema__(:fields)
  end

  def fields_for(schema_name) when is_atom(schema_name) do
    schema_name.__schema__(:fields)
  end

  def fields_for(map) when is_map(map) do
    map
    |> Map.keys()
    |> Enum.reject(fn key -> key in [:__struct__] end)
  end

  @doc """
  Compares the values of two maps for specified keys.

  When values do not match, this function will flunk the current test with
  explicit information about the first value that did not match.

  This function also accepts a list of fields to _not_ compare, and can be mixed
  with the fields to compare.

  This function assumes keys are atoms unless specified as `:string_keys`, and
  will convert keys into a common type before comparing values (can compare
  atom-keyed and string-keyed maps with same-named keys). Additionally,
  `:atom_keys` can be provided to be more explicit.

  ## Options
  * `:convert_dates`
    When `true`, will convert date-representing values to ISO-8601 formatted
  strings.

  ## Examples
  ```
  ## your_unit_test.exs
  expected = %{key1: :value, key2: :value, key3: :value}
  actual = %{"key1" => :value, "key2" => :value, "key3" => :value}

  ## returns :ok when expected and actual match
  assert_values_for(
    expected: expected,
    actual: {actual, :string_keys},
    fields: [:key1, :key2, :key3]
  )
  ```

  With dates:

  ```
  expected = %{date: ~U[2021-12-17 03:08:36.579609Z], key2: :value, key3: :value}
  actual = %{"date" => "2021-12-17T03:08:36.579609Z", "key2" => :value, "key3" => :value}

  ## Will not flunk for different types of dates if they both convert to the
  same ISO 8601 string

  assert_values_for(
    expected: expected,
    actual: {actual, :string_keys},
    fields: [:date, :key2, :key3],
    opts: [convert_dates: true]
  )
  ```

  Using `:skip_fields`:

  ```
  expected = %{key1: :value, key2: :value, key3: :value, value_that_wont_match: "Panama"}
  actual = %{key1: :value, key2: :value, key3: :value, value_that_wont_match: "Manimal"}

  ## Returns :ok when expected and actual match. Can exclude fields anticipated
  to be different.
  assert_values_for(
    expected: expected,
    actual: actual,
    fields: [:key1, :key2, :key3],
    skip_fields: [:value_that_wont_match]
  )
  ```
  """
  @spec assert_values_for(inputs()) :: :ok | no_return()
  def assert_values_for(all_the_things) do
    raw_expected = Keyword.fetch!(all_the_things, :expected)
    raw_actual = Keyword.fetch!(all_the_things, :actual)
    raw_fields = Keyword.get(all_the_things, :fields)
    raw_skip_fields = Keyword.get(all_the_things, :skip_fields, [])
    opts = all_the_things[:opts] || []

    expected = convert_to_atom_keys(raw_expected)
    actual = convert_to_atom_keys(raw_actual)
    fields = maybe_convert_fields_to_atoms(raw_fields) -- maybe_convert_fields_to_atoms(raw_skip_fields)

    for field <- fields do
      with {{:ok, expected_value}, _} <- {Map.fetch(expected, field), :expected},
           {{:ok, actual_value}, _} <- {Map.fetch(actual, field), :actual} do
        expected_value = maybe_convert_datetime_to_string(expected_value, opts[:convert_dates])
        actual_value = maybe_convert_datetime_to_string(actual_value, opts[:convert_dates])

        assert(
          expected_value == actual_value,
          "Values did not match for field: #{inspect(field)}\nexpected: #{inspect(expected_value)}\nactual: #{inspect(actual_value)}"
        )
      else
        {:error, type} -> flunk("Key for field: #{inspect(field)} didn't exist in #{type}")
      end
    end

    :ok
  end

  defp convert_to_atom_keys({map, :atom_keys}), do: map

  defp convert_to_atom_keys({map, :string_keys}),
    do: for({key, value} <- map, into: %{}, do: {String.to_atom(key), value})

  defp convert_to_atom_keys(map) when is_map(map), do: map

  defp maybe_convert_fields_to_atoms(fields) do
    Enum.map(
      fields,
      fn
        field when is_binary(field) -> String.to_atom(field)
        field when is_atom(field) -> field
      end
    )
  end

  defp maybe_convert_datetime_to_string(%DateTime{} = datetime, true = _convert_dates) do
    DateTime.to_iso8601(datetime)
  end

  defp maybe_convert_datetime_to_string(%Date{} = date, true = _convert_dates) do
    Date.to_iso8601(date)
  end

  defp maybe_convert_datetime_to_string(datetime, _) do
    datetime
  end
end
