# This file was generated, do not modify it. # hide
using DataFrames,CSV,Chain,Downloads
reserve_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/reserve.csv"

reserve_df = @chain reserve_url Downloads.download CSV.File DataFrame
first(reserve_df,10) |> println