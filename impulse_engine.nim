
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
    os,
    strutils,
    strformat,
    times,
    math,
    options,
    ie_math,
    shapes,
    manifold,
    scene,
    rendering,
    nimgl/glfw,
    opengl,
    opengl/glu,
    opengl/glut

const
    VERSION = "1.1.0"
    WINDOW_SIZE = (w: 800.int32, h: 600.int32)
    FRAME_TIME = 1.0f/float(FRAME_RATE)
    # If the VSYNC value is true, the FRAME_RATE has to be set to the monitor
    # refresh rate! If it's lower, everything will move faster
    VSYNC = true

var
    done = false # Application exit flag
    frameStepping = false
    canStep = false
    window: GLFWWindow
    centerCircle = newCircle(5.0f)
    mainScene = newScene(10)
    monitor: GLFWMonitor
    videoMode: ptr GLFWVidMode
    bodyCounter: int = 0


proc initOpenGL() =
    loadExtensions()
    glMatrixMode(GL_PROJECTION)
    glPushMatrix()
    glLoadIdentity()
    gluOrtho2D(0, WINDOW_SIZE.w/10, WINDOW_SIZE.h/10, 0)
    glMatrixMode(GL_MODELVIEW)
    glPushMatrix()
    glLoadIdentity()
    glutInit()

proc mouseCallback(window: GLFWWindow,
                   button: int32,
                   action: int32,
                   modKeys: int32) {.cdecl.} =
    # Get cursor position and adjust it to openGL settings
    
    var
        x, y: float64
    window.getCursorPos(addr(x), addr(y))
    x /= 10.0f
    y /= 10.0f
    # Filter only mouse press events
    if action == GLFW_RELEASE:
        case button:
            of Button1:
                # Create random polygon
                var
                    poly: Polygon = newPolygon()
                    count: int = int(ie_math.random(3, MaxPolyVertexCount))
                    vertices: array[MaxPolyVertexCount, Vec]
                    e: float = ie_math.random(5.0f, 10.0f)
                    b: Body
                for i in 0..vertices.high:
                    vertices[i].set(ie_math.random(-e, e), ie_math.random(-e, e))
                poly.set(vertices, count)
                b = mainScene.add(poly, x, y)
                b.setOrient(ie_math.random(-ie_math.PI, ie_math.PI))
                b.restitution = 0.2f
                b.dynamicFriction = 0.2f
                b.staticFriction = 0.4f
                bodycounter += 1
                displayString(1, 6, "Polygon added", 2)
                displayString(4, 8, fmt"Total number of bodies: {bodycounter}", 2)

            of Button2:
                # Create random circle
                var
                    c: Circle = newCircle(ie_math.random(1.0f, 3.0f))
                discard mainScene.add(c, x, y)
                bodycounter += 1
                displayString(1, 6, "Circle added", 2)
                displayString(4, 8, fmt"Total number of bodies: {bodycounter}", 2)

            else:
                discard

proc keyCallback(window: GLFWWindow,
                 key: int32,
                 scanCode: int32,
                 action: int32,
                 modKeys: int32) {.cdecl.} =
    # Filter only keyUp events
    if action == GLFW_RELEASE:
        case key:
            of GLFWKey.Escape:
                window.setWindowShouldClose(true)
            of GLFWKey.F4:
                if (int(modKeys) and int(GLFWModAlt)) != 0:
                    window.setWindowShouldClose(true)
            of GLFWKey.F:
                frameStepping = not frameStepping
            of GLFWKey.Right:
#                mainScene.bodies[mainScene.bodies.high].velocity += Vec(x:2.0f, y:0.0f)
                mainScene.bodies[mainScene.bodies.high].angularVelocity += 1.0
            of GLFWKey.Left:
