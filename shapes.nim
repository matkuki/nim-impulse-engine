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
    math,
    iemath,
    opengl

const
    MaxPolyVertexCount* = 64

type
    Body* = ref object of RootObj
        position*: Vec
        velocity*: Vec
        angularVelocity*: float
        torque*: float
        orient*: float # radians
        force*: Vec
        # Set by shape
        inertia*: float  # moment of inertia
        inertiaInverse*: float
        mass*: float
        massInverse*: float
        # http://gamedev.tutsplus.com/tutorials/implementation/how-to-create-a-custom-2d-physics-engine-friction-scene-and-jump-table/
        staticFriction*: float
        dynamicFriction*: float
        restitution*: float
        # Shape interface
        shape*: Shape
        # Store a color in RGB format
        r*, g*, b*: float

    ShapeType* = enum
        stCircle
        stPoly
        stCount

    Shape* = ref object of RootObj
        body*: Body
        # For the circle
        radius*: float 
        # For polygon shape
        orientation*: Mat # Orientation matrix from model to world
    
    Circle* = ref object of Shape
    
    Polygon* = ref object of Shape
        mVertexCount*: int
        mVertices*: array[0..MaxPolyVertexCount, Vec]
        mNormals*: array[0..MaxPolyVertexCount, Vec]


#[
    Shape methods (base)
]#
method clone*(self: Shape): Shape {.base, inline.} = 
    quit "Virtual method, must be overridden!"

method computeMass*(self: Shape, density: float) {.base, inline.} = 
    quit "Virtual method, must be overridden!"

method initialize*(self: Shape) {.base, inline.} = 
    quit "Virtual method, must be overridden!"

method setOrient*(self: Shape, radians: float) {.base, inline.} = 
    quit "Virtual method, must be overridden!"

method draw*(self: Shape) {.base, inline.} = 
    quit "Virtual method, must be overridden!"

method getType*(self: Shape): ShapeType {.base, inline.} = 
    quit "Virtual method, must be overridden!"


#[
    Circle procedures/methods
]#
proc newCircle*(radius: float): Circle =
    new(result)
    new(result.body)
    result.radius = radius
    
method clone*(self: Circle): Shape =
    result = newCircle(self.radius)

method computeMass(self: Circle, density: float) =
    # Mass
    self.body.mass = iemath.PI * self.radius * self.radius * density
    if self.body.mass > 0.0f:
        self.body.massInverse = 1.0f / self.body.mass
    else:
        self.body.massInverse = 0.0f
    # Inertia
    self.body.inertia = self.body.mass * self.radius * self.radius
    if self.body.inertia > 0.0f:
        self.body.inertiaInverse = 1.0f / self.body.inertia
    else:
        self.body.inertiaInverse = 0.0f

method initialize*(self: Circle) =
    self.computeMass(1.0f)

method setOrient*(self: Circle, radians: float) =
    discard

method draw*(self: Circle) =
    const k_segments: int = 20
    # Render a circle with a bunch of lines
    glColor3f(self.body.r, self.body.g, self.body.b)
    glBegin(GL_LINE_LOOP)
    var
        theta: float = self.body.orient
        inc = iemath.PI * 2.0f / float(k_segments)
    for i in 0..k_segments-1:
        theta += inc
        var p: Vec = Vec(x: math.cos(theta), y: math.sin(theta))
        p *= self.radius
        p += self.body.position
        glVertex2f(p.x*SCALE, p.y*SCALE)
    glEnd()
    # Render line within circle so orientation is visible
    glBegin(GL_LINE_STRIP)
    var
        r: Vec = Vec(x: 0.0, y: 1.0)
        c: float = math.cos(self.body.orient)
        s: float = math.sin(self.body.orient)
    r.set(r.x * c - r.y * s, r.x * s + r.y * c)
    r *= self.radius
    r = r + self.body.position
    glVertex2f(self.body.position.x*SCALE, self.body.position.y*SCALE)
    glVertex2f(r.x*SCALE, r.y*SCALE)
    glEnd()
    # Draw object body's center point
    glPointSize(4.0f)
    glBegin(GL_POINTS);
    glColor3f(1.0f, 0.0f, 0.0f)
    glVertex2f(self.body.position.x*SCALE, self.body.position.y*SCALE)
    glEnd()

