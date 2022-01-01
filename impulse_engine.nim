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
    os,
    strutils,
    strformat,
    times,
    math,
    iemath,
    shapes,
    manifold,
    scene,
    glfw,
    glfw/wrapper,
    opengl,
    opengl/glu,
    textdraw,
    data

var 
    done = false # Application exit flag
    frameStepping = false
    canStep = false
    win: glfw.Window
    centerCircle = newCircle(5.0f)
    mainScene = newScene(5)
    videoMode: glfw.VideoMode
    bodyCounter: int = 0
    viewScale = 0.0
    adjustedWindowSize: tuple[w: float, h: float]


proc initOpenGL() = 
    loadExtensions()
    glMatrixMode(GL_PROJECTION)
    glPushMatrix()
    glLoadIdentity()
    gluOrtho2D(0, WINDOW_SIZE.w/10, WINDOW_SIZE.h/10, 0)
    glMatrixMode(GL_MODELVIEW)
    glPushMatrix()
    glLoadIdentity()

proc mouseButtonCallback(win: glfw.Window, 
                         button: MouseButton, 
                         pressed: bool,
                         modKeys: set[ModifierKey]) =
    # Get cursor position and adjust it to openGL settings
    var curPos = win.cursorPos()
    curPos.x /= 10.0f
    curPos.y /= 10.0f
    # Adjust position depending on the view scale
    let
        xRatio = adjustedWindowSize.w / WINDOW_SIZE.w.float
        yRatio = adjustedWindowSize.h / WINDOW_SIZE.h.float
    curPos.x *= xRatio
    curPos.y *= yRatio
    curPos.x += ((WINDOW_SIZE.w.float - adjustedWindowSize.w) / 2.0) / 10.0
    curPos.y += ((WINDOW_SIZE.h.float - adjustedWindowSize.h) / 2.0) / 10.0
    # Filter only mouse press events
    if pressed == true:
        case button:
            of mbLeft:
                if LEFT_CLICK_RANDOM_POLYGONS:
                    # Create random polygon
                    var
                        poly: Polygon = newPolygon()
                        count: int = int(iemath.random(3, MaxPolyVertexCount))
                        vertices: array[MaxPolyVertexCount, Vec]
                        e: float = iemath.random(5.0f, 10.0f)
                        b: Body
                    for i in 0..vertices.high:
                        vertices[i].set(iemath.random(-e, e), iemath.random(-e, e))
                    poly.set(vertices, count)
                    b = mainScene.add(poly, curPos.x, curPos.y)
                    b.setOrient(iemath.random(-iemath.PI, iemath.PI))
                    b.restitution = 0.2f
                    b.dynamicFriction = 0.2f
                    b.staticFriction = 0.4f
                else:
                    # Create symetric rectangles
                    var
                        poly: Polygon = newPolygon()
                        vertices: array[4, Vec]
                        e: float = 3.0f
                        b: Body
                    vertices[0].set(-e, -e)
                    vertices[1].set(e, -e)
                    vertices[2].set(e, e)
                    vertices[3].set(-e, e)
                    poly.set(vertices, vertices.len())
                    b = mainScene.add(poly, curPos.x, curPos.y)
                    b.setOrient(0.0) #(iemath.random(-iemath.PI, iemath.PI))
                    b.restitution = 0.9 #0.2f
                    b.dynamicFriction = 0.9 #0.2f
                    b.staticFriction = 0.9 #0.4f
                bodycounter += 1
        
            of mbRight:
                # Create random circle
                var
                    c: Circle = newCircle(iemath.random(1.0f, 3.0f))
                discard mainScene.add(c, curPos.x, curPos.y)
                bodycounter += 1
            
            else:
                discard

proc setScale(newOffset: float) =
    # Set the scale
    viewScale -= newOffset
    if viewScale < -200:
        viewScale = -200

proc setView() =
    const ratio = float(WINDOW_SIZE.w / WINDOW_SIZE.h)
    var offset: Vec
    offset.x = viewScale * 10 * ratio
    offset.y = viewScale * 10
    # Reinitialize the viewport
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
#    glViewport(-int32(offset.x/2), -int32(offset.y/2), int32(WINDOW_SIZE.w.float + offset.x), int32(WINDOW_SIZE.h.float + offset.y))
#    glOrtho(-offset.x, WINDOW_SIZE.w.float+offset.x, WINDOW_SIZE.h.float+offset.y, -offset.y, 0.0f, 1.0f)
    
    if viewScale > 0:
        glViewport(-int32(offset.x/2), -int32(offset.y/2), int32(WINDOW_SIZE.w.float + offset.x), int32(WINDOW_SIZE.h.float + offset.y))
        glOrtho(0, WINDOW_SIZE.w.float, WINDOW_SIZE.h.float, 0, viewScale, -1.0f)
        adjustedWindowSize = (
            w: (WINDOW_SIZE.w.float),
            h: (WINDOW_SIZE.h.float),
        )
    else:
        var
            x = -offset.x
            y = -offset.y
            wx = -offset.x
            hy = -offset.y
        glViewport(0, 0, WINDOW_SIZE.w.int32, WINDOW_SIZE.h.int32)
        glOrtho(-x, WINDOW_SIZE.w.float+wx, WINDOW_SIZE.h.float+hy, -y, 0.0f, 1.0f)
        adjustedWindowSize = (
            w: (x + WINDOW_SIZE.w.float+wx),
            h: (y + WINDOW_SIZE.h.float+hy),
        )

