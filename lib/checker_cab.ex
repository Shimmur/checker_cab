defmodule CheckerCab do
  @moduledoc """
  Documentation for CheckerCab.

  This documentation assumes these functions are used in the context of unit
  tests.
  """
  import ExUnit.Assertions, only: [assert: 2]

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

    field_comparisons =
      Enum.map(fields, fn field ->
        expected_value = fetch_and_convert(expected, field, opts)
        actual_value = fetch_and_convert(actual, field, opts)

        %{
          field: field,
          expected: expected_value,
          actual: actual_value
        }
      end)

    {missing, populated} = Enum.split_with(field_comparisons, &missing_either_value?/1)
    mismatched = Enum.filter(populated, &mismatched?/1)

    assert(
      Enum.empty?(missing) && Enum.empty?(mismatched),
      error_message_for(missing, mismatched)
    )

    :ok
  end

  defp missing_either_value?(%{expected: expected, actual: actual}) do
    !match?({:ok, _}, expected) || !match?({:ok, _}, actual)
  end

  defp mismatched?(%{expected: expected, actual: actual}) do
    expected != actual
  end

  defp fetch_and_convert(map, field_name, opts) do
    with {:ok, value} <- Map.fetch(map, field_name) do
      {:ok, maybe_convert_datetime_to_string(value, opts[:convert_dates])}
    end
  end

  defp error_message_for(missing, mismatched) do
    [
      "There were issues with the comparison:",
      error_message_for_missing(missing),
      error_message_for_mismatched(mismatched)
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n\n")
  end

  defp error_message_for_missing([]) do
    ""
  end

  defp error_message_for_missing(missing) do
    missing
    |> Enum.sort_by(& &1.field)
    |> Enum.reduce(["Key(s) missing:"], fn
      %{actual: :error, expected: :error, field: field}, acc ->
        ["  field: #{inspect(field)} didn't exist in actual and expected" | acc]

      %{actual: :error, field: field}, acc ->
        ["  field: #{inspect(field)} didn't exist in actual" | acc]

      %{expected: :error, field: field}, acc ->
        ["  field: #{inspect(field)} didn't exist in expected" | acc]
    end)
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  defp error_message_for_mismatched([]) do
    ""
  end

  defp error_message_for_mismatched(mismatched) do
    mismatched
    |> Enum.sort_by(& &1.field)
    |> Enum.reduce(["Values did not match for:"], fn %{actual: {:ok, actual}, expected: {:ok, expected}, field: field},
                                                     acc ->
      message =
        Enum.join(
          ["  field: #{inspect(field)}", "    expected: #{inspect(expected)}", "    actual: #{inspect(actual)}"],
          "\n"
        )

      [message | acc]
    end)
    |> Enum.reverse()
    |> Enum.join("\n")
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
