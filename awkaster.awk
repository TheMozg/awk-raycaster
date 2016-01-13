#Copyright (c) 2016 Fedor Kalugin
#MIT License

BEGIN {
  #USER SETTINGS
  #screen width and height, every "pixel" is 2 chars wide
  w=64
  h=48
  #default color mode, change at runtime by pressing 1-4
  #1 = no color, chars only, fast drawing
  #2 = colored chars
  #3 = background color only
  #4 = background color with char textures
  colormode = 4


  #INITIALIZATION
  srand()
  PROCINFO["sorted_in"] = "@ind_num_asc"
  buffer[w,h]
  ZBuffer[w]
  #ugly 2d array initialization
  sprite[0][0]
  delete sprite[0]

  reloadTimeLeft = 0;
  moveSpeed = 0.8
  rotSpeed = 0.4
  reloadTime = 10
  score = 0
  health = 100
  moves = 1001

  #initial player direction vector
  dirX = 0.0
  dirY = -1.0
  #camera plane perpendicular to direction vector
  planeX = -0.66
  planeY = 0.0


  #LEVEL DESIGN
  mapWidth=44
  mapHeight=44
  map =\
  "55555555566666666665555566666666655556666666"\
  "5........666.6.6.65.....6...66665....7666666"\
  "5.8.8.8.............88..6...66667.8..7.....6"\
  "5........66666.6.6888...6.7.6667..88.7.....6"\
  "5.8.8.8......6.6.6668..66.7.667......7.....6"\
  "5........555.666..668.....7.65...7555666.666"\
  "5.8.8.8..5.5.6667.766555557.67..75...666.666"\
  "5....5...5...667...766665...6..76677.666.666"\
  "555.5566.555.67.....76665.666..56667.66..666"\
  "668.8666.....67..8..76665.....766667.6...666"\
  "67...77666666667...766665....7666667....6666"\
  "67....7666666666555666666777..566667...66666"\
  "7......6777777777777777666665..56667..666666"\
  "7..77..5...............6666665..5667.6666666"\
  "67776..5...............66666665..767.6666666"\
  "6666...5..8.........8..666666665.567.6666666"\
  "6....8.5...............66666666...67..666666"\
  "6.66.8.5...............6666667.....7...66666"\
  "666....5.....33.33.....6666668...........666"\
  "66...665.....3...3.....6666667.....7576...66"\
  "6...6665.....3...3.....66666666...66666...66"\
  "6.666665.....3...3.....666666665.5655666.666"\
  "6.66...5.....33333.....6665666.5.55.5666.666"\
  "6.6....5...............655.556......5666.666"\
  "6.6....5...............6.....55...556666.666"\
  "6......5..8.........8..6..........66666...66"\
  "6555...5...............6.....66...566666.666"\
  "65.....5...............655.55666...56666.666"\
  "65.....56666668.8666666665.5666656566666.666"\
  "65...6666666668.8666666555.5555555566666.666"\
  "5...66666666668.8666666...........56666...66"\
  "7.7666666666668.8666666...........5666.....6"\
  "7.7666666666668.8666666............566.....6"\
  "7.7666666666668.8666666............566.....6"\
  "7.76........666.6666666............5666...66"\
  "7.76...88888666.666666655555.......56666.666"\
  "7.73...8...8666.6666666....5..............66"\
  "7..........8666.6666666....5.......56668.866"\
  "7773...8...8666.6666666....5.......5668...86"\
  "6676...88888666............3.......568.....8"\
  "6676........66666666665...........7668.....8"\
  "66666666666666666666665555537777776668.....8"\
  "666666666666666666666666666666666666668...86"\
  "66666666666666666666666666666666666666688866"

  ceilingTex = "=="
  ceilingColor = 1
  ceilingIsBright = 1

  floorTex = "__"
  floorColor = 4
  floorIsBright = 0

  monsterTex = "OOMMZZ[]FuLL"
  monsterColor = 2

  bulletTex = "**"
  bulletColor = 3
  bulletIsBright = 0

  wallTex="kkrrggyybbmmccww"

  #initial player position
  posX = 37.5
  posY = 9.5

  for (i=0; i < 25; i++)
    spawnMonster()


  #ENTERING MAIN LOOP
  main()


  #EXITING
  print "\n"
  if(health <= 0)
    print "GAME OVER! YOU LOSE!"
  else if (moves == -1)
    print "YOU WIN! YOUR SCORE: " score
  else
    print "You quit. Progress was not saved."

  print "Credits: Fedor 'TheMozg' Kalugin"
  print "https://github.com/TheMozg/awk-raycaster"
  print "Gameplay testing - Alex 'Yakojo' & Danya 'bogych97'"
  print "Go away!"
}

