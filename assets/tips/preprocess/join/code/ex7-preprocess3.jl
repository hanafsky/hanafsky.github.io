# This file was generated, do not modify it. # hide
using Dates
function total_price_history(reserve_dates,prices;day=Day(90))
  tp = similar(prices)
  for (index,date) in enumerate(reserve_dates)
    filtered_date = filter(((d)->date-day ≤ d < date), reserve_dates)
    tp[index] = filtered_date==DateTime[] ? 0 :
                sum(prices[i] for (i,d) in enumerate(reserve_dates) if d in filtered_date)
  end
  return tp
end

@chain reserve_df begin
  sort([:customer_id,:reserve_datetime])
  groupby(:customer_id)
  transform([:reserve_datetime,:total_price]=>total_price_history=>:total_price_90d)
  select(:customer_id,:reserve_datetime,:total_price,:total_price_90d) # 表示する列を選択
  sort(:customer_id,lt=natural)
  first(_,15) # 15件目のレコードまで選択
  println
end