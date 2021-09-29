# This file was generated, do not modify it. # hide
using DataFrames,CSV,Chain,Downloads
reserve_url = "https://raw.githubusercontent.com/ghmagazine/awesomebook/master/data/reserve.csv"
reserve_df = @chain reserve_url begin
  Downloads.download(IOBuffer())
  String(take!(_))
  CSV.read(IOBuffer(_),DataFrame)
end
println(first(reserve_df));