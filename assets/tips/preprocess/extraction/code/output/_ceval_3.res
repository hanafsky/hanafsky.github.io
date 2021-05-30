:(let
      var"##290" = Downloads.download(reserve_url, IOBuffer())
      var"##291" = String(take!(var"##290"))
      var"##292" = CSV.read(IOBuffer(var"##291"), DataFrame)
  end)