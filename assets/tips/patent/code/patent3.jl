# This file was generated, do not modify it. # hide
using Cascadia
s = Selector("title")
q = eachmatch(s, h.root)
q[1] |> nodeText |> println