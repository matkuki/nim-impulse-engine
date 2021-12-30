# Generated @ 2021-12-29T14:05:38+01:00
# Command line:
#   C:\Users\matic\.nimble\pkgs\nimterop-0.6.13\nimterop\toast.exe --preprocess -m:c --recurse --pnim --dynlib=drawtextLPath --symOverride=drawtext --nim:C:\Nim\bin\nim.exe --pluginSourcePath=C:\Users\matic\nimcache\nimterop\cPlugins\nimterop_4013203698.nim C:\msys64\home\matic\libdrawtext\build\libdrawtext\src\drawtext.h -o C:\msys64\home\matic\libdrawtext\libdrawtext.nim

{.push hint[ConvFromXtoItselfNotNeeded]: off.}
import macros

macro defineEnum(typ: untyped): untyped =
  result = newNimNode(nnkStmtList)

  # Enum mapped to distinct cint
  result.add quote do:
    type `typ`* = distinct cint

  for i in ["+", "-", "*", "div", "mod", "shl", "shr", "or", "and", "xor", "<", "<=", "==", ">", ">="]:
    let
      ni = newIdentNode(i)
      typout = if i[0] in "<=>": newIdentNode("bool") else: typ # comparisons return bool
    if i[0] == '>': # cannot borrow `>` and `>=` from templates
      let
        nopp = if i.len == 2: newIdentNode("<=") else: newIdentNode("<")
      result.add quote do:
        proc `ni`*(x: `typ`, y: cint): `typout` = `nopp`(y, x)
        proc `ni`*(x: cint, y: `typ`): `typout` = `nopp`(y, x)
        proc `ni`*(x, y: `typ`): `typout` = `nopp`(y, x)
    else:
      result.add quote do:
        proc `ni`*(x: `typ`, y: cint): `typout` {.borrow.}
        proc `ni`*(x: cint, y: `typ`): `typout` {.borrow.}
        proc `ni`*(x, y: `typ`): `typout` {.borrow.}
    result.add quote do:
      proc `ni`*(x: `typ`, y: int): `typout` = `ni`(x, y.cint)
      proc `ni`*(x: int, y: `typ`): `typout` = `ni`(x.cint, y)

  let
    divop = newIdentNode("/")   # `/`()
    dlrop = newIdentNode("$")   # `$`()
    notop = newIdentNode("not") # `not`()
  result.add quote do:
    proc `divop`*(x, y: `typ`): `typ` = `typ`((x.float / y.float).cint)
    proc `divop`*(x: `typ`, y: cint): `typ` = `divop`(x, `typ`(y))
    proc `divop`*(x: cint, y: `typ`): `typ` = `divop`(`typ`(x), y)
    proc `divop`*(x: `typ`, y: int): `typ` = `divop`(x, y.cint)
    proc `divop`*(x: int, y: `typ`): `typ` = `divop`(x.cint, y)

    proc `dlrop`*(x: `typ`): string {.borrow.}
    proc `notop`*(x: `typ`): `typ` {.borrow.}

when defined(cpp):
  # http://www.cplusplus.com/reference/cwchar/wchar_t/
  # In C++, wchar_t is a distinct fundamental type (and thus it is
  # not defined in <cwchar> nor any other header).
  type wchar_t* {.importc.} = object
else:
  type wchar_t* {.importc, header:"stddef.h".} = object


{.pragma: impdrawtextHdr,
  header: "C:/msys64/home/matic/libdrawtext/build/libdrawtext/src/drawtext.h".}
#{.pragma: impdrawtextDyn, dynlib: drawtextLPath.}
{.pragma: impdrawtextDyn, dynlib: "libdrawtext.dll".}
{.experimental: "codeReordering".}
defineEnum(Enum_drawtexth1)  ## ```
                             ##   draw buffering modes
                             ## ```
defineEnum(Enum_drawtexth2)  ## ```
                             ##   glyphmap resize filtering
                             ## ```
defineEnum(dtx_option)       ## ```
                             ##   ---- options and flags ----
                             ## ```
