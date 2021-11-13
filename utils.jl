function hfun_bar(vname)
  val = Meta.parse(vname[1])
  return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
  var = vname[1]
  return pagevar("index", var)
end

function lx_baz(com, _)
  # keep this first line
  brace_content = Franklin.content(com.braces[1]) # input string
  # do whatever you want here
  return uppercase(brace_content)
end

html_audio(src) = """
~~~
<div style=\"text-align:center\">
<audio controls controlslist=\"nodownload\" src=\"$src\">
</audio>
</div>
~~~
"""

function lx_audio(lxc::Franklin.LxCom, _)
  rpath = Franklin.stent(lxc.braces[1])
  path  = Franklin.parse_rpath(rpath; canonical=false, code=true)
  fdir, fext = splitext(path)
  # there are several cases
  # A. a path with no extension --> guess extension
  # B. a path with extension --> use that
  # then in both cases there can be a relative path set but the user may mean
  # that it's in the subfolder /output/ (if generated by code) so should look
  # both in the relpath and if not found and if /output/ not already last dir
  candext = ifelse(isempty(fext),
                   (".wav", ".mp3"), (fext,))
  for ext ∈ candext
      candpath = fdir * ext
      syspath  = joinpath(Franklin.PATHS[:site], split(candpath, '/')...)
      isfile(syspath) && return html_audio(candpath)
  end
  # now try in the output dir just in case (provided we weren't already
  # looking there)
  p1, p2 = splitdir(fdir)
  if splitdir(p1)[2] != "output"
      for ext ∈ candext
          candpath = p1 * "/output/" *p2 * ext
          syspath  = joinpath(Franklin.PATHS[:site], split(candpath, '/')...)
          isfile(syspath) && return html_audio(candpath)
      end
  end
  return Franklin.html_err("Audio matching '$syspath' not found.")
end

luminous_img(src,alt="") = """<div style=\"text-align:center\">
                                  <a href=\"$src\" class=\"ZOOM\"><img src=\"$src\" alt=\"$alt\"></a>
                              </div>"""

function lx_figpop(lxc::Franklin.LxCom, _)
  rpath = Franklin.stent(lxc.braces[1])
  path  = Franklin.parse_rpath(rpath; canonical=false, code=true)
  fdir, fext = splitext(path)
  alt = ""
  # there are several cases
  # A. a path with no extension --> guess extension
  # B. a path with extension --> use that
  # then in both cases there can be a relative path set but the user may mean
  # that it's in the subfolder /output/ (if generated by code) so should look
  # both in the relpath and if not found and if /output/ not already last dir
  candext = ifelse(isempty(fext),
                   (".png", ".jpeg", ".jpg", ".svg", ".gif"), (fext,))
  for ext ∈ candext
      candpath = fdir * ext
      syspath  = joinpath(Franklin.PATHS[:site], split(candpath, '/')...)
      isfile(syspath) && return luminous_img(candpath, alt)
  end
  # now try in the output dir just in case (provided we weren't already
  # looking there)
  p1, p2 = splitdir(fdir)
  if splitdir(p1)[2] != "output"
      for ext ∈ candext
          candpath = p1 * "/output/" *p2 * ext
          syspath  = joinpath(Franklin.PATHS[:site], split(candpath, '/')...)
          isfile(syspath) && return "\\luminous{$candpath}"
      end
  end
  return Franklin.html_err("Image matching '$path' not found.")
end

"""
    {{ addcomments }}

Add a comment widget, managed by utterances <https://utteranc.es>.
"""
function hfun_addcomments()
    html_str = """
        <script src="https://utteranc.es/client.js"
            repo="hanafsky/blog_comments"
            issue-term="pathname"
            label="Comment"
            theme="github-light"
            crossorigin="anonymous"
            async>
        </script>
    """
    return html_str
end

function env_cap(com, _)
  option = Franklin.content(com.braces[1])
  content = Franklin.content(com)
  output = replace(content, option => uppercase(option))
  return "~~~<b>~~~$output~~~</b>~~~"
end