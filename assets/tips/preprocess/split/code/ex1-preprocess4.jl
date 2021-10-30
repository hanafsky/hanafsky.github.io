# This file was generated, do not modify it. # hide
using DataFrames,CSV,Chain,Downloads,NaturalSort
production_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/production.csv"
monthly_index_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/monthly_index.csv"

production_df = @chain production_url Downloads.download CSV.File DataFrame
monthly_index_df = @chain monthly_index_url Downloads.download CSV.File DataFrame
first(production_df,10) |> println