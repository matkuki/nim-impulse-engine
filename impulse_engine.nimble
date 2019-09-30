# Package
version = "1.6.0"
author = "Matic Kukovec"
description = "Nim port of a simple 2D physics engine"
license = "zlib"

# Deps
requires "nim >= 0.15.0"
requires "opengl >= 1.1.0"
requires "x11 >= 1.0"
requires "nimgl >= 1.0.0"

# Compile binary
bin = @["impulse_engine"]
