using Dates

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

"""
    {{blogposts}}
Plug in the list of blog posts contained in the `/blog/` folder.
"""
function hfun_blogposts(params)# paramsはblogなどのディレクトリ
    io = IOBuffer()
    write(io,"\n @@cards @@row \n")
    path=params[1]
    posts = filter!(p->endswith(p,".md"), readdir(path))
    days = Vector{Date}(undef, length(posts))
    lines = Vector{String}(undef,length(posts))
    for (i, post) ∈ enumerate(posts)
        ps = split(post)[1]
        url = "/$path/$ps"
        lurl = split(url,".")[1]
        surl = strip(url, '/')
        title = pagevar(surl, :title)
        title === nothing && (title = "Untitled")
        img = pagevar(surl,:titleimage)
        img === nothing && (img = "/assets/blank.jpg")
        description = pagevar(surl, :description)
        pubdate = pagevar(surl, :published)
        if isnothing(pubdate)
            date = Date(2021,04,01)
        else
            date = Date(pubdate, dateformat"d U Y")
        end
        days[i] = date
        lines[i] = """\n @@column @@card @@container
                         ~~~<p style="text-align:center"><img src="$img" alt="No image"></p> ~~~ 
                         @@title $title @@
                         @@vitae $(Dates.format(date,"d u Y")) @@ 
                         @@description $(description) @@ 
                       ~~~<p><button class="button" onclick="location.href='$lurl'">読む</button></p> ~~~ @@ @@ @@ \n
                   """ 
    end
    foreach(line -> write(io, line), lines[sortperm(days, rev=true)])
    write(io,"\n @@ @@\n")
    r = Franklin.fd2html(String(take!(io)), internal=true)
    return r
end

function hfun_inserttitle(params)
    path=joinpath(params...)
    title = pagevar(path,:title)
    description=pagevar(path,:description)
    img = pagevar(path,:titleimage)
    imgsrc = pagevar(path,:imagesrc)
    imgsrc === nothing && (imgsrc ="original")
    date = pagevar(path,:published)
    date === nothing && (date = "01 January 2025")
    date = Dates.format(Date(date,dateformat"d U Y"), "d u Y") 
    io = IOBuffer()
    write(io,"\n # $description - $title \n")
    write(io,"\n @@date $date @@\n")
    write(io,"\n @@titleimage ~~~<img src=$img alt=''>
              <div style='text-align:right; font-size:small; color:grey'>(src=$imgsrc)</div> 
              ~~~@@ \n")
    r = Franklin.fd2html(String(take!(io)), internal=true)
    return r
end