method getType*(self: Circle): ShapeType =
    result = stCircle


#[
    Polygon procedures/methods
]#
proc newPolygon*(): Polygon =
    new(result)
    new(result.body)

method computeMass*(self: Polygon, density: float) =
    # Calculate centroid and moment of interia
    var
        c: Vec = Vec(x: 0.0f, y: 0.0f) # centroid
        area: float = 0.0f
        I: float = 0.0f
    const k_inv3: float = 1.0f / 3.0f

    for i1 in 0..self.mVertexCount-1:
        # Triangle vertices, third vertex implied as (0, 0)
        var
            p1: Vec = self.mVertices[i1]
            i2: int = if (i1 + 1 < self.mVertexCount): i1 + 1 else: 0
            p2: Vec = self.mVertices[i2]
            D: float = iemath.cross(p1, p2)
            triangleArea: float = 0.5f * D
        area += triangleArea
        # Use area to weight the centroid average, not just vertex position
        c += (triangleArea * k_inv3 * (p1 + p2))
        var
            intx2 = p1.x * p1.x + p2.x * p1.x + p2.x * p2.x
            inty2 = p1.y * p1.y + p2.y * p1.y + p2.y * p2.y
        I += (0.25f * k_inv3 * D) * (intx2 + inty2)

    c *= 1.0f / area
    
    self.body.mass = density * area
    self.body.massInverse = if (self.body.mass > 0.0f): 1.0f / self.body.mass else: 0.0f
    self.body.inertia = I * density
    self.body.inertiaInverse = if (self.body.inertia > 0.0f): 1.0f / self.body.inertia else: 0.0f

method initialize*(self: Polygon) =
    self.computeMass(1.0f)

method clone*(self: Polygon): Shape =
    var poly: Polygon
    new(poly)
    poly.orientation = self.orientation
    for i in 0..self.mVertexCount-1:
        poly.mVertices[i] = self.mVertices[i]
        poly.mNormals[i] = self.mNormals[i]
    poly.mVertexCount = self.mVertexCount
    result = poly

method setOrient*(self: Polygon, radians: float) =
    self.orientation.set(radians)

method draw*(self: Polygon) =
    glColor3f(self.body.r, self.body.g, self.body.b)
    glBegin(GL_LINE_LOOP)
    for i in 0..self.mVertexCount-1:
        let v: Vec = self.body.position + self.orientation * self.mVertices[i]
        glVertex2f(v.x*SCALE, v.y*SCALE)
    glEnd()
    # Draw all polygon vertices
    glColor3f(1.0f, 0.0f, 0.0f)
    glPointSize(2.0f)
    glBegin(GL_POINTS)
    for i in 0..self.mVertexCount-1:
        let v: Vec = self.body.position + self.orientation * self.mVertices[i]
        glVertex2f(v.x*SCALE, v.y*SCALE)
    glEnd()
    # Draw object body's center point
    glPointSize(4.0f)
    glBegin(GL_POINTS);
    glColor3f(1.0f, 0.0f, 0.0f)
    let centroid = self.body.position + 
        (self.orientation * computePolygonCentroid(self.mVertices, self.mVertexCount))
    glVertex2f(centroid.x*SCALE, centroid.y*SCALE)
    glEnd()
    

method getType*(self: Polygon): ShapeType =
    result = stPoly

proc setBox*(self: Polygon, hw: float, hh: float) =
    self.mVertexCount = 4
    self.mVertices[0].set(-hw, -hh)
    self.mVertices[1].set(hw, -hh)
    self.mVertices[2].set(hw, hh)
    self.mVertices[3].set(-hw, hh)
    self.mNormals[0].set(0.0f, -1.0f)
    self.mNormals[1].set(1.0f, 0.0f)
    self.mNormals[2].set(0.0f, 1.0f)
    self.mNormals[3].set(-1.0f, 0.0f)

