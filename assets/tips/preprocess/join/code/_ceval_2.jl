# This file was generated, do not modify it. # hide
function roll_sum(v,window=3)
  length(v) < window ? Vector{Missing}(undef,length(v)) : 
                       vcat(Vector{Missing}(undef,window-1),rolling(sum,v,window))
end
roll_sum([1,2,3,4,5],3)
