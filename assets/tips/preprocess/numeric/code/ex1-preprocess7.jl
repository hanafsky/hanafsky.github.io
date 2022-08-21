# This file was generated, do not modify it. # hide
using DataFrames,CSV,Chain,Downloads
reserve_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/reserve.csv"

reserve_df = @chain reserve_url begin 
                    Downloads.download 
                    CSV.File 
                    DataFrame
                    transform(:total_price=>ByRow(c->log10(c/1000 + 1))=>:total_price_log)
                    end

first(reserve_df,10) |> println