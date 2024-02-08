# This file was generated, do not modify it. # hide
@chain reserve_df.customer_id begin
  unique
  sample(_, round(Int,length(_)/2),replace=false)
  filter(:customer_id => in(_),reserve_df) 
end