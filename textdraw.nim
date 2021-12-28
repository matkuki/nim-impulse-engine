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
    iemath,
    shapes,
    manifold,
    opengl,
    freetype/freetype

#[
    Freetype text drawing
]#
var lib: FT_Library

proc init_freetype*() =
    let result = freetype.init(lib)
    if result != 0:
        raise newException(LibraryError, "[FreeType] Initialization error!")

proc draw_text_opengl*(text: string,
                       position: Vec, 
                       color: Color) =
    discard