# This file was generated, do not modify it. # hide
using DataFrames,CSV,Chain,Downloads
production_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/production.csv"

production_df = @chain production_url Downloads.download CSV.File DataFrame
first(production_df,10) |> println