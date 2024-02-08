# This file was generated, do not modify it. # hide
@chain production_missing_df begin
    transform(:thickness=>ByRow(c->coalesce(c,1))=>:thickness)
    first(30) 
    println
end