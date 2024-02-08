# This file was generated, do not modify it. # hide
df3_2 = @chain reserve_df begin
  groupby([:hotel_id,:people_num])
  combine(:total_price=> sum =>:price_sum)
end
first(df3_2) |> println