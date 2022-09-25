# This file was generated, do not modify it. # hide
@chain customer_df begin
    select(:sex, [:sex=>ByRow(isequal(v))=>Symbol("sex_is_"*v) for v in unique(customer_df.sex)])
    first(10)
    println
end