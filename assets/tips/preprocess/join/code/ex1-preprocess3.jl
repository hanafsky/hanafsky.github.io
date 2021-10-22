# This file was generated, do not modify it. # hide
using DataFrames,CSV,Chain,Downloads,NaturalSort
reserve_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/reserve.csv"
hotel_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/hotel.csv"
customer_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/customer.csv"

reserve_df = @chain reserve_url Downloads.download CSV.File DataFrame
hotel_df = @chain hotel_url Downloads.download CSV.File DataFrame
customer_df = @chain customer_url Downloads.download CSV.File DataFrame
using Dates
reserve_df.reserve_datetime = DateTime.(reserve_df.reserve_datetime, dateformat"yyyy-mm-dd HH:MM:SS")
first(hotel_df) |> println