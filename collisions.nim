
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


proc circleToCircle*(m: Manifold, a: Body, b: Body) =
    var
        A: Circle = Circle(a.shape)
        B: Circle = Circle(b.shape)
        # Calculate translational vector, which is normal
        normal = b.position - a.position
        distSqr = normal.lenSqr()
        radius = A.radius + B.radius
    # Not in contact
    if distSqr >= (radius * radius):
        m.contactCount = 0
        return
    var distance: float = math.sqrt(distSqr)
    m.contactCount = 1
    if distance == 0.0f:
        m.penetration = A.radius
        m.normal = Vec(x:1, y:0)
        m.contacts[0] = a.position
    else:
        m.penetration = radius - distance
        m.normal = normal / distance # Faster than using Normalized since we already performed sqrt
        m.contacts[0] = (m.normal * A.radius) + a.position

proc circleToPolygon*(m: Manifold, a: Body, b: Body) =
    var
        A: Circle = Circle(a.shape)
        B: Polygon = Polygon(b.shape)
    m.contactCount = 0
    # Transform circle center to Polygon model space
    var center: Vec = a.position
    center = B.orientation.transpose() * (center - b.position)
    # Find edge with minimum penetration
    # Exact concept as using support points in Polygon vs Polygon 
    var
        separation: float = -float(high(int))
        faceNormal: int = 0
    for i in 0..B.mVertexCount-1:
        var
            s: float = dot(B.mNormals[i], center - B.mVertices[i])
        if s > A.radius:
            return
        if s > separation:
            separation = s
            faceNormal = i
    # Grab face's vertices
    var
        v1: Vec = B.mVertices[faceNormal]
        i2: int = if((faceNormal + 1) < B.mVertexCount): faceNormal + 1 else: 0
        v2: Vec = B.mVertices[i2]
    # Check to see if center is within polygon
    if separation < EPSILON:
        m.contactCount = 1
        m.normal = -(B.orientation * B.mNormals[faceNormal])
        m.contacts[0] = m.normal * A.radius + a.position
        m.penetration = A.radius
        return
    # Determine which voronoi region of the edge center of circle lies within
    var
        dot1: float = dot(center - v1, v2 - v1)
        dot2: float = dot(center - v2, v1 - v2)
    m.penetration = A.radius - separation
    # Closest to v1
    if dot1 <= 0.0f:
        if distSqr(center, v1) > (A.radius * A.radius):
            return
        m.contactCount = 1
        var n: Vec = v1 - center
        n = B.orientation * n
        n.normalize()
        m.normal = n
        v1 = (B.orientation * v1) + b.position
        m.contacts[0] = v1
        
    # Closest to v2
    elif dot2 <= 0.0f:
        if distSqr(center, v2) > (A.radius * A.radius):
            return
        m.contactCount = 1
        var n: Vec = v2 - center
        v2 = (B.orientation * v2) + b.position
        m.contacts[0] = v2
        n = B.orientation * n
        n.normalize()
        m.normal = n
        
    # Closest to face
    else:
        var n: Vec = B.mNormals[faceNormal]
        if dot(center - v1, n) > A.radius:
            return
        n = B.orientation * n
        m.normal = -n
        m.contacts[0] = (m.normal * A.radius) + a.position
        m.contactCount = 1

proc polygonToCircle*(m: Manifold, a: Body, b: Body) =
    circletoPolygon(m, b, a)
    m.normal = -m.normal

proc findAxisLeastPenetration*(faceIndex: var int, A: Polygon, B: Polygon): float =
    var
        bestDistance: float = -float(high(int))
        bestIndex: int
    for i in 0..A.mVertexCount-1:
        var
            # Retrieve a face normal from A
            n: Vec = A.mNormals[i]
            nw: Vec = A.orientation * n
            # Transform face normal into B's model space
            buT: Mat = B.orientation.transpose()
        n = buT * nw
        var
            # Retrieve support point from B along -n
            s: Vec = B.getSupport(-n)
            # Retrieve vertex on face from A, transform into
            # B's model space
            v: Vec = A.mVertices[i]
        v = (A.orientation * v) + A.body.position
        v -= B.body.position
        v = buT * v
        # Compute penetration distance (in B's model space)
        var d: float = dot(n, s - v)
        # Store greatest distance
        if d > bestDistance:
            bestDistance = d
            bestIndex = i
    faceIndex = bestIndex
    result = bestDistance

