
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

import
    ie_math,
    shapes,
    manifold,
    opengl

type
    Scene* = ref object of RootObj
        mIterations*: int
        bodies*: seq[Body]
        contacts*: seq[Manifold]

proc newScene*(iterations: int): Scene =
    new(result)
    result.mIterations = iterations
    result.bodies = newSeq[Body]()
    result.contacts = newSeq[Manifold]()
    
proc integrateForces*(b: Body, dt: float) =
    if b.massInverse == 0.0f:
        return
    b.velocity += ((b.force * b.massInverse) + gravity) * (dt / 2.0f)
    b.angularVelocity += b.torque * b.inertiaInverse * (dt / 2.0f)

proc integrateVelocity*(b: Body, dt: float) =
    if b.massInverse == 0.0f:
        return
    b.position += b.velocity * dt
    b.orient += b.angularVelocity * dt
    b.setOrient(b.orient)
    integrateForces(b, dt)

proc step*(self: Scene, dt:float) =
    # Generate new collision info
    self.contacts = @[]
    for i in 0..len(self.bodies)-1:
        var A: Body = self.bodies[i]
        for j in i+1..len(self.bodies)-1:
            var B: Body = self.bodies[j]
            if A.massInverse == 0 and B.massInverse == 0:
                continue
            var m: Manifold = Manifold(A: A, B: B)
            m.solve()
            if m.contactCount != 0:
                self.contacts.add(m)
    # Integrate forces
    for i in 0..len(self.bodies)-1:
        integrateForces(self.bodies[i], dt)
    # Initialize collision
    for i in 0..len(self.contacts)-1:
        self.contacts[i].initialize()
    # Solve collisions
    for j in 0..self.mIterations-1:
        for i in 0..len(self.contacts)-1:
            self.contacts[i].applyImpulse()
    # Integrate velocities
    for i in 0..len(self.bodies)-1:
        integrateVelocity(self.bodies[i], dt)
    # Correct positions
    for i in 0..len(self.contacts)-1:
        self.contacts[i].positionalCorrection()
    # Clear all forces
    for i in 0..len(self.bodies)-1:
        var b: Body = self.bodies[i]
        b.force.set(0.0, 0.0)
        b.torque = 0

proc render*(self: Scene) =
    for i in 0..len(self.bodies)-1:
        self.bodies[i].shape.draw()
    glPointSize(4.0f)
    glBegin(GL_POINTS);
    glColor3f(1.0f, 0.0f, 0.0f)
    
    for i in 0..len(self.contacts)-1:
        var m: Manifold = self.contacts[i]
        for j in 0..m.contactCount-1:
            var c: Vec = m.contacts[j]
            glVertex2f(c.x, c.y)
    glEnd()
    glPointSize(1.0f)

    glBegin(GL_LINES)
    glColor3f(0.0f, 1.0f, 0.0f)
    for i in 0..len(self.contacts)-1:
        var 
            m: Manifold = self.contacts[i]
            n: Vec = m.normal
        for j in 0..m.contactCount-1:
            var c: Vec = m.contacts[j]
            glVertex2f(c.x, c.y)
            n *= 0.75f
            c += n
            glVertex2f(c.x, c.y)
    glEnd()

proc add*(self: Scene, shape: Shape, x: float, y: float): Body =
    assert(shape != nil)
    var b: Body = newBody(shape, x, y)
    self.bodies.add(b)
    result = b




