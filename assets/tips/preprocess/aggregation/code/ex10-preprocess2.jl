# This file was generated, do not modify it. # hide
using StatsBase
@chain reserve_df begin
  groupby(:hotel_id)
  select(:,:reserve_datetime => ordinalrank =>:log_no)
  first(10)
  println
end