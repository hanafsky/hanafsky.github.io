# This file was generated, do not modify it. # hide
# 年月マスタの生成
month_mst = DataFrame(:year_month=>[Date("2017-01-01")+Month(m) for m in 0:2]) 
customer_mst = crossjoin(customer_df,month_mst)

summary_result = @chain reserve_df begin
  select(:customer_id,
         :checkin_date=>ByRow(r->Date(Year(r),Month(r)))=>:year_month,
         :total_price)
  # customer_mstに対して結合したいのでleftjoinではなくrightjoinを使う。
  rightjoin(customer_mst,on=[:customer_id,:year_month]) 
  groupby([:customer_id,:year_month])
  combine(:total_price=>sum=>:price_sum)
  sort(:year_month)
  sort(:customer_id,lt=natural)
end
replace!(summary_result.price_sum,missing=>0)

first(summary_result,10) |> println