function addSprite(x,y, dX,dY, tex, color, isBright, type, uDiv, vDiv, vMove) {
  n = length(sprite)+1
  sprite[n]["dirX"]=dX
  sprite[n]["dirY"]=dY
  sprite[n]["posX"]=x
  sprite[n]["posY"]=y
  sprite[n]["tex"]=tex
  sprite[n]["color"]=color
  sprite[n]["isBright"]=isBright
  sprite[n]["type"]=type
  sprite[n]["vDiv"]=vDiv
  sprite[n]["uDiv"]=uDiv
  sprite[n]["vMove"]=vMove
}

function spawnMonster(){
  do{
    x = mapWidth*rand()
    y = mapHeight*rand()
  } while ((worldMap(x, y) != 0) || (distPP(x,y,posX,posY) < 10))
  isBright = int(2*rand())
  n = int(rand()*int(length(monsterTex)/2))+1
  tex = substr(monsterTex, n*2-1, 2)
  addSprite(x, y, dirX, dirY, tex, monsterColor, isBright, "monster", 1.0, 1.0, 0.0)
}

function shoot() {
  addSprite(posX, posY, dirX, dirY, bulletTex, bulletColor, bulletIsBright, "bullet", 3.0, 3.0, 0)
  n = length(sprite)
  moveSprite(n, 0.1)
}

function worldMap(y, x) {
  y = int(y)
  x = int(x)
  tile = substr(map, mapWidth*y+x+1, 1)
  if (tile == ".")
    return 0
  return tile
}

function abs(x) {
  if(x<0)
    return -x
  return x
}

function fillBackground(){
  for(x = 0; x < w; x++){
    for(y = 0; y < h/2; y++){
      buffer[x,y] = getPixel(ceilingColor, ceilingIsBright, colormode, ceilingTex);
    }
    for(y = int(h/2); y < h; y++){
      buffer[x,y] = getPixel(floorColor, floorIsBright, colormode, floorTex);
    }
  }
}

function redraw(){
  str = "\n\n\n\n\n\n"
  for(y = 0; y < h-2; y++){
    for(x = 0; x < w; x++){
      str = str buffer[x,y]
    }
    if(y < h-3)
      str = str "\n"
  }
  print str
  drawUI()
}

function drawUI(){
  if(colormode == 1 || colormode == 2){
    fg_color = getANSICode(0, 0, 0);
    bg_color = getANSICode(0, 0, 1);
  }
  if(colormode == 3 || colormode == 4){
    fg_color = getANSICode(8, 1, 0);
    bg_color = getANSICode(5, 0, 1);
  }
  help = "WASD - move, P - shoot, 1-4 - change color mode"
  if(inPosition())
    if (moves != 0)
      help = help ", WAIT FOR ELEVATOR"
    else
      help = help ", PRESS X TO WIN"
  else
    help = help ", find an elevator and press X"
  info = "ELEVATOR COMING " moves " | HP " health " | SCORE " score " | GUN "
  if(reloadTimeLeft == 0)
    info = info "READY"
  else
    info = info "RELOADING"
  while(length(help) < w*2)
    help = help " "
  while(length(info) < w*2)
    info = info " "
  text = buildPixel(bg_color, fg_color, help);
  print text
  text = buildPixel(bg_color, fg_color, info);
  print text
}


