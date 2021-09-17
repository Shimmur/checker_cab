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
end
