:(let
      var"##396" = reserve_url
      var"##397" = Downloads.download(var"##396", IOBuffer())
      var"##398" = String(take!(var"##397"))
      var"##399" = CSV.read(IOBuffer(var"##398"), DataFrame)
      var"##399"
  end)