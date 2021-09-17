defmodule CookieCutter do
  @moduledoc """
  Documentation for CookieCutter.
  """
  def fields_for(map) when is_map(map) do
    map
    |> Map.keys()
    |> Enum.reject(fn key -> key in [:__meta__, :__struct__] end)
  end
end
