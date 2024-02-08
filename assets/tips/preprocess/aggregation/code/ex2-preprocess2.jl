# This file was generated, do not modify it. # hide
using Chain
df3_1= @chain reserve_df begin
  groupby(:hotel_id)
  combine(:reserve_id  => length        => :rsv_cnt,
          :customer_id => length∘unique => :cus_cnt)
end
first(df3_1) |> println