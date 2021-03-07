# This file was generated, do not modify it. # hide
using DataFrames,CSV
path_rsv = joinpath("tips","data","reserve.csv")
path_hotel = joinpath("tips","data","hotel.csv")
reserve_df = CSV.read(path_rsv,DataFrame)
hotel_df = CSV.read(path_hotel,DataFrame)
#first(hotel_df) |> println