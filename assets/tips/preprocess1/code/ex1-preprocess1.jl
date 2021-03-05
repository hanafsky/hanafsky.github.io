# This file was generated, do not modify it. # hide
using DataFrames,CSV
path = joinpath("tips","data","reserve.csv")
reserve_df = CSV.read(path,DataFrame)
println(first(reserve_df))