const
  DTX_NBF* = (0).cint        ## ```
                             ##   unbuffered
                             ## ```
  DTX_LBF* = (DTX_NBF + 1).cint ## ```
                                ##   line buffered
                                ## ```
  DTX_FBF* = (DTX_LBF + 1).cint ## ```
                                ##   fully buffered
                                ## ```
  DTX_NEAREST* = (0).cint
  DTX_LINEAR* = (DTX_NEAREST + 1).cint
  DTX_GL_ATTR_VERTEX* = (0).dtx_option ## ```
                                       ##   vertex attribute location     (default: -1 for standard gl_Vertex)
                                       ## ```
  DTX_GL_ATTR_TEXCOORD* = (DTX_GL_ATTR_VERTEX + 1).dtx_option ## ```
                                                              ##   texture uv attribute location (default: -1 for gl_MultiTexCoord0)
                                                              ## ```
  DTX_GL_ATTR_COLOR* = (DTX_GL_ATTR_TEXCOORD + 1).dtx_option ## ```
                                                             ##   color attribute location      (default: -1 for gl_Color) 
                                                             ##      options for the raster renderer
                                                             ## ```
  DTX_RASTER_THRESHOLD* = (DTX_GL_ATTR_COLOR + 1).dtx_option ## ```
                                                             ##   opaque/transparent threshold  (default: -1. fully opaque glyphs)
                                                             ## ```
  DTX_RASTER_BLEND* = (DTX_RASTER_THRESHOLD + 1).dtx_option ## ```
                                                            ##   glyph alpha blending (0 or 1) (default: 0 (off)) 
                                                            ##      generic options
                                                            ## ```
  DTX_PADDING* = (128).dtx_option ## ```
                                  ##   padding between glyphs in pixels (default: 8)
                                  ## ```
  DTX_SAVE_PPM* = (DTX_PADDING + 1).dtx_option ## ```
                                               ##   let dtx_save_glyphmap* save PPM instead of PGM (0 or 1) (default: 0 (PGM))
                                               ## ```
  DTX_FORCE_32BIT_ENUM* = (0x7FFFFFFF).dtx_option ## ```
                                                  ##   this is not a valid option
                                                  ## ```
type
  drawtext = object
  dtx_font* {.incompleteStruct, impdrawtextHdr, importc: "struct dtx_font".} = object
  dtx_glyphmap* {.incompleteStruct, impdrawtextHdr,
                  importc: "struct dtx_glyphmap".} = object
  dtx_box* {.bycopy, impdrawtextHdr, importc: "struct dtx_box".} = object
    x*: cfloat
    y*: cfloat
    width*: cfloat
    height*: cfloat

  dtx_vertex* {.bycopy, impdrawtextHdr, importc: "struct dtx_vertex".} = object
    x*: cfloat
    y*: cfloat
    s*: cfloat
    t*: cfloat

  dtx_pixmap* {.bycopy, impdrawtextHdr, importc: "struct dtx_pixmap".} = object
    pixels*: ptr cuchar      ## ```
                             ##   pixel buffer pointer (8 bits per pixel)
                             ## ```
    width*: cint             ## ```
                             ##   dimensions of the pixel buffer
                             ## ```
    height*: cint            ## ```
                             ##   dimensions of the pixel buffer
                             ## ```
    udata*: pointer ## ```
                    ##   user-supplied pointer to data associated with this
                    ##   					 pixmap. On the first callback invocation this pointer
                    ##   					 will be null. The user may set it to associate any extra
                    ##   					 data to this pixmap (such as texture structures or
                    ##   					 identifiers). Libdrawtext will never modify this pointer.
                    ## ```
  
  dtx_user_draw_func* {.importc, impdrawtextHdr.} = proc (v: ptr dtx_vertex;
      vcount: cint; pixmap: ptr dtx_pixmap; cls: pointer) {.cdecl.}
