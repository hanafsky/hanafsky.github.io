# This file was generated, do not modify it. # hide
using StatsBase
transform!(reserve_df,:people_num=>zscore, :total_price=>zscore)
first(reserve_df,10) |> println