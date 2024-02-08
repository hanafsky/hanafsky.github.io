# This file was generated, do not modify it. # hide
innerjoin(filter(:people_num=>==(1),reserve_df),
          filter(:is_business=>==(true),hotel_df),
          on=:hotel_id) |> first |> println