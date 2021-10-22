# This file was generated, do not modify it. # hide
using Chain, ShiftedArrays

@chain reserve_df begin
  sort(:reserve_datetime)
  sort(:customer_id,lt=natural)
  groupby(:customer_id)
  transform(:total_price=>roll_sum=>:price_sum)
  select(:customer_id,:reserve_datetime,:total_price,:price_sum) # 表示する列を選択
  first(_,15) # 15件目のレコードまで選択
  println
end