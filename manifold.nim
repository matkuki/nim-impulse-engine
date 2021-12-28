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
    shapes

type
    Manifold* = ref object of RootObj
        A*: Body
        B*: Body
        penetration*: float # Depth of penetration from collision
        normal*: Vec # From A to B
        contacts*: array[0..1, Vec] # Points of contact during collision
        contactCount*: int # Number of contacts that occured during collision
        e*: float # Mixed restitution
        df*: float # Mixed dynamic friction
        sf*: float # Mixed static friction

proc initialize*(self: Manifold) =
    # Calculate average restitution
    self.e = min(self.A.restitution, self.B.restitution)
    # Calculate static and dynamic friction
    self.sf = math.sqrt(self.A.staticFriction * self.A.staticFriction)
    self.df = math.sqrt(self.A.dynamicFriction * self.A.dynamicFriction)
    
    for i in 0..self.contactCount-1:
        # Calculate radii from COM to contact
        var
            ra: Vec = self.contacts[i] - self.A.position
            rb: Vec = self.contacts[i] - self.B.position
            # Relative velocity
            rv: Vec = self.B.velocity + cross(self.B.angularVelocity, rb) -
                      self.A.velocity + cross(self.A.angularVelocity, ra)
        # Determine if we should perform a resting collision or not
        # The idea is if the only thing moving this object is gravity,
        # then the collision should be performed without any restitution
        if rv.lenSqr() < ((dt * gravity).lenSqr() + EPSILON):
            self.e = 0.0f

proc infiniteMassCorrection*(self: Manifold) =
    self.A.velocity.set(0.0 ,0.0)
    self.B.velocity.set(0.0, 0.0)

proc applyImpulse*(self: Manifold) =
    # Early out and positional correct if both objects have infinite mass
    if iemath.equal(self.A.massInverse + self.B.massInverse, 0):
        self.infiniteMassCorrection()
        return
    for i in 0..self.contactCount-1:
        # Calculate radii from COM to contact
        var
            ra: Vec = self.contacts[i] - self.A.position
            rb: Vec = self.contacts[i] - self.B.position
            # Relative velocity
            rv: Vec = self.B.velocity + cross(self.B.angularVelocity, rb) -
                      self.A.velocity - cross(self.A.angularVelocity, ra)
            # Relative velocity along the normal
            contactVel: float = dot(rv, self.normal)
        # Do not resolve if velocities are separating
        if contactVel > 0:
            return
        var
            raCrossN: float = cross(ra, self.normal)
            rbCrossN: float = cross(rb, self.normal)
            invMassSum: float = self.A.massInverse + self.B.massInverse +
                                (sqr(raCrossN) * self.A.inertiaInverse) +
                                (sqr(rbCrossN) * self.B.inertiaInverse)
            # Calculate impulse scalar
            j: float = -(1.0f + self.e) * contactVel
        j /= invMassSum
        j /= float(self.contactCount)
        # Apply impulse
        var impulse: Vec = self.normal * j
        self.A.applyImpulse(-impulse, ra)
        self.B.applyImpulse(impulse, rb)
        # Friction impulse
        rv = self.B.velocity + cross(self.B.angularVelocity, rb) -
             self.A.velocity - cross(self.A.angularVelocity, ra)
        var t: Vec = rv - (self.normal * dot(rv, self.normal))
        t.normalize()
        # j tangent magnitude
        var jt: float = -dot(rv, t)
        jt /= invMassSum
        jt /= float(self.contactCount)
        # Don't apply tiny friction impulses
        if equal( jt, 0.0f ):
            return
        # Coulumb's law
        var tangentImpulse: Vec
        if abs(jt) < (j * self.sf):
            tangentImpulse = t * jt
        else:
            tangentImpulse = t * -j * self.df
        # Apply friction impulse
        self.A.applyImpulse(-tangentImpulse, ra)
        self.B.applyImpulse(tangentImpulse, rb)

proc positionalCorrection*(self: Manifold) =
    const
        kSlop: float = 0.00001f # Penetration allowance
        percent: float = 0.2f # Penetration percentage to correct
    var
        correction: Vec = (max(self.penetration - kSlop, 0.0f) / (self.A.massInverse + self.B.massInverse)) *
                          self.normal * percent
    self.A.position -= correction * self.A.massInverse
    self.B.position += correction * self.B.massInverse

## Copies the contents of the included module into this module
include collisions

proc solve*(self: Manifold) =
    var
        typeA: ShapeType = self.A.shape.getType()
        typeB: ShapeType = self.B.shape.getType()
    if typeA == stCircle and typeB == stCircle:
        circleToCircle(self, self.A, self.B)
    elif typeA == stCircle and typeB == stPoly:
        circleToPolygon(self, self.A, self.B)
    elif typeA == stPoly and typeB == stPoly:
        polygonToPolygon(self, self.A, self.B)
    elif typeA == stPoly and typeB == stCircle:
        polygonToCircle(self, self.A, self.B)
