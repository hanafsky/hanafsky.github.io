# This file was generated, do not modify it. # hide
using HTTP
patentURL="https://patents.google.com/patent/US9839852"
r=HTTP.request("GET", patentURL)
@show r.status