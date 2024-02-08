# This file was generated, do not modify it. # hide
using StatsBase: sample 
sample_row = sample(1:nrow(reserve_df), round(Int,nrow(reserve_df)/2), replace=false)
reserve_df[sample_row,:]