defimpl CheckerCab.MatchTypes, for: Decimal do
  def values_match?(expected, actual) do
    Decimal.equal?(expected, actual)
  end
end
