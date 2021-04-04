# This file was generated, do not modify it. # hide
using SavGol
sg1 = SavGol.SG(5,2)
p0=scatter(sg1[:,1],label="window for smoothing")
scatter!(sg1[:,2], label="window for 1st order derivative")
scatter!(sg1[:,3], label="window for 2nd order derivative")
savefig(p0,joinpath(@OUTPUT,"savgol.svg")) # hide