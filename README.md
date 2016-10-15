# Impulse Engine (Nim port)
### Descripton: ###
Nim programming language port of Randy Gaul's Impulse engine (https://github.com/RandyGaul/ImpulseEngine).<br>
Thanks to Randy for a great educational tool.
<br><br>
### License: ###
zlib license (check the License.txt file for more details)
<br><br>
### Used libraries: ###
- nim-glfw (https://github.com/ephja/nim-glfw - thanks to ephja for glfw support and troubleshooting)
- opengl (https://github.com/nim-lang/opengl)
- x11 (https://github.com/nim-lang/x11)
<br><br>

### Installation: ###
[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://github.com/yglukhov/nimble-tag)
<br>
Installation can be done using the Nimble package manager from the shell/command line (Nimble has to be installed):
```sh 
$ nimble install impulse_engine
```
<br>

### Compilation: ###

Run the following command in the shell/command line:
```sh 
$ nim c impulse_engine.nim
```
On Windows (tested with mingw64-32) it should work out of the box, provided you have everything needed for openGL.<br>
On GNU/Linux (tested on Lubuntu) you will probably need to install libmesa, Xcursor and other X development packages, and
I also had to create symlinks for libGL.so, libXi.so and libXxf86v.so.<br>
If anyone is willing to try it on another platform, any feedback would be greatly appreciated.<br><br>

#### Screenshot: ####
<img src="https://github.com/matkuki/Nim-Impulse-Engine/blob/master/screenshot.jpg" align="top" width="600" height="480">
### Video: ###
https://www.youtube.com/watch?v=AzA_owsZU04
