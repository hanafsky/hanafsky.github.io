# This file was generated, do not modify it. # hide
using DataFrames,CSV,Chain,Downloads

reserve_url = "https://raw.githubusercontent.com/ghmagazine/awesomebook/master/data/reserve.csv"

reserve_df = @chain reserve_url Downloads.download CSV.File DataFrame
println(first(reserve_df))