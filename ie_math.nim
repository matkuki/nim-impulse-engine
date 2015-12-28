
##    Copyright (c) 2015 Matic Kukovec
##
##    This software is provided 'as-is', without any express or implied
##    warranty. In no event will the authors be held liable for any damages
##    arising from the use of this software.
##
##    Permission is granted to anyone to use this software for any purpose,
##    including commercial applications, and to alter it and redistribute it
##    freely, subject to the following restrictions:
##      1. The origin of this software must not be misrepresented; you must not
##         claim that you wrote the original software. If you use this software
##         in a product, an acknowledgment in the product documentation would be
##         appreciated but is not required.
##      2. Altered source versions must be plainly marked as such, and must not be
##         misrepresented as being the original software.
##      3. This notice may not be removed or altered from any source distribution.

import math


const
    PI*: float = 3.141592741f
    EPSILON*: float = 0.0001f
    RAND_MAX*: float = 32767.0f



############
## Vector ##
############
type
    Vec* = object
        x*: float
        y*: float

proc set*(inVector: var Vec, inX: float, inY: float) =
    inVector.x = inX
    inVector.y = inY
    
proc `-`*(inVector: Vec): Vec =
    result = Vec(x: -inVector.x, y: -inVector.y)

proc `*`*(inVector: Vec, scalar: float): Vec =
    result = Vec(x: inVector.x * scalar, y: inVector.y * scalar)

proc `*`*(scalar: float, inVector: Vec): Vec =
    result = Vec(x: scalar * inVector.x, y: scalar * inVector.y)

proc `/`*(inVector: Vec, scalar: float): Vec =
    result = Vec(x: inVector.x / scalar, y: inVector.y / scalar)

proc `*=`*(inVector: var Vec, scalar: float) =
    inVector.x *= scalar
    inVector.y *= scalar

proc `+`*(inVector: Vec, scalar: float): Vec =
    result = Vec(x: inVector.x + scalar, y: inVector.y + scalar)

proc `+`*(inVector: Vec, addVector: Vec): Vec =
    result = Vec(x: inVector.x + addVector.x, y: inVector.y + addVector.y)

proc `+=`*(inVector: var Vec, addVector: Vec) =
    inVector.x += addVector.x
    inVector.y += addVector.y

proc `-`*(inVector: Vec, scalar: float): Vec =
    result = Vec(x: inVector.x - scalar, y: inVector.y - scalar)

proc `-`*(inVector: Vec, subVector: Vec): Vec =
    result = Vec(x: inVector.x - subVector.x, y: inVector.y - subVector.y)

proc `-=`*(inVector: var Vec, subVector: Vec) =
    inVector.x -= subVector.x
    inVector.y -= subVector.y

proc lenSqr*(inVector: Vec): float =
    result = inVector.x * inVector.x + inVector.y * inVector.y

proc len*(inVector: Vec): float =
    result = math.sqrt(inVector.x * inVector.x + inVector.y * inVector.y)

proc rotate*(inVector: var Vec, radians: float) =
    var
        c = math.cos(radians)
        s = math.sin(radians)
        xp = inVector.x * c - inVector.y * s
        yp = inVector.x * s + inVector.y * c
    inVector.x = xp
    inVector.y = yp

proc normalize*(inVector: var Vec) =
    var len = inVector.len()
    if len > EPSILON:
        var invLen = 1.0f / len
        inVector.x *= invLen
        inVector.y *= invLen


############
## Matrix ##
############
type
    Mat* = object
        m00*: float
        m01*: float
        m10*: float
        m11*: float

proc newMat*(radians: float): Mat =
    var
        c = math.cos(radians)
        s = math.sin(radians)
    result.m00 = c
    result.m01 = -s
    result.m10 = s
    result.m11 = c

proc set*(inMatrix: var Mat, radians: float) =
    var
        c = math.cos(radians)
        s = math.sin(radians)
    inMatrix.m00 = c
    inMatrix.m01 = -s
    inMatrix.m10 = s
    inMatrix.m11 = c

proc abs*(inMatrix: Mat): Mat =
    result.m00 = abs(inMatrix.m00)
    result.m01 = abs(inMatrix.m01)
    result.m10 = abs(inMatrix.m10)
    result.m11 = abs(inMatrix.m11)

proc axisX*(inMatrix: Mat): Vec =
    result.x = inMatrix.m00
    result.y = inMatrix.m10

proc axisY*(inMatrix: Mat): Vec =
    result.x = inMatrix.m01
    result.y = inMatrix.m11

proc transpose*(inMatrix: Mat): Mat =
    result.m00 = inMatrix.m00
    result.m01 = inMatrix.m10
    result.m10 = inMatrix.m01
    result.m11 = inMatrix.m11

proc `*`*(inMatrix: Mat, inVector: Vec): Vec =
    result.x = inMatrix.m00 * inVector.x + inMatrix.m01 * inVector.y
    result.y = inMatrix.m10 * inVector.x + inMatrix.m11 * inVector.y

proc min*(a, b: Vec): Vec =
    result.x = min(a.x, b.x)
    result.y = min(a.y, b.y)

proc max*(a, b: Vec): Vec =
    result.x = max(a.x, b.x)
    result.y = max(a.y, b.y)

proc dot*(a, b: Vec): float =
    result = a.x * b.x + a.y * b.y

proc distSqr*(a, b: Vec): float =
    var c = a - b
    result = dot(c, c)

proc cross*(inVector: Vec, scalar: float): Vec =
    result.x = scalar * inVector.y
    result.y = -scalar * inVector.x

proc cross*(scalar: float, inVector: Vec): Vec =
    result.x = -scalar * inVector.y
    result.y = scalar * inVector.x

proc cross*(a, b: Vec): float =
    result = a.x * b.y - a.y * b.x

proc equal*(a, b: float): bool =
    result = abs(a - b) <= EPSILON

proc sqr*(number: float): float =
    result = number * number

proc clamp*(min, max, number: float): float =
    if number < min:
        result = min
    elif number > max:
        result = max
    else:
        result = number

proc round*(number: float): int =
    result = int(number + 0.5f)

proc random*(low, high: float): float =
    result = math.random(RAND_MAX)
    result /= RAND_MAX
    result = (high - low) * result + low

proc biasGreaterThan*(a, b: float): bool =
    const
        kBiasRelative = 0.95f
        kBiasAbsolute = 0.01f
    result = a >= b * kBiasRelative + a * kBiasAbsolute



###########
## Other ##
###########
const
    gravityScale*: float32 = 5.0f
    gravity*: Vec = Vec(x: 0.0f, y: 10.0f * gravityScale)
    dt*: float = 1.0f / 60.0f

