
##    Copyright (c) 2013 Randy Gaul http://RandyGaul.net
##
##    This software is provided 'as-is', without any express or implied
##    warranty. In no event will the authors be held liable for any damages
##    arising from the use of this software.
##
##    Permission is granted to anyone to use this software for any purpose,
##    including commercial applications, and to alter it and redistribute it
##    freely, subject to the followindowg restrictions:
##      1. The origin of this software must not be misrepresented; you must not
##         claim that you wrote the original software. If you use this software
##         in a product, an acknowledgment in the product documentation would be
##         appreciated but is not required.
##      2. Altered source versions must be plainly marked as such, and must not be
##         misrepresented as being the original software.
##      3. This notice may not be removed or altered from any source distribution.
##
##    Port to Nim by Matic Kukovec https://github.com/matkuki/Nim-Impulse-Engine

import
    opengl,
    opengl/glut,
    algorithm


const
    FRAME_RATE* = 60


#[
    String rendering
]#
type
    StringElement = object
        x, y: int32
        text: string
        cycleCount: int

var stringList = newSeq[StringElement]()

proc renderString(x, y: int32; text: string) =
    glColor3f(0.5f, 0.5f, 0.9f)
    glRasterPos2i(x, y)
    for i in 0 ..< text.len():
        glutBitmapCharacter(GLUT_BITMAP_9_BY_15, cint(text[i]))

proc displayString*(x, y: int32; text: string, seconds: int=(-1)) =
    var newList = newSeq[StringElement]()
    for s in stringList:
        if s.x == x and s.y == y:
            continue
        newList.add(s)
    stringList = newList
    stringList.add(
        StringElement(
            x: x,
            y: y,
            text: text,
            cycleCount: (seconds * FRAME_RATE))
    )

proc renderStrings*() =
    var
        removeList = newSeq[int]()
        count = 0
    for s in stringList.mitems():
        renderString(s.x, s.y, s.text)
        if s.cycleCount > 0:
            s.cycleCount -= 1
        if s.cycleCount == 0:
            removeList.add(count)
        count += 1
    for r in removeList.reversed():
        stringList.del(r)


