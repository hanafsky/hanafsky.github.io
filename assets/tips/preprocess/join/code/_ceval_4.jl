# This file was generated, do not modify it. # hide
function price_avg(v,window=3)
  length(v) < window ? vcat(missing,runmean(v,length(v))[begin:end-1]) :
                       vcat(missing,runmean(v,window)[begin:end-1])
end
price_avg([1,2,3,4,5],3)
