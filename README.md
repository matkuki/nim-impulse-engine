# Impulse Engine (Nim port)
### Descripton: ###
Nim programming language port of Randy Gaul's Impulse engine (https://github.com/RandyGaul/ImpulseEngine).<br>
Thanks to Randy for a great educational tool.
<br><br>
### License: ###
zlib license (check the License.txt file for more details)
<br><br>
### Used libraries (included in the source) ###
- nim-glfw (https://github.com/ephja/nim-glfw - thanks to ephja for glfw support and troubleshooting)
- opengl (https://github.com/nim-lang/opengl)
- x11 (https://github.com/nim-lang/x11)
<br><br>

### Compilation: ###

Run the following command in the shell/command line:
```sh 
$ nim c impulse_engine.nim
```
On Windows (tested with mingw64-32) it should work out of the box, provided you have everything needed for openGL.<br>
On GNU/Linux (tested on Lubuntu) you will probably need to install libmesa, Xcursor, ... development packages and
I also had to create symlinks for libGL.so, libXi.so and libXxf86v.so.