proc scrollCallback(win: glfw.Window,
                    pos: tuple[x: float64, y: float64]) =
    setScale(pos.y)

proc keyCallback(win: glfw.Window,
                 key: Key,
                 scanCode: int32, 
                 action: KeyAction,
                 modKeys: set[ModifierKey]) =
    # Filter only keyUp events
    if action != kaUp:
        case key:
            of keyEscape:
                win.shouldClose = true
            
            of keyF4:
                if mkAlt in modKeys:
                    win.shouldClose = true
            
            of keyF:
                frameStepping = not frameStepping
            
            of keyR:
                viewScale = 0.0
                setView()
            
            of keyRight:
                mainScene.bodies[mainScene.bodies.high].velocity += Vec(x:2.0f, y:0.0f)
            
            of keyLeft:
                mainScene.bodies[mainScene.bodies.high].velocity -= Vec(x:2.0f, y:0.0f)
            
            of keyUp:
                mainScene.bodies[mainScene.bodies.high].velocity += Vec(x:0.0f, y: -5.0f)
            
            of keySpace:
                canStep = true
            
            else:
                discard

proc initView() =
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    glOrtho(0, WINDOW_SIZE.w.float, WINDOW_SIZE.h.float, 0.0, 0.0f, 1.0f)
    glViewport(0, 0, WINDOW_SIZE.w.int32, WINDOW_SIZE.h.int32)

proc physicsLoop() =
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    setView()
    
    # Continuous or single step
    if frameStepping == false:
        mainScene.step(FRAME_TIME)
    else:
        if canStep == true:
            canStep = false
            mainScene.step(FRAME_TIME)
    mainScene.render()

proc textLoop() =
    let text_list = [
        fmt"Total number of bodies: {bodycounter}",
        fmt"View-scaling: {viewScale}",
        "Left-click to spawn a polygon",
        "Right-click to spawn a circle",
        "Mouse-wheel to change perspective",
        "R to reset perspective",
        "Esc to quit",
    ]
    textdraw.draw_text(
        text_list.join("\n"),
        Vec(x: 10, y: 10),
        createColor("#7070cb")
    )

proc main() =
    # Initialize GLFW
    glfw.initialize()
    # Initialize text drawing
    textdraw.init()
    # Initialize the main window
    var window_options = DefaultOpenglWindowConfig
    window_options.size = (w: WINDOW_SIZE.w, h: WINDOW_SIZE.h)
    window_options.title = "Impulse Engine (Nim) Ver.:$1" % VERSION
    window_options.fullscreenMonitor = NoMonitor # No monitor specified; don't go fullscreen.
    window_options.shareResourcesWith = glfw.Window(nil) # Don't share resources.
    window_options.visible = true
    window_options.decorated = true
    window_options.resizable = false
    window_options.stereo = false
    window_options.srgbCapableFramebuffer = false
    window_options.bits = (r: 8, g: 8, b: 8, a: 8, stencil: 8, depth: 24)
    window_options.accumBufferBits = (r: 0, g: 0, b: 0, a: 0)
    window_options.nAuxBuffers = 0
    window_options.nMultiSamples = 0
    window_options.refreshRate = some(FRAME_RATE) # 0 - use the current monitor refresh rate.
    window_options.version = glv30
    window_options.forwardCompat = false
    window_options.debugContext = false
    win = newWindow(window_options)
    # Center window to screen
    videoMode = glfw.getPrimaryMonitor().videoMode
    win.pos = (
        x: int(videoMode.size.w/2 - WINDOW_SIZE.w/2),
        y: int(videoMode.size.h/2 - WINDOW_SIZE.h/2)
    )
    
    # Set the CTRL+C hook that raises the done flag
    # (terminal window has to be focused!)
    setControlCHook(proc() {.noconv.} = done = true)
    
    # Set up event handlers, context and openGL
    win.mouseButtonCb = mouseButtonCallback
    win.keyCb = keyCallback
    win.scrollCb = scrollCallback
    win.makeContextCurrent()
    initOpenGL()
    # Set the swap interval for the current context:
    #   0 - no syncing
    #   1 - syncs the win.update to 1 screen refresh
    when VSYNC == true:
        glfw.swapInterval(1)
    else:
        glfw.swapInterval(0)
    
    # Initialize view
    initView()
    
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
    
    # Main loop
    while not done and not win.shouldClose:
    #    if mainScene.bodies.len() > 0:
    #        echo mainScene.bodies[mainScene.bodies.high].position, "  ", mainScene.bodies[mainScene.bodies.high].velocity
        when VSYNC == true:
            ## This consumes 100% of one CPU core on Windows OS, until another application
            ## needs more of the CPU (it seems to be a Windows driver issue). Once the
            ## CPU usage falls, it stays at the correct level!
            # Impulse engine routine
            physicsLoop()
            # Draw diagnostic text
            textLoop()
            # Buffer swap + event poll.
            win.swapBuffers()
            glfw.pollEvents()
        else:
            ## If someone knows a better delay mechanism,
            ## please contact me or open an issue on Github!
            glfw.setTime(0)
            # Impulse engine routine
            physicsLoop()
            # Draw diagnostic text
            textLoop()
            # Buffer swap + event poll.
            win.swapBuffers()
            glfw.pollEvents()
            # Delay for frame syncing
            var sleepTime = int(1000*(FRAME_TIME - glfw.getTime())) - 1
            if sleepTime > 0:
                os.sleep(sleepTime)
        
    # Cleanup everything
    win.destroy()
    glfw.terminate()
    echo "Application closed"


if isMainModule:
    main()