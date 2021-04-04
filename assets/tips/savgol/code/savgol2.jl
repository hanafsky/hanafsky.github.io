# This file was generated, do not modify it. # hide
deriv1_1 = apply_filter(sg1[:,2],y)/0.1
println(deriv1_1)
p_2 = plot(sigmoid_d,label="theoretical 1st order derivative",legend=:topleft)
scatter!(p_2,x,deriv1_1,label="smoothed 1st order derivative")
savefig(p_2,joinpath(@OUTPUT,"savgol2.svg")) # hide