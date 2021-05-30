# This file was generated, do not modify it. # hide
@chain reserve_df begin
  groupby(:hotel_id)
  combine(:reserve_id => length => :rsv_cnt)
  select(:,:rsv_cnt => competerank =>:rsv_cnt_rank)
  first(10)
  println
end