defmodule CookieCutter do
  @moduledoc """
  Documentation for CookieCutter.
  """
  import ExUnit.Assertions, only: [assert: 2, flunk: 1]

  @type inputs :: [
          expected: map(),
          actual: map(),
          fields: list(atom())
        ]

  def fields_for(map) when is_map(map) do
    map
    |> Map.keys()
    |> Enum.reject(fn key -> key in [:__meta__, :__struct__] end)
  end

  def fields_for(schema_name) when is_atom(schema_name) do
    schema_name.__schema__(:fields)
  end

  @spec assert_values_for(inputs()) :: :ok | no_return()
  def assert_values_for(all_the_things) do
    expected = Keyword.fetch!(all_the_things, :expected)
    actual = Keyword.fetch!(all_the_things, :actual)
    fields = Keyword.get(all_the_things, :fields)

    for field <- fields do
      with {{:ok, expected}, _} <- {Map.fetch(expected, field), :expected},
           {{:ok, actual}, _} <- {Map.fetch(actual, field), :actual} do
        assert(
          expected == actual,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
        )
      else
        {:error, type} -> flunk("Key for field: #{field} didn't exist in #{type}")
      end
    end

    :ok
  end
end
