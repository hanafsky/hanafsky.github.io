# This file was generated, do not modify it. # hide
# hideall
using Plots,Plots.PlotMeasures
Plots.reset_defaults()
default(
    left_margin = 30px,
    bottom_margin = 30px
)
xlabel=["2017","2018#1","2018#2","2019#1","2019#2","2019#3","2020#1","2020#2","2020#3","2021#1","2021#2"]
juken=[1448,1988,2680,3436,5143,6580,6298,12552,7250,6062,7450]
gokaku=[823,1136,1740,2500,3672,4652,4198,8656,4318,3866,4582]
p=plot(juken,label="examinees",xrotation=10)
plot!(p,gokaku,label="passers")
xticks!([1:11;],xlabel)
savefig(p,joinpath(@OUTPUT,"hist.svg"))
