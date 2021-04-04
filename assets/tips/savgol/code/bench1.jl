# This file was generated, do not modify it. # hide
using BenchmarkTools
sg3 = SG_Filter(Float64,halfWidth=5,degree=2)
@btime apply_SG_filter(y,sg3,derivativeOrder=0) # 直接畳み込み
@btime apply_filter(sg1[:,2],y) # FFT畳み込み