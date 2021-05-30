# This file was generated, do not modify it. # hide
using Chain
reserve_df.rand=rand(nrow(reserve_df))
sdf = @chain reserve_df begin
  filter(:rand =><(0.5),_)
  select!(Not(:rand))
end
println(first(sdf))