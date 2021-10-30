:(let
      var"##372" = Downloads.download(reserve_url, IOBuffer())
      var"##373" = String(take!(var"##372"))
      var"##374" = CSV.read(IOBuffer(var"##373"), DataFrame)
      var"##374"
  end)