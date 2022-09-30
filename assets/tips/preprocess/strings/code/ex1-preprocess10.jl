# This file was generated, do not modify it. # hide
using  Chain, Downloads
meros_url =  "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/txt/meros.txt"

meros = @chain meros_url begin
                Downloads.download
                read
                String
            end
first(meros, 10) |> println