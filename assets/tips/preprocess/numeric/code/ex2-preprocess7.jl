# This file was generated, do not modify it. # hide
using CategoricalArrays
customer_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/customer.csv"
customer_df = @chain customer_url Downloads.download CSV.File DataFrame
transform!(customer_df, :age=>ByRow(c->10floor(Int,c/10))=>:age_rank)
transform!(customer_df, :age_rank=>categorical=>:age_rank)

first(customer_df,10) |> println