#                mainScene.bodies[mainScene.bodies.high].velocity -= Vec(x:2.0f, y:0.0f)
                mainScene.bodies[mainScene.bodies.high].angularVelocity -= 1.0
            of GLFWKey.Up:
                mainScene.bodies[mainScene.bodies.high].velocity += Vec(x:0.0f, y: -5.0f)
            of GLFWKey.Space:
                canStep = true
            else:
                discard

proc physicsLoop() =
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    # Continuous or single step
    if frameStepping == false:
        mainScene.step(FRAME_TIME)
    else:
        if canStep == true:
            canStep = false
            mainScene.step(FRAME_TIME)
    mainScene.render()

proc errorCallback(error: int32, description: cstring) {.cdecl.} =
    echo fmt("[ERROR LEVEL {error}]\n:  {description}")


proc main() =
    # Initialize GLFW
    if not glfwInit():
        raise newException(Exception, "GLFW failed to initialize!")
    # Initialize the main windowdow
    window = glfwCreateWindow(
        WINDOW_SIZE.w,
        WINDOW_SIZE.h,
        "Impulse Engine (Nim) Ver.:$1" % VERSION,
        nil,
        nil
    )
    if window == nil:
        raise newException(Exception, "Error creating GLFW window!")
    # Center windowdow to screen
    monitor = glfwGetPrimaryMonitor()
    videoMode = getVideoMode(monitor)
    window.setWindowPos(
        int32(videoMode.width/2 - WINDOW_SIZE.w/2),
        int32(videoMode.height/2 - WINDOW_SIZE.h/2)
    )
    
    # Set the CTRL+C hook that raises the done flag
    # (terminal windowdow has to be focused!)
    setControlCHook(proc() {.noconv.} = done = true)
    
    # Set callbacks
    discard glfwSetErrorCallback(errorCallback)
    discard setKeyCallback(window, keyCallback)
    discard setMouseButtonCallback(window, mouseCallback)
    
    # Set up context and openGL
    window.makeContextCurrent()
    initOpenGL()
    # Set the swap interval for the current context:
    #   0 - no syncing
    #   1 - syncs the window.update to 1 screen refresh
    when VSYNC == true:
        glfwSwapInterval(1)
    else:
        glfwSwapInterval(0)
    
    # Initialize static(immovable) objects in the scene
    var b: Body
    # Middle circle
    b = mainScene.add(centerCircle, 40.0f, 40.0)
    b.setStatic()
    # Bottom platform
    var poly: Polygon = newPolygon()
    poly.setBox(30.0f, 1.0f)
    b = mainScene.add(poly, 40.0f, 55.0f)
    b.setStatic()
    b.setOrient(0)
    # Left wall
    poly = newPolygon()
    poly.setBox(1.0f, 5.0f)
    b = mainScene.add(poly, 11.0f, 49.0f)
    b.setStatic()
    b.setOrient(0)
    # Right wall
    poly = newPolygon()
    poly.setBox(1.0f, 5.0f)
    b = mainScene.add(poly, 69.0f, 49.0f)
    b.setStatic()
    b.setOrient(0)
    
    displayString(1, 2, "Left click to spawn a polygon")
    displayString(1, 4, "Right click to spawn a circle")
    
    # Main loop
    while not done and not window.windowShouldClose:
        when VSYNC == true:
            ## This consumes 100% of one CPU core on Windows Vista, until another application
            ## needs more of the CPU (it seems to be a Windows driver issue). Once the
            ## CPU usage falls, it stays at the correct level!
            physicsLoop() # Impulse engine routine
        else:
            ## If someone knows a better delay mechanism,
            ## please contact me or open an issue on Github!
            glfwSetTime(0)
            physicsLoop() # Impulse engine routine
            # Delay for frame syncing
            var sleepTime = int(1000*(FRAME_TIME - glfwGetTime())) - 1
            if sleepTime > 0:
                os.sleep(sleepTime)
        # Strings
        renderStrings()
        # Update everything
        window.swapBuffers()
        glfwPollEvents()
    
    # Cleanup everything
    window.destroyWindow()
    glfwTerminate()
    echo "Application closed"

main()
