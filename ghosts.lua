local function setTarget(val, x,y)
  val.targetX = x
  val.targetY = y
end

local function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

local frightAtlas = love.graphics.newImage('assets/img/fantomesPacman5.png')

local function getNextTile(val)
  local rndX, rndY = round(val.x), round(val.y) 
  if val.direction == "left" then
    return rndX -1, rndY
  elseif val.direction == 'right' then
    return rndX +1, rndY
  elseif val.direction == 'up' then 
    return rndX, rndY-1
  elseif val.direction == 'down' then 
    return rndX, rndY+1
  end
end

local function getNextTileObs(val)
  local nextX, nextY = getNextTile(val)
  return OBSTACLE[nextY][nextX]
end

local function getSurTile(x,y)
  return 
  {
    OBSTACLE[y-1][x],
    OBSTACLE[y][x+1],
    OBSTACLE[y+1][x],
    OBSTACLE[y][x-1],
  }
end

local function howManyExit(arr)
  local res = 0
  for i=1,4 do
    if(arr[i] == 0) then res = res + 1 end
  end
  return res
end

local function update(val, dt)
  
  if round(val.x) == val.nextX and round(val.y) == val.nextY then
    val.targetX, val.targetY = round(pacMan.x), round(pacMan.y)
    val.direction = val.nextDecision

    local nX, nY = getNextTile(val)
    local surObst = getSurTile(nX,nY)
    -- print(nX, nY)
    local dist = {}
    for i=1,#surObst do
      repeat
        if surObst[i] == 1 then break end -- == continue
        if i == 1 and val.direction == 'down' then break end
        if i == 2 and val.direction == 'left' then break end
        if i == 3 and val.direction == 'up' then break end
        if i == 4 and val.direction == 'right' then break end
        if i == 1 then
          table.insert(dist, { dist = math.abs(distance(val.targetX, val.targetY, nX, nY-1)), x=nX,y=nY-1, dir="up" })
        elseif i == 2 then
          table.insert(dist, { dist= math.abs(distance(val.targetX, val.targetY, nX+1, nY)), x=nX+1,y=nY, dir="right"})
        elseif i == 3 then
          table.insert(dist, { dist = math.abs(distance(val.targetX, val.targetY, nX, nY+1)), x=nX, y=nY+1, dir ="down"})
        elseif i == 4 then
          table.insert(dist, { dist = math.abs(distance(val.targetX, val.targetY, nX-1, nY)), x=nX-1, y=nY, dir="left"})
        end
      until true
    end
    table.sort(dist, function(a,b) return a.dist < b.dist end)
    val.nextX = nX
    val.nextY = nY
    val.nextDecision = dist[1].dir
  end

  if val.direction == 'left' or val.direction == 'right' then
    if val.y%1 ~= 0 then val.y = round(val.y)end
  elseif val.direction == 'up' or val.direction == 'down' then
    if val.x%1 ~= 0 then val.x = round(val.x)end
  end
  
  if val.direction == 'left' then
    val.dirX= -1
    val.dirY = 0
  elseif val.direction == 'right' then
    val.dirX= 1
    val.dirY = 0
  elseif val.direction == 'up' then
    val.dirX= 0
    val.dirY = -1
  elseif val.direction == 'down' then
      val.dirX= 0
      val.dirY = 1
  end
  val.x = val.x + dt * val.speed * val.speedCoef * val.dirX
  val.y = val.y + dt * val.speed * val.speedCoef * val.dirY

end



local function draw(val)
  love.graphics.draw(val[val.curAtlas], val.sprites[val.animDir][val.keyframe],
  (val.x-1)*BLOCKSIZE*PPM + BLOCKSIZE*PPM*0.5,
  (val.y-1)*BLOCKSIZE*PPM + BLOCKSIZE*PPM*0.5,
  val.angle,
  val.scaleSignX * PPM * 1.6,
  val.scaleSignY * PPM * 1.6,
  16*0.5,
  16*0.5)
  local r, g, b, a = love.graphics.getColor()
  -- print('rgba: '..r..', '..g..', '..b..', '..a)
  if DEBUG then 
    love.graphics.setColor(1,0,0,0.7)
    love.graphics.rectangle('fill',(val.targetX-1)*BLOCKSIZE*PPM , (val.targetY-1)*BLOCKSIZE*PPM, BLOCKSIZE*PPM, BLOCKSIZE*PPM)
    love.graphics.print('x: '..val.x..'; y: '..val.y, (VW*PPM)+10, 45)
    love.graphics.print('dir: '..val.direction, (VW*PPM)+10, 60)
    love.graphics.print('nextX: '..val.nextX..'; nextY: '..val.nextY, (VW*PPM)+10, 75)
    love.graphics.print('nextDecision: '..val.nextDecision, (VW*PPM)+10, 90)
    love.graphics.setColor(1,1,1,1)
  end
end


---------------------------------------------------------------------------
---------------------------------RED---------------------------------------

g_red = {
    startX=15, startY=12+3,
    x=15, y=12+3,
    timer = 0,
    speed = 8,

    dirX = 0,
    dirY = 0,
    direction = "right",
    animDir = "right",
    curAtlas = "atlas",
    keyframe=1,
    nbrFrame=2,
    fps=5,
    angle=0,
    scaleSignX= 1,
    scaleSignY= 1,
    state = "chase",
    targetX = 25,
    targetY = 1,
    speedCoef = 0.8,
    nextDecision = "right",
    nextX = 16,
    nextY = 12+3
  }
  g_red.animTimer = 1 /g_red.fps
  g_red.atlas= love.graphics.newImage('assets/img/fantomesPacman4.png')
  g_red.frightAtlas = frightAtlas
  g_red.sprites = {}
  g_red.sprites.right = {
    love.graphics.newQuad(4*16,0,16,16,g_red.atlas:getDimensions()),
    love.graphics.newQuad(1*16,0,16,16,g_red.atlas:getDimensions()),
  }
  g_red.sprites.down = {
    love.graphics.newQuad(2*16,0,16,16,g_red.atlas:getDimensions()),
    love.graphics.newQuad(1*16,0,16,16,g_red.atlas:getDimensions()),
  }
  g_red.sprites.left = {
    love.graphics.newQuad(4*16,0,16,16,g_red.atlas:getDimensions()),
    love.graphics.newQuad(1*16,0,16,16,g_red.atlas:getDimensions()),
  }
  g_red.sprites.up = {
    love.graphics.newQuad(6*16,0,16,16,g_red.atlas:getDimensions()),
    love.graphics.newQuad(1*16,0,16,16,g_red.atlas:getDimensions()),
  }
  g_red.sprites.fright = {
    love.graphics.newQuad(0*16,0,16,16,frightAtlas:getDimensions()),
    love.graphics.newQuad(1*16,0,16,16,frightAtlas:getDimensions()),
  }


g_red.draw = function(val)
  draw(val)
end

g_red.update = function(val, dt)
  update(val, dt)
end

g_red.setTarget = function(val, x,y)
  setTarget(val, x, y)
end

g_red.getNextTile = function(val)
  getNextTile(val)
end