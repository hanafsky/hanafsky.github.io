# This file was generated, do not modify it. # hide
p2 = @chain new_df begin
        filter(:fault_flg=>==(false),_)
        @df scatter(:length, :thickness, label="false")
    end
                                                              
@chain new_df begin
      filter(:fault_flg=>==(true),_)
      @df scatter!(:length, :thickness, label="true")
    end
savefig(p2, joinpath(@OUTPUT,"5-2.svg")) # hide
