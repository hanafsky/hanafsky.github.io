# This file was generated, do not modify it. # hide
using DataFrames,CSV,Chain,Downloads
using CategoricalArrays
customer_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/customer.csv"

customer_df = @chain customer_url begin 
                    Downloads.download 
                    CSV.File 
                    DataFrame
                    DataFrames.transform(:sex=>categorical=>:sex_c)
                    end
first(customer_df,10) |> println
