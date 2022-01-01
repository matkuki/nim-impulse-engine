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

const
    VERSION* = "1.6.2"
    WINDOW_SIZE* = (w: 800, h: 600)
    FRAME_RATE* = 60.int32
    FRAME_TIME* = 1.0f/float(FRAME_RATE)
    # If the VSYNC value is true, the FRAME_RATE has to be set to the monitor
    # refresh rate! If it's lower, everything will move faster
    VSYNC* = true
    LEFT_CLICK_RANDOM_POLYGONS* = true