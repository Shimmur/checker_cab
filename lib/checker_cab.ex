defmodule CheckerCab do
  @moduledoc """
  Documentation for CheckerCab.
  """
  import ExUnit.Assertions, only: [assert: 2, flunk: 1]

  @type inputs :: [
          expected: map(),
          actual: map(),
          fields: list(atom())
        ]

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
          "Values did not match for field: #{inspect(field)}\nexpected: #{inspect(expected_value)}\nactual: #{
            inspect(actual_value)
          }"
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
