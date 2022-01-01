##[
    Copyright (c) 2013 Randy Gaul http://RandyGaul.net
    ##
    This software is provided 'as-is', without any express or implied
    warranty. In no event will the authors be held liable for any damages
    arising from the use of this software.
    ##
    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software
        in a product, an acknowledgment in the product documentation would be
        appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be
        misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
    ##
    Port to Nim by Matic Kukovec https://github.com/matkuki/Nim-Impulse-Engine
]##

import
    data,
    iemath,
    shapes,
    manifold,
    opengl,
#    freetype/freetype,
    libdrawtext

#[
    Freetype text drawing
]#
#var lib: FT_Library
#
#proc init_freetype*() =
#    let result = freetype.init(lib)
#    if result != 0:
#        raise newException(LibraryError, "[FreeType] Initialization error!")

var font: ptr dtx_font

proc init*() =
    # XXX dtx_open_font opens a font file and returns a pointer to dtx_font
    font = dtx_open_font("SourceCodePro-Regular.ttf", 16)
    if font == nil:
        raise newException(LibraryError, "[libdrawtext]Failed to open font")
    # XXX select the font and size to render with by calling dtx_use_font
    # if you want to use a different font size, you must first call:
    # dtx_prepare(font, size) once.
    dtx_use_font(font, 16);

proc draw_text*(text: string,
                position: Vec,
                color: Color) =
    glMatrixMode(GL_PROJECTION)
    glPushMatrix()
    glScalef(1.0, -1.0, 1.0)
#    let
#        w = dtx_string_width(text)
#        h = dtx_string_height(text)
#    echo w, " ", h
    glTranslatef(-4.0 + position.x, -15.0 - position.y, 0.0)
#    glRotatef(20.0, 0.0, 0.0, 1)
    glColor3f(color.r, color.g, color.b)
    # XXX call dtx_string to draw utf-8 text.
    # any transformations and the current color apply
    dtx_string(text)
    glPopMatrix()