function getWallTex(color, isBright){
  tex = substr(wallTex, color*2-1, 2)
  if(isBright == 1)
    return toupper(tex)
  return tex
}

function getANSICode(color, isBright, isBG){
  if(color == 0)
    color = 10
  else if (isBright==1)
    color+=60
  if(isBG==1)
    color+=10
  color+=30-1
  return color
}

function buildPixel(bg_color, fg_color, text){
  pixel = "\033[" bg_color ";" fg_color "m" text "\033[0m";
  return pixel;
}

function getPixel(basecolor, isBright, colormode, tex){
  color = "??";

  if (colormode==1) {
    color = tex;
  }
  else if (colormode==2) {
    fg_color = getANSICode(basecolor, isBright, 0);
    bg_color = getANSICode(0, isBright, 1);
    color = buildPixel(bg_color, fg_color, tex);
  }
  else if (colormode==3) {
    tex = "  ";
    fg_color = getANSICode(0, isBright, 0);
    bg_color = getANSICode(basecolor, isBright, 1);
    color = buildPixel(bg_color, fg_color, tex);
  }
  else if (colormode==4){
    bg_color = getANSICode(basecolor, isBright, 1);
    if (isBright == 0)
      isBright = 1;
    else
      isBright = 0;
    fg_color = getANSICode(basecolor, isBright, 0);
    color = buildPixel(bg_color, fg_color, tex);
  }
  return color;
}

function distSP(i, x, y){
  return distPP(sprite[i]["posX"], sprite[i]["posY"], x, y)
}

function distSS(i, j){
  return distPP(sprite[i]["posX"], sprite[i]["posY"], sprite[j]["posX"], sprite[j]["posY"])
}

function distPP(x1, y1, x2, y2){
  return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
}


function inPosition(){
  if(posX <= 22 && posX >= 19.5 && posY >= 13 && posY <= 17)
    return 1
  return 0
}

function moveSprite(n, speed) {
  newPosX = sprite[n]["posX"]+sprite[n]["dirX"]*speed
  newPosY = sprite[n]["posY"]+sprite[n]["dirY"]*speed
  if(worldMap(newPosX,sprite[n]["posY"]) == 0)
    sprite[n]["posX"] = newPosX
  if(worldMap(sprite[n]["posX"],newPosY) == 0)
    sprite[n]["posY"] = newPosY
  return (worldMap(newPosX,newPosY) == 0)
}

function compareSprites(i1, v1, i2, v2){
  return (v2["dist"] - v1["dist"])
}