proc set*(self: Polygon, vertices: openarray[Vec], inCount: int) =
    # No hulls with less than 3 vertices (ensure actual polygon)
    assert((inCount > 2) and (inCount <= MaxPolyVertexCount))
    var count = min(inCount, MaxPolyVertexCount)

    # Find the right most point on the hull
    var
        rightMost: int = 0
        highestXCoord: float = vertices[0].x
    for i in 1..count-1:
        var x: float = vertices[i].x
        if x > highestXCoord:
            highestXCoord = x
            rightMost = i
        # If matching x then take farthest negative y
        elif x == highestXCoord:
            if vertices[i].y < vertices[rightMost].y:
                rightMost = i
    var
        hull: array[0..MaxPolyVertexCount-1, int]
        outCount: int = 0
        indexHull: int = rightMost
    
    while true:
        hull[outCount] = indexHull
        # Search for next index that wraps around the hull
        # by computing cross products to find the most counter-clockwise
        # vertex in the set, given the previos hull index
        var nextHullIndex = 0
        for i in 1..count-1:
            # Skip if same coordinate as we need three unique
            # points in the set to perform a cross product
            if nextHullIndex == indexHull:
                nextHullIndex = i
                continue
            # Cross every set of three unique vertices
            # Record each counter clockwise third vertex and add
            # to the output hull
            # See : http://www.oocities.org/pcgpe/math2d.html
            var
                e1: Vec = vertices[nextHullIndex] - vertices[hull[outCount]]
                e2: Vec = vertices[i] - vertices[hull[outCount]]
                c: float = cross(e1, e2)
            if c < 0.0f:
                nextHullIndex = i
            # Cross product is zero then e vectors are on same line
            # therefor want to record vertex farthest along that line
            if (c == 0.0f) and (e2.lenSqr() > e1.lenSqr()):
                nextHullIndex = i
        inc(outCount)
        indexHull = nextHullIndex
        # Conclude algorithm upon wrap-around
        if nextHullIndex == rightMost:
            self.mVertexCount = outCount
            break
            
    # Copy vertices into shape's vertices
    for i in 0..self.mVertexCount-1:
        self.mVertices[i] = vertices[hull[i]]
    
    # Compute face normals
    for i1 in 0..self.mVertexCount-1:
        var
            i2 = if (i1 + 1 < self.mVertexCount): i1 + 1 else: 0
            face: Vec = self.mVertices[i2] - self.mVertices[i1]
        # Ensure no zero-length edges, because that's bad
        assert(face.lenSqr() > EPSILON * EPSILON)
        # Calculate normal with 2D cross product between vector and scalar
        self.mNormals[i1] = Vec(x: face.y, y: -face.x)
        self.mNormals[i1].normalize()

proc getSupport*(self: Polygon, dir: Vec): Vec =
    ## The extreme point along a direction within a polygon
    var
       bestProjection: float = -float(high(int))
       bestVertex: Vec
    for i in 0..self.mVertexCount-1:
        var
            v: Vec = self.mVertices[i]
            projection: float = dot(v, dir)
        if projection > bestProjection:
            bestVertex = v
            bestProjection = projection
    result = bestVertex

    
#[
    Body procedures
]#
proc newBody*[T: Shape|Circle|Polygon](shape: T, x: float, y: float): Body =
    new(result)
    result.shape = shape.clone()
    result.shape.body = result
    shape.body = result
    result.position.set(x, y)
    result.velocity.set(0.0, 0.0)
    result.angularVelocity = 0.0
    result.torque = 0.0
    result.orient = iemath.random(-PI, PI)
    result.force.set(0.0, 0.0)
    result.staticFriction = 0.5f
    result.dynamicFriction = 0.3f
    result.restitution = 0.2f
    shape.initialize()
    result.r = iemath.random(0.2f, 1.0f)
    result.g = iemath.random(0.2f, 1.0f)
    result.b = iemath.random(0.2f, 1.0f)
    

proc setOrient*(self: Body, radians: float) =
    self.orient = radians
    self.shape.setOrient(radians)

proc applyForce*(self: Body, f: Vec) =
    self.force += f

proc applyImpulse*(self: Body, impulse: Vec, contactVector: Vec) =
    self.velocity += self.massInverse * impulse
    self.angularVelocity += self.inertiaInverse * cross(contactVector, impulse)

proc setStatic*(self: Body) =
    self.inertia = 0.0f
    self.inertiaInverse = 0.0f;
    self.mass = 0.0f
    self.massInverse = 0.0f








