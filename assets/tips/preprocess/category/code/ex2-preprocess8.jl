# This file was generated, do not modify it. # hide
transform!(customer_df, :age=>ByRow(c->10floor(Int,c/10))=>:age_rank)
transform!(customer_df, :age_rank=>categorical=>:age_rank)
replace!(customer_df.age_rank,[70,80]=>60)
first(customer_df,20) |> println