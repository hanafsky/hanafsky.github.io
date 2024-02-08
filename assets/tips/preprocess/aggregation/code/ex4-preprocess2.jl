# This file was generated, do not modify it. # hide
using Statistics
@chain reserve_df begin
  groupby(:hotel_id)
  combine(:total_price=>maximum=>:price_max,
          :total_price=>minimum=>:price_min,
          :total_price=>mean=>:price_mean, 
          :total_price=>median=>:price_medeian,
          :total_price=>(r->quantile(r,0.2))=>:price_20per) 
  first(10)
  println
end