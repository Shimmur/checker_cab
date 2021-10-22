defmodule CookieCutterTest do
  use ExUnit.Case

  defmodule ModuleForStructTests do
    defstruct [:key1, :key2, :key3]
  end

  defmodule ModuleForEctoSchemaTests do
    use Ecto.Schema

    schema "bobby_tables" do
      field(:field1, :integer)
      field(:field2, :string)
      field(:field3, :boolean)
    end
  end

  describe "fields_for/1" do
    test "success: it returns a list of atoms if passed an atom-keyed map" do
      input = %{key1: "value1", key2: "value2", key3: "value3"}

      ### kickoff
      result = CookieCutter.fields_for(input)

      assert Enum.sort(result) == Enum.sort(Map.keys(input))
    end

    test "success: it returns a list of strings if passed a string-keyed map" do
      input = %{"key1" => :value1, "key2" => :value2, "key3" => :value3}

      ### kickoff
      result = CookieCutter.fields_for(input)

      assert Enum.sort(result) == Enum.sort(Map.keys(input))
    end

    test "success: it returns a stripped list of atoms if passed a struct" do
      input = %ModuleForStructTests{}

      ### kickoff
      result = CookieCutter.fields_for(input)

      expected_keys =
        input
        |> Map.keys()
        |> List.delete(:__struct__)
        |> Enum.sort()

      assert Enum.sort(result) == expected_keys
    end

    test "success: it returns a stripped list of atoms if passed an Ecto.Schema" do
      input = %ModuleForEctoSchemaTests{}

      ### kickoff
      result = CookieCutter.fields_for(input)

      expected_keys =
        input
        |> Map.keys()
        |> Enum.reject(fn key -> key in [:__meta__, :__struct__] end)
        |> Enum.sort()

      assert Enum.sort(result) == expected_keys
    end

    test "success: it returns a stripped list of atoms if passed an Ecto.Schema name" do
      input = ModuleForEctoSchemaTests

      ### kickoff
      result = CookieCutter.fields_for(input)

      expected_keys =
        input
        |> struct()
        |> Map.keys()
        |> Enum.reject(fn key -> key in [:__meta__, :__struct__] end)
        |> Enum.sort()

      assert Enum.sort(result) == expected_keys
    end
  end

  describe "assert_values_for/1" do
    test "success: it does not raise with identical, atom-keyed maps" do
      expected = actual = %{key1: "value1", key2: "value2", key3: "value3"}
      input = [expected: expected, actual: actual, fields: Map.keys(expected)]

      ## kickoff
      assert :ok == CookieCutter.assert_values_for(input)
    end

    test "success: it raises when a key in `:fields` is missing from the `:expected` input" do
      expected = %{key1: "value1"}
      actual = %{key1: "value1", key2: "value2"}

      input = [expected: expected, actual: actual, fields: Map.keys(actual)]

      expected_message = "Key for field: #{inspect(:key2)} didn't exist in #{:expected}"

      assert_raise(ExUnit.AssertionError, formatted_error_message(expected_message), fn ->
        CookieCutter.assert_values_for(input)
      end)
    end

    test "success: it raises when a key in `:fields` is missing from the `:actual` input" do
      expected = %{key1: "value1", key2: "value2"}
      actual = %{key1: "value1"}

      input = [expected: expected, actual: actual, fields: Map.keys(expected)]

      expected_message = "Key for field: #{inspect(:key2)} didn't exist in #{:actual}"

      assert_raise(ExUnit.AssertionError, formatted_error_message(expected_message), fn ->
        CookieCutter.assert_values_for(input)
      end)
    end

    test "success: it raises when two atom-keyed maps have the same keys, but different values" do
      expected = %{key1: "value1", key2: "value2"}
      actual = %{key1: "value1", key2: "unexpected_value"}

      input = [expected: expected, actual: actual, fields: Map.keys(expected)]

      expected_message =
        "Values did not match for field: #{inspect(:key2)}\nexpected: #{inspect(expected.key2)}\nactual: #{
          inspect(actual.key2)
        }"

      ## kickoff
      assert_raise(ExUnit.AssertionError, formatted_error_message(expected_message), fn ->
        CookieCutter.assert_values_for(input)
      end)
    end

    test "success: with atom keys explicitly specified" do
      expected = actual = %{key1: "value1", key2: "value2", key3: "value3"}
      input = [expected: {expected, :atom_keys}, actual: {actual, :atom_keys}, fields: Map.keys(expected)]

      ## kickoff
      # if things match, :ok. If they don't, it will raise.
      assert :ok == CookieCutter.assert_values_for(input)
    end

    test "success: with string keys explicitly specified" do
      expected = actual = %{"key1" => "value1", "key2" => "value2", "key3" => "value3"}
      input = [expected: {expected, :string_keys}, actual: {actual, :string_keys}, fields: [:key1, :key2, :key3]]

      ## kickoff
      # if things match, :ok. If they don't, it will raise.
      assert :ok == CookieCutter.assert_values_for(input)
    end

    test "success: with fields as strings" do
      expected = actual = %{"key1" => "value1", "key2" => "value2", "key3" => "value3"}
      input = [expected: {expected, :string_keys}, actual: {actual, :string_keys}, fields: Map.keys(expected)]

      ## kickoff
      # if things match, :ok. If they don't, it will raise.
      assert :ok == CookieCutter.assert_values_for(input)
    end

    test "success: with skip_fields key passed in" do
      expected = %{key1: "value1", key2: "value2"}
      actual = %{key1: "value1", key2: "unexpected_value"}

      input = [expected: expected, actual: actual, fields: Map.keys(expected), skip_fields: [:key2]]

      assert :ok == CookieCutter.assert_values_for(input)
    end

    test "success: with string skip_fields key passed in" do
      expected = %{key1: "value1", key2: "value2"}
      actual = %{key1: "value1", key2: "unexpected_value"}

      input = [expected: expected, actual: actual, fields: Map.keys(expected), skip_fields: ["key2"]]

      assert :ok == CookieCutter.assert_values_for(input)
    end
  end

  defp formatted_error_message(message) do
    error = %ExUnit.AssertionError{message: message}

    ExUnit.AssertionError.message(error)
  end
end
