# This file was generated, do not modify it. # hide
using StatsPlots
p = @chain production_df begin
        filter(:fault_flg=>==(false),_)
        @df scatter(:length, :thickness, label="false")
    end
                                                              
@chain production_df begin
      filter(:fault_flg=>==(true),_)
      @df scatter!(:length, :thickness, label="true")
    end
savefig(p, joinpath(@OUTPUT,"5-1.svg")) # hide
