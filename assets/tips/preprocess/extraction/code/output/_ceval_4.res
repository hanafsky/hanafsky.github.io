:(let
      var"##292" = Downloads.download(reserve_url, IOBuffer())
      var"##293" = String(take!(var"##292"))
      var"##294" = CSV.read(IOBuffer(var"##293"), DataFrame)
  end)