# awkaster
Bring some old-school fun to your terminal! Explore the dungeon and shoot monsters in this pseudo-3D game inspired by the classic Wolfenstein 3D and Doom.

![Screenshot](screenshot.png)

#Running the game
`gawk -f awkaster.awk`

You need `gawk` version >= `4.0.0`


OS X users must install `gawk` first. The easiest way to do this is to use [Homebrew](http://brew.sh/). Once it has been installed, run the following commands:
```
brew update
brew install gawk
```

NetBSD users require `gawk`. The easiest way to do it is install it with [pkgin](http://pkgin.net):
```
pkgin install gawk
```

Alternatively install from sources using the [pkgsrc framework](https://pkgsrc.org/):
```
cd /usr/pkgsrc/lang/gawk && make install
```

Your machine will now be ready to run *awkaster*.

#How to play
Your objective is to navigate the map and activate exit elevator, killing hoards of monsters in the process.

Controls:
* WASD - movement
* J/L - turn left/right. Hold shift to turn quicker
* spacebar - shoot
* num 1-4 - change color mode
* x - activate elevator (arrives after 1000 moves)

#Adjusting resolution
By default game resolution is 64x48 "pixels", which are just a pair of ASCII symbols. That means your terminal needs to be at least 128 chars wide. You may change variables `w` and `h` to your liking.

#Game engine
Wall rendering is done using ray casting. Monsters and projectiles are added after that as sprites.
Ray casting is a simple rendering algorithm that doesn't require any 3d modeling or complex computation.

You can find an excellent tutorial here:
http://lodev.org/cgtutor/raycasting.html
