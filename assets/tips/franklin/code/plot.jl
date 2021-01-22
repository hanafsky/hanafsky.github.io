# This file was generated, do not modify it. # hide
using Plots
p = plot(x->sin(x),xlabel="x",ylabel="y")
savefig(p,joinpath(@OUTPUT,"figplot.svg"))