proc findIncidentFace*(v: var openarray[Vec], refPoly: Polygon, 
                       incPoly: Polygon, referenceIndex: int) =
    var referenceNormal = refPoly.mNormals[referenceIndex]
    # Calculate normal in incident's frame of reference
    referenceNormal = refPoly.orientation * referenceNormal # To world space
    referenceNormal = incPoly.orientation.transpose() * referenceNormal # To incident's model space
    # Find most anti-normal face on incident polygon
    var
        incidentFace: int = 0
        minDot: float = float(high(int))
    for i in 0..incPoly.mVertexCount-1:
        var dot: float = dot(referenceNormal, incPoly.mNormals[i])
        if dot < minDot:
            minDot = dot
            incidentFace = i
    # Assign face vertices for incidentFace
    v[0] = incPoly.orientation * incPoly.mVertices[incidentFace] + incPoly.body.position
    incidentFace = if((incidentFace + 1) >= incPoly.mVertexCount): 0 else: incidentFace + 1
    v[1] = incPoly.orientation * incPoly.mVertices[incidentFace] + incPoly.body.position

proc clip*(n: Vec, c: float, face: var array[0..1, Vec]): int =
    var
        sp: int = 0
        outVec: array[0..1, Vec] = [face[0], face[1]]
        # Retrieve distances from each endpoint to the line
        # d = ax + by - c
        d1: float = dot(n, face[0]) - c
        d2: float = dot(n, face[1]) - c
    # If negative (behind plane) clip
    if d1 <= 0.0f: 
        outVec[sp] = face[0]
        inc(sp)
    if d2 <= 0.0f: 
        outVec[sp] = face[1]
        inc(sp)
    # If the points are on different sides of the plane
    if (d1 * d2) < 0.0f: # less than to ignore -0.0f
        # Push interesection point
        var alpha: float = d1 / (d1 - d2)
        outVec[sp] = face[0] + alpha * (face[1] - face[0])
        inc(sp)
    # Assign our new converted values
    face[0] = outVec[0]
    face[1] = outVec[1]
    assert(sp != 3)
    result = sp

proc polygonToPolygon*(m: Manifold, a: Body, b: Body) =
    var
        A: Polygon = Polygon(a.shape)
        B: Polygon = Polygon(b.shape)
    m.contactCount = 0
    # Check for a separating axis with A's face planes
    var
        faceA: int
        penetrationA: float = findAxisLeastPenetration(faceA, A, B)
    if penetrationA >= 0.0f:
        return
    # Check for a separating axis with B's face planes
    var
        faceB: int
        penetrationB: float = findAxisLeastPenetration(faceB, B, A)
    if penetrationB >= 0.0f:
        return
    var
        referenceIndex: int
        flip: bool # Always point from a to b
        refPoly: Polygon # Reference
        incPoly: Polygon # Incident
    # Determine which shape contains reference face
    if biasGreaterThan(penetrationA, penetrationB):
        refPoly = A
        incPoly = B
        referenceIndex = faceA
        flip = false
    else:
        refPoly = B
        incPoly = A
        referenceIndex = faceB
        flip = true
    # World space incident face
    var incidentFace: array[0..1, Vec]
    findIncidentFace(incidentFace, refPoly, incPoly, referenceIndex)
    
    #        y
    #        ^  ->n       ^
    #      +---c ------posPlane--
    #  x < | i |\
    #      +---+ c-----negPlane--
    #             \       v
    #              r
    #
    #  r : reference face
    #  i : incident poly
    #  c : clipped point
    #  n : incident normal
    
    # Setup reference face vertices
    var v1 = refPoly.mVertices[referenceIndex]
    referenceIndex = if((referenceIndex + 1) == refPoly.mVertexCount): 0 else: referenceIndex + 1
    var v2 = refPoly.mVertices[referenceIndex]
    # Transform vertices to world space
    v1 = refPoly.orientation * v1 + refPoly.body.position
    v2 = refPoly.orientation * v2 + refPoly.body.position
    # Calculate reference face side normal in world space
    var sidePlaneNormal: Vec = v2 - v1
    sidePlaneNormal.normalize()
    # Orthogonalize
    var refFaceNormal: Vec = Vec(x: sidePlaneNormal.y, y: -sidePlaneNormal.x)
    # ax + by = c
    # c is distance from origin
    var
        refC: float = dot(refFaceNormal, v1)
        negSide: float = -dot(sidePlaneNormal, v1)
        posSide: float = dot(sidePlaneNormal, v2)
    # Clip incident face to reference face side planes
    if clip(-sidePlaneNormal, negSide, incidentFace) < 2:
        return # Due to floating point error, possible to not have required points
    if clip(sidePlaneNormal, posSide, incidentFace) < 2:
        return # Due to floating point error, possible to not have required points
    # Flip
    m.normal = if(flip): -refFaceNormal else: refFaceNormal
    # Keep points behind reference face
    var
        cp: int = 0 # clipped points behind reference face
        separation: float = dot(refFaceNormal, incidentFace[0]) - refC
    if separation < 0.0f:
        m.contacts[cp] = incidentFace[0]
        m.penetration = -separation
        inc(cp)
    else:
        m.penetration = 0
    separation = dot(refFaceNormal, incidentFace[1]) - refC
    if separation <= 0.0f:
        m.contacts[cp] = incidentFace[1]
        m.penetration += -separation
        inc(cp)
        # Average penetration
        m.penetration /= float(cp)
    m.contactCount = cp