function main()
{
  while (1) {
    if(moves != 0)
      moves--
    if(reloadTimeLeft != 0)
      reloadTimeLeft--
    if(health <= 0)
      break;

    fillBackground();
    for(x = 0; x < w; x++)
    {
      #calculate ray position and direction
      cameraX = 2 * x / w - 1; #x-coordinate in camera space
      rayPosX = posX;
      rayPosY = posY;
      rayDirX = dirX + planeX * cameraX;
      rayDirY = dirY + planeY * cameraX;

      #which box of the map we're in
      mapX = int(rayPosX);
      mapY = int(rayPosY);

      #length of ray from current position to next x or y-side
      sideDistX=0.0;
      sideDistY=0.0;

      #length of ray from one x or y-side to next x or y-side
      if(rayDirX != 0)
        deltaDistX = sqrt(1 + (rayDirY * rayDirY) / (rayDirX * rayDirX));
      else
        deltaDistX=999999;

      if(rayDirY != 0)
        deltaDistY = sqrt(1 + (rayDirX * rayDirX) / (rayDirY * rayDirY));
      else
        deltaDistY=999999;

      perpWallDist=0.0;

      #what direction to step in x or y-direction (either +1 or -1)
      stepX=0;
      stepY=0;

      hit = 0; #was there a wall hit?
      side = 0; #was a NS or a EW wall hit?

      #calculate step and initial sideDist
      if (rayDirX < 0) {
        stepX = -1;
        sideDistX = (rayPosX - mapX) * deltaDistX;
      }
      else {
        stepX = 1;
        sideDistX = (mapX + 1.0 - rayPosX) * deltaDistX;
      }
      if (rayDirY < 0) {
        stepY = -1;
        sideDistY = (rayPosY - mapY) * deltaDistY;
      }
      else {
        stepY = 1;
        sideDistY = (mapY + 1.0 - rayPosY) * deltaDistY;
      }

      #perform DDA
      while (hit == 0) {
        #jump to next map square, OR in x-direction, OR in y-direction
        if (sideDistX < sideDistY) {
          sideDistX += deltaDistX;
          mapX += stepX;
          side = 0;
        }
        else{
          sideDistY += deltaDistY;
          mapY += stepY;
          side = 1;
        }
        #Check if ray has hit a wall
        if (worldMap(mapX,mapY) > 0)
          hit = 1;
      }

      #Calculate distance projected on camera direction
      if (side == 0)
        perpWallDist = abs( (mapX - rayPosX + int((1 - stepX) / 2)) / rayDirX);
      else
        perpWallDist = abs( (mapY - rayPosY + int((1 - stepY) / 2)) / rayDirY);

      #Calculate height of line to draw on screen
      if(perpWallDist == 0)
        lineHeight = h
      else
        lineHeight = abs(int(h / perpWallDist));

      #calculate lowest and highest pixel to fill in current stripe
      drawStart = int(int(h / 2)-int(lineHeight / 2) );
      if(drawStart < 0) drawStart = 0;
      drawEnd = int(lineHeight / 2 + h / 2);
      if(drawEnd >= h) drawEnd = h - 1;

      #choose wall color
      tex = getWallTex(worldMap(mapX,mapY), side);
      color = getPixel(worldMap(mapX,mapY), side, colormode, tex);

      #draw the pixels of the stripe as a vertical line
      for(y = drawStart; y <= drawEnd; y++) {
        buffer[x,y] = color
      }

      #set ZBuffer for sprite casting
      ZBuffer[x] = perpWallDist; #perpendicular distance is used
    }

    #sort sprites from far to close
    for(i in sprite) {
      sprite[i]["dist"] = distSP(i, posX, posY)
    }
    asort(sprite, sprite, "compareSprites")

    #after sorting the sprites, do the projection and draw them
    for(i in sprite)
    {
      #translate sprite position to relative to camera
      spriteX = sprite[i]["posX"] - posX;
      spriteY = sprite[i]["posY"] - posY;

      #transform sprite with the inverse camera matrix
      #required for correct matrix multiplication
      invDet = 1.0 / (planeX * dirY - dirX * planeY);

      transformX = invDet * (dirY * spriteX - dirX * spriteY);
      #this is actually the depth inside the screen, that what Z is in 3D
      transformY = invDet * (-planeY * spriteX + planeX * spriteY);

      spriteScreenX = int((w / 2) * (1 + transformX / transformY));

      #controls moving the sprite up or down
      vMoveScreen = int(sprite[i]["vMove"] / transformY);

      #calculate height of the sprite on screen
      #using "transformY" instead of the real distance prevents fisheye
      spriteHeight = abs(int((h / transformY) / sprite[i]["vDiv"]));
      #calculate lowest and highest pixel to fill in current stripe
      drawStartY = int(int(-spriteHeight/2) + h/2 + vMoveScreen);
      if(drawStartY < 0) drawStartY = 0;
      drawEndY = int(int(spriteHeight / 2) + h/2 + vMoveScreen);
      if(drawEndY >= h) drawEndY = h - 1;

      #calculate width of the sprite
      spriteWidth = abs(int((h /transformY) / sprite[i]["uDiv"]));
      drawStartX = int(spriteScreenX-int(spriteWidth / 2));
      if(drawStartX < 0) drawStartX = 0;
      drawEndX = int(int(spriteWidth / 2) + spriteScreenX);
      if(drawEndX >= w) drawEndX = w - 1;

      #loop through every vertical stripe of the sprite on screen
      for(stripe = drawStartX; stripe <= drawEndX; stripe++){
        if(transformY > 0 && stripe >= 0 && stripe < w && transformY < ZBuffer[stripe])
        for(y = drawStartY; y <= drawEndY; y++){ #for every pixel of the current stripe
          draw as circle
          if((stripe-spriteScreenX)*(stripe-spriteScreenX)+(y-h/2)*(y-h/2) <= spriteHeight*spriteHeight/4){
            pixel = getPixel(sprite[i]["color"], sprite[i]["isBright"], colormode, sprite[i]["tex"]);
            buffer[stripe,y] = pixel;
          }
        }
      }
    }
    redraw();

    system("stty -echo")
    cmd = "bash -c 'read -n 1 input; echo $input'"
    cmd | getline input
    close(cmd)
    system("stty echo")

    if (input == "w" || input == "s"){
      newPosX = posX - dirX * moveSpeed;
      newPosY = posY - dirY * moveSpeed;
      if (input == "w") {
        newPosX = posX + dirX * moveSpeed;
        newPosY = posY + dirY * moveSpeed;
      }
      ok = 1;
      for(i in sprite) {
        dist = distSP(i, newPosX, newPosY);
        if(dist < 0.51 && sprite[i]["type"] == "monster")
          ok = 0;
      }
      if(ok){
        if(worldMap(newPosX,posY) == 0) posX = newPosX;
        if(worldMap(posX,newPosY) == 0) posY = newPosY;
      }
    }
    if (input == "a" || input == "d"){
      rot = rotSpeed
      if (input == "d")
        rot = -rot
      #both camera direction and camera plane must be rotated
      oldDirX = dirX
      dirX = dirX * cos(rot) - dirY * sin(rot)
      dirY = oldDirX * sin(rot) + dirY * cos(rot)
      oldPlaneX = planeX
      planeX = planeX * cos(rot) - planeY * sin(rot)
      planeY = oldPlaneX * sin(rot) + planeY * cos(rot)
    }
    if((input == "p" || input == " ") && reloadTimeLeft == 0){
      shoot()
      reloadTimeLeft = reloadTime
    }
    if(input == "1")
      colormode = 1
    if(input == "2")
      colormode = 2
    if(input == "3")
      colormode = 3
    if(input == "4")
      colormode = 4
    if(input == "q")
      break
    if(input == "x" && moves == 0){
      moves = -1
      break
    }

    spawnCount = 0
    for(i in sprite){
      if(!(i in sprite))
        continue
      if (sprite[i]["type"] == "monster"){
        d = distSP(i, posX, posY)
        sprite[i]["dirX"] = (posX - sprite[i]["posX"]) / d
        sprite[i]["dirY"] = (posY - sprite[i]["posY"]) / d
        x = sprite[i]["posX"]+sprite[i]["dirX"]*0.5
        y = sprite[i]["posY"]+sprite[i]["dirY"]*0.5
        if(d > 0.7){
          #prevent clustering of monsters
          ok = 1
          for(j in sprite){
            if(!(j in sprite))
              continue
            if(sprite[j]["type"] == "monster" && i != j && distSP(j,x,y) < 1)
              ok = 0;
          }
          if(ok)
            moveSprite(i, 0.5)
        }
        else{
          health -= 10
          delete sprite[i]
          spawnCount++
        }
      }
    }

    for(i in sprite){
      if(!(i in sprite))
        continue
      if (sprite[i]["type"] == "bullet"){
        for(j in sprite){
          if(!(j in sprite))
            continue
          if (sprite[j]["type"] == "monster"){
            if(distSS(i,j) < 1){
              delete sprite[j]
              delete sprite[i]
              score += 100
              reloadTimeLeft = 0
              spawnCount++
              break
            }
          }
        }
        if(i in sprite)
          if(!moveSprite(i, 1.2))
            delete sprite[i]
      }
    }

    for (i=0; i < spawnCount*3; i++) {
      spawnMonster()
    }
  }
}
