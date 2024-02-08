# This file was generated, do not modify it. # hide
reserve_df2 = @chain reserve_df begin
      transform(:total_price=>zscore)
      filter(:total_price_zscore=>(c->abs(c)≤3),_)
end

first(reserve_df2,10) |> println