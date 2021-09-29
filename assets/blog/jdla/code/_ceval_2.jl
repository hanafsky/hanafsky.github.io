# This file was generated, do not modify it. # hide
# hideall
xlabel=["2018","2019#1","2019#2","2020#1","2021#1","2021#2"]
juken_e=[337,387,696,1042,1688,1170]
gokaku_e=[234,245,472,709,1324,872]
p=plot(juken_e,label="examinees",xrotation=10)
plot!(p,gokaku_e,label="passers")
xticks!([1:6;],xlabel)
savefig(p,joinpath(@OUTPUT,"hist2.svg"))
