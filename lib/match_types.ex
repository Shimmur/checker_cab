defprotocol CheckerCab.MatchTypes do
  @fallback_to_any true
  @spec values_match?(any(), any()) :: boolean()
  def values_match?(expected, actual)
end

defimpl CheckerCab.MatchTypes, for: Any do
  def values_match?(expected, actual) do
    expected == actual
  end
end
