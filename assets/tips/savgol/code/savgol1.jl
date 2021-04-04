# This file was generated, do not modify it. # hide
using Plots, Random
Random.seed!(123)
sigmoid(x) = 1/(1+exp(-x+1))
sigmoid_d(x) = exp(-x+1)/(1+exp(-x+1))^2
p_1=plot(sigmoid,xlabel="x",ylabel="y",label="sigmoid curve",legend=:topleft)
x = -4:0.1:4
y = sigmoid.(x) + 0.01randn(length(x))
scatter!(p_1,x,y,label="observed") 
savefig(p_1,joinpath(@OUTPUT,"savgol1.svg")) # hide