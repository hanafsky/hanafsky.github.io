quote
    local var"##537" = reserve_url
    local var"##538" = Downloads.download(var"##537", IOBuffer())
    local var"##539" = String(take!(var"##538"))
    local var"##540" = CSV.read(IOBuffer(var"##539"), DataFrame)
    var"##540"
end