# This file was generated, do not modify it. # hide
using Cascadia
h = parsehtml(String(r.body)) # hide
s_claim = Selector(".claims .claim .claim")
q_claim = eachmatch(s_claim, h.root)
claim1 = q_claim[1] |> nodeText 
@show claim1