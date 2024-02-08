# This file was generated, do not modify it. # hide
@macroexpand(@chain reserve_url begin
  Downloads.download(IOBuffer())
  String(take!(_))
  CSV.read(IOBuffer(_),DataFrame)
end) |>Base.remove_linenums!
