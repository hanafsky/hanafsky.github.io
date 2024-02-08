# This file was generated, do not modify it. # hide
using Chain
@chain reserve_df begin
  filter(:checkin_date => >=(Date(2016,10,12)),_)
  filter(:checkin_date => <=(Date(2016,10,13)),_)
  # println
end