# This file was generated, do not modify it. # hide
using DirectConvolution
sg2 = SG_Filter(Float64,halfWidth=10,degree=2)
deriv1_2 = apply_SG_filter(y,sg2,derivativeOrder=1)/0.1
p_3 = plot(sigmoid_d,label="theoretical 1st order derivative",legend=:topleft)
scatter!(p_3,x,deriv1_2,label="smoothed 1st order derivative") 
savefig(p_3,joinpath(@OUTPUT,"savgol3.svg")) # hide