proc dtx_open_font*(fname: cstring; sz: cint): ptr dtx_font {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   Open a truetype/opentype/whatever font.
                    ##   
                    ##    If sz is non-zero, the default ASCII glyphmap at the requested point size is
                    ##    automatically created as well, and ready to use.
                    ##   
                    ##    To use other unicode ranges and different font sizes you must first call
                    ##    dtx_prepare or dtx_prepare_range before issuing any drawing calls, otherwise
                    ##    nothing will be rendered.
                    ## ```
proc dtx_open_font_mem*(`ptr`: pointer; memsz: cint; fontsz: cint): ptr dtx_font {.
    importc, cdecl, impdrawtextDyn.}
  ## ```
                                    ##   same as dtx_open_font, but open from a memory buffer instead of a file
                                    ## ```
proc dtx_open_font_glyphmap*(fname: cstring): ptr dtx_font {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   open a font by loading a precompiled glyphmap (see: dtx_save_glyphmap)
                    ##    this works even when compiled without freetype support
                    ## ```
proc dtx_open_font_glyphmap_mem*(`ptr`: pointer; memsz: cint): ptr dtx_font {.
    importc, cdecl, impdrawtextDyn.}
  ## ```
                                    ##   same as dtx_open_font_glyphmap, but open from a memory buffer instead of a file
                                    ## ```
proc dtx_close_font*(fnt: ptr dtx_font) {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                          ##   close a font opened by either of the above
                                                                          ## ```
proc dtx_prepare*(fnt: ptr dtx_font; sz: cint) {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                                 ##   prepare an ASCII glyphmap for the specified font size
                                                                                 ## ```
proc dtx_prepare_range*(fnt: ptr dtx_font; sz: cint; cstart: cint; cend: cint) {.
    importc, cdecl, impdrawtextDyn.}
  ## ```
                                    ##   prepare an arbitrary unicode range glyphmap for the specified font size
                                    ## ```
proc dtx_calc_font_distfield*(fnt: ptr dtx_font; scale_numer: cint;
                              scale_denom: cint): cint {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   convert all glyphmaps to distance fields for use with the distance field
                    ##    font rendering algorithm. This is a convenience function which calls
                    ##    dtx_calc_glyphmap_distfield and
                    ##    dtx_resize_glyphmap(..., scale_numer, scale_denom, DTX_LINEAR) for each
                    ##    glyphmap in this font.
                    ## ```
proc dtx_get_font_glyphmap*(fnt: ptr dtx_font; sz: cint; code: cint): ptr dtx_glyphmap {.
    importc, cdecl, impdrawtextDyn.}
  ## ```
                                    ##   Finds the glyphmap that contains the specified character code and matches the requested size
                                    ##    Returns null if it hasn't been created (you should call dtx_prepare/dtx_prepare_range).
                                    ## ```
proc dtx_get_font_glyphmap_range*(fnt: ptr dtx_font; sz: cint; cstart: cint;
                                  cend: cint): ptr dtx_glyphmap {.importc,
    cdecl, impdrawtextDyn.}
  ## ```
                           ##   Finds the glyphmap that contains the specified unicode range and matches the requested font size
                           ##    Will automatically generate one if it can't find it.
                           ## ```
proc dtx_get_num_glyphmaps*(fnt: ptr dtx_font): cint {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   returns the number of glyphmaps in this font
                    ## ```
proc dtx_get_glyphmap*(fnt: ptr dtx_font; idx: cint): ptr dtx_glyphmap {.
    importc, cdecl, impdrawtextDyn.}
  ## ```
                                    ##   returns the Nth glyphmap of this font
                                    ## ```
proc dtx_create_glyphmap_range*(fnt: ptr dtx_font; sz: cint; cstart: cint;
                                cend: cint): ptr dtx_glyphmap {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   Creates and returns a glyphmap for a particular unicode range and font size.
                    ##    The generated glyphmap is added to the font's list of glyphmaps.
                    ## ```
proc dtx_free_glyphmap*(gmap: ptr dtx_glyphmap) {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                                  ##   free a glyphmap
                                                                                  ## ```
proc dtx_calc_glyphmap_distfield*(gmap: ptr dtx_glyphmap): cint {.importc,
    cdecl, impdrawtextDyn.}
  ## ```
                           ##   converts a glyphmap to a distance field glyphmap, for use with the distance
                           ##    field font rendering algorithm.
                           ##   
                           ##    It is recommended to use a fairly large font size glyphmap for this, and
                           ##    then shrink the resulting distance field glyphmap as needed, with
                           ##    dtx_resize_glyphmap
                           ## ```
proc dtx_resize_glyphmap*(gmap: ptr dtx_glyphmap; snum: cint; sdenom: cint;
                          filter: cint): cint {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                                ##   resize a glyphmap by the provided scale factor fraction snum/sdenom
                                                                                ##    in order to maintain the power of 2 invariant, scaling fractions are only
                                                                                ##    allowed to be of the form 1/x or x/1, where x is a power of 2
                                                                                ## ```
proc dtx_get_glyphmap_image*(gmap: ptr dtx_glyphmap): ptr cuchar {.importc,
    cdecl, impdrawtextDyn.}
  ## ```
                           ##   returns a pointer to the raster image of a glyphmap (1 byte per pixel grayscale)
                           ## ```
proc dtx_get_glyphmap_width*(gmap: ptr dtx_glyphmap): cint {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   returns the width of the glyphmap image in pixels
                    ## ```
proc dtx_get_glyphmap_height*(gmap: ptr dtx_glyphmap): cint {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   returns the height of the glyphmap image in pixels
                    ## ```
proc dtx_get_glyphmap_ptsize*(gmap: ptr dtx_glyphmap): cint {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   returns the point size represented by this glyphmap
                    ## ```
proc dtx_load_glyphmap*(fname: cstring): ptr dtx_glyphmap {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   The following functions can be used even when the library is compiled without
                    ##    freetype support.
                    ## ```
proc dtx_load_glyphmap_stream*(fp: File): ptr dtx_glyphmap {.importc, cdecl,
    impdrawtextDyn.}
proc dtx_load_glyphmap_mem*(`ptr`: pointer; memsz: cint): ptr dtx_glyphmap {.
    importc, cdecl, impdrawtextDyn.}
proc dtx_save_glyphmap*(fname: cstring; gmap: ptr dtx_glyphmap): cint {.importc,
    cdecl, impdrawtextDyn.}
proc dtx_save_glyphmap_stream*(fp: File; gmap: ptr dtx_glyphmap): cint {.
    importc, cdecl, impdrawtextDyn.}
proc dtx_add_glyphmap*(fnt: ptr dtx_font; gmap: ptr dtx_glyphmap) {.importc,
    cdecl, impdrawtextDyn.}
  ## ```
                           ##   adds a glyphmap to a font
                           ## ```
proc dtx_set*(opt: dtx_option; val: cint) {.importc, cdecl, impdrawtextDyn.}
proc dtx_get*(opt: dtx_option): cint {.importc, cdecl, impdrawtextDyn.}
proc dtx_target_opengl*() {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                            ##   ---- rendering ---- 
                                                            ##      the dtx_target_ functions select which rendering mode to use.
                                                            ##    default: opengl
                                                            ## ```
proc dtx_target_raster*(pixels: ptr cuchar; width: cint; height: cint) {.
    importc, cdecl, impdrawtextDyn.}
  ## ```
                                    ##   pixels are expected to be RGBA ordered bytes, 4 per pixel
                                    ##    text is rendered with pre-multiplied alpha
                                    ## ```
proc dtx_target_user*(drawfunc: dtx_user_draw_func; cls: pointer) {.importc,
    cdecl, impdrawtextDyn.}
  ## ```
                           ##   set user-supplied draw callback and optional closure pointer, which will
                           ##    be passed unchanged as the last argument on every invocation of the draw
                           ##    callback.
                           ## ```
proc dtx_position*(x: cfloat; y: cfloat) {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                           ##   position of the origin of the first character to be printed
                                                                           ## ```
proc dtx_color*(r: cfloat; g: cfloat; b: cfloat; a: cfloat) {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   TODO currently only used by the raster renderer, implement in gl too
                    ## ```
proc dtx_use_font*(fnt: ptr dtx_font; sz: cint) {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                                  ##   before drawing anything this function must set the font to use
                                                                                  ## ```
proc dtx_draw_buffering*(mode: cint) {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                       ##   sets the buffering mode
                                                                       ##    - DTX_NBUF: every call to dtx_string gets rendered immediately.
                                                                       ##    - DTX_LBUF: renders when the buffer is full or the string contains a newline.
                                                                       ##    - DTX_FBUF: renders only when the buffer is full (you must call dtx_flush explicitly).
                                                                       ## ```
proc dtx_vertex_attribs*(vert_attr: cint; tex_attr: cint) {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   Sets the vertex attribute indices to use for passing vertex and texture coordinate
                    ##    data. By default both are -1 which means you don't have to use a shader, and if you
                    ##    do they are accessible through gl_Vertex and gl_MultiTexCoord0, as usual.
                    ##   
                    ##    NOTE: If you are using OpenGL ES 2.x or OpenGL >= 3.1 core (non-compatibility)
                    ##    context you must specify valid attribute indices.
                    ##   
                    ##    NOTE2: equivalent to:
                    ##       dtx_set(DTX_GL_ATTR_VERTEX, vert_attr);
                    ##       dtx_set(DTX_GL_ATTR_TEXCOORD, tex_attr);
                    ## ```
proc dtx_glyph*(code: cint) {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                              ##   draws a single glyph at the origin
                                                              ## ```
proc dtx_string*(str: cstring) {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                 ##   draws a utf-8 string starting at the origin. \n \r and \t are handled appropriately.
                                                                 ## ```
proc dtx_substring*(str: cstring; start: cint; `end`: cint) {.importc, cdecl,
    impdrawtextDyn.}
proc dtx_printf*(fmt: cstring) {.importc, cdecl, impdrawtextDyn, varargs.}
proc dtx_flush*() {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                    ##   render any pending glyphs (see dtx_draw_buffering)
                                                    ## ```
proc dtx_utf8_next_char*(str: cstring): cstring {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                                  ##   ---- encodings ---- 
                                                                                  ##      returns a pointer to the next character in a utf-8 stream
                                                                                  ## ```
proc dtx_utf8_prev_char*(`ptr`: cstring; first: cstring): cstring {.importc,
    cdecl, impdrawtextDyn.}
  ## ```
                           ##   returns a pointer to the previous character in a utf-8 stream
                           ## ```
proc dtx_utf8_char_code*(str: cstring): cint {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                               ##   returns the unicode character codepoint of the utf-8 character starting at str
                                                                               ## ```
proc dtx_utf8_nbytes*(str: cstring): cint {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                            ##   returns the number of bytes of the utf-8 character starting at str
                                                                            ## ```
proc dtx_utf8_char_count*(str: cstring): cint {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                                ##   returns the number of utf-8 characters in a zero-terminated utf-8 string
                                                                                ## ```
proc dtx_utf8_char_count_range*(str: cstring; nbytes: cint): cint {.importc,
    cdecl, impdrawtextDyn.}
  ## ```
                           ##   returns the number of utf-8 characters in the next N bytes starting from str
                           ## ```
proc dtx_utf8_from_char_code*(code: cint; buf: cstring): uint {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   Converts a unicode code-point to a utf-8 character by filling in the buffer
                    ##    passed at the second argument, and returns the number of bytes taken by that
                    ##    utf-8 character.
                    ##    It's valid to pass a null buffer pointer, in which case only the byte count is
                    ##    returned (useful to figure out how much memory to allocate for a buffer).
                    ## ```
proc dtx_utf8_from_string*(str: ptr wchar_t; buf: cstring): uint {.importc,
    cdecl, impdrawtextDyn.}
  ## ```
                           ##   Converts a unicode utf-16 wchar_t string to utf-8, filling in the buffer passed
                           ##    at the second argument. Returns the size of the resulting string in bytes.
                           ##   
                           ##    It's valid to pass a null buffer pointer, in which case only the size gets
                           ##    calculated and returned, which is useful for figuring out how much memory to
                           ##    allocate for the utf-8 buffer.
                           ## ```
proc dtx_line_height*(): cfloat {.importc, cdecl, impdrawtextDyn.}
  ## ```
                                                                  ##   ---- metrics ----
                                                                  ## ```
proc dtx_baseline*(): cfloat {.importc, cdecl, impdrawtextDyn.}
proc dtx_glyph_box*(code: cint; box: ptr dtx_box) {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   rendered dimensions of a single glyph
                    ## ```
proc dtx_glyph_width*(code: cint): cfloat {.importc, cdecl, impdrawtextDyn.}
proc dtx_glyph_height*(code: cint): cfloat {.importc, cdecl, impdrawtextDyn.}
proc dtx_string_box*(str: cstring; box: ptr dtx_box) {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   rendered dimensions of a string
                    ## ```
proc dtx_substring_box*(str: cstring; start: cint; `end`: cint; box: ptr dtx_box) {.
    importc, cdecl, impdrawtextDyn.}
proc dtx_string_width*(str: cstring): cfloat {.importc, cdecl, impdrawtextDyn.}
proc dtx_string_height*(str: cstring): cfloat {.importc, cdecl, impdrawtextDyn.}
proc dtx_char_pos*(str: cstring; n: cint): cfloat {.importc, cdecl,
    impdrawtextDyn.}
  ## ```
                    ##   returns the horizontal position of the n-th character of the rendered string
                    ##    (useful for placing cursors)
                    ## ```
proc dtx_char_at_pt*(str: cstring; pt: cfloat): cint {.importc, cdecl,
    impdrawtextDyn.}
{.pop.}
