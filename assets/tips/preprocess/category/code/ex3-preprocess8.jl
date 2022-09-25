# This file was generated, do not modify it. # hide
@chain customer_df begin
    select(:age,:sex, [:age,:sex]=>ByRow((x,y)->string(floor(Int,x/10)*10, "_", y))=>:sex_and_age)
    DataFrames.transform(:sex_and_age=>categorical=>:sex_and_age)
    first(10)
    println
end