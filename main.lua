require "rooms"

gfx = love.graphics

--- Data

game_state = "play"

zoom = 10
speed = 1

-- Declarations

local player
local current_room
local prev_room

-- Constants

MIASMA_SPREAD_CHANCE = 0.1
MAGNET_LINE_TIME = 6
MAX_VELOCITY = 30

-- Colors

BLACK = { 0, 0, 0 }
WHITE = { 255, 255, 255 }
MIASMA = { 55, 0, 55 }

FLOOR_SAND = { 210, 180, 140 }

WALL_SAND = { 110, 80, 40 }

DRAWING_SAND = { 180, 140, 110 }

RED_MAGNET = { 205, 0, 0 }
RED_MAGNET_EDGE = { 145, 0, 0 }
ORANGE_WARP = { 215, 120, 0 }
YELLOW_TORCH = { 205, 205, 0 }
GREEN_WHIRLWIND = { 0, 205, 0 }
BLUE_BOMB = { 50, 50, 255 }
VIOLET_SWORD = { 215, 10, 125 }

--- Utility

function mergeColor( orig, diff, a )
   local a_orig = 1.0 - a
   return {
      math.floor((orig[1] * a_orig) + (diff[1] * a)),
      math.floor((orig[2] * a_orig) + (diff[2] * a)),
      math.floor((orig[3] * a_orig) + (diff[3] * a))
   }
end

function translateRotate( dx, dy, direction )
   gfx.translate( dx, dy )
   if direction == 'right' then gfx.rotate( math.pi / 2 ) end
   if direction == 'down' then gfx.rotate( math.pi ) end
   if direction == 'left' then gfx.rotate( -math.pi / 2 ) end
end

function deTranslateRotate( dx, dy, direction )
   if direction == 'right' then gfx.rotate( -math.pi / 2 ) end
   if direction == 'down' then gfx.rotate( math.pi ) end
   if direction == 'left' then gfx.rotate( math.pi / 2 ) end
   gfx.translate( -dx, -dy )
end

--- Window

function setZoom( z )
   if z < 1 or z > 30 then
      return
   end

   zoom = z
   love.window.setMode( 64*z, 64*z )
end

--- Objects

function moveObject( object, dx, dy )
   local new_x = object.x + dx
   local new_y = object.y + dy

   -- Check collisions
   local take_back = false
   if objectStaticCollisions( object, new_x, new_y ) then take_back = true end

   if not take_back then
      -- TODO Update grid
      for x=object.x,object.x+object.width-1 do
         for y=object.y,object.y+object.height-1 do
            current_room.grid[x][y].obj = nil
         end
      end
      object.x = new_x
      object.y = new_y
      for x=object.x,object.x+object.width-1 do
         for y=object.y,object.y+object.height-1 do
            current_room.grid[x][y].obj = object
         end
      end

      return true
   else
      return false
   end
end

function drawObjects()
   for _,object in ipairs(current_room.objects) do

      if object.class == "block" then
         if object.color == "red" then gfx.setColor( RED_MAGNET ) end

         gfx.rectangle( "fill", object.x, object.y, object.width, object.height )

         if object.color == "red" then gfx.setColor( RED_MAGNET_EDGE ) end

         gfx.rectangle( "line", object.x+1, object.y+1, object.width-1, object.height-1 )
      end
   end
end

--- Room

function loadNewRoom( name )
   if prev_room ~= nil and prev_room.name == name and not prev_room.regenerate then
      local temp = prev_room
      prev_room = current_room
      current_room = temp
   elseif roomDatabase[name] ~= nil then
      prev_room = current_room
      current_room = generateRoom( roomDatabase[name] )
   end
   current_room.name = name
   player.warppoint = nil
end

function generateRoom( input )
   local room = { width = input.width, height = input.height, 
                  active = input.active, 
                  regenerate = input.regenerate, 
                  objects = { },
                  camera = { 0, 0 } }
   
   if input.custom_grid then
      room.grid = input.custom_grid
   else
      -- Grid setup
      room.grid = {}
      for i=0,room.width-1 do
         room.grid[i] = {}
         for j=0,room.height-1 do
            room.grid[i][j] = { nil }
         end
      end

      -- Base Walls
      for i=0,room.width-1 do
         room.grid[i][0] = { 'wall' }
         room.grid[i][1] = { 'wall' }
         room.grid[i][room.height-1] = { 'wall' }
         room.grid[i][room.height-2] = { 'wall' }
      end
      for j=0,room.height-1 do
         room.grid[0][j] = { 'wall' }
         room.grid[1][j] = { 'wall' }
         room.grid[room.height-1][j] = { 'wall' }
         room.grid[room.height-2][j] = { 'wall' }
      end

      if input.doors then
         for _,door in ipairs(input.doors) do
            if door.side == 'up' then
               for i=door.start,door.finish do
                  room.grid[i][0] = { 'door', door.side, door.to }
                  room.grid[i][1] = { nil }
               end
            elseif door.side == 'down' then
               for i=door.start,door.finish do
                  room.grid[i][room.height-1] = { 'door', door.side, door.to }
                  room.grid[i][room.height-2] = { nil }
               end
            elseif door.side == 'right' then
               for j=door.start,door.finish do
                  room.grid[room.width-1][j] = { 'door', door.side, door.to }
                  room.grid[room.width-2][j] = { nil }
               end
            elseif door.side == 'left' then
               for j=door.start,door.finish do
                  room.grid[0][j] = { 'door', door.side, door.to }
                  room.grid[1][j] = { nil }
               end
            end
         end
      end

      if input.floor then
         for _,geometry in ipairs(input.floor) do

            if geometry.style == 'line' then
               local cur = {}
               cur.x = geometry.start.x
               cur.y = geometry.start.y
               room.grid[cur.x][cur.y] = { geometry.mark }
               for _,move in ipairs(geometry.moves) do
                  local dx = 0
                  local dy = 0
                  if move.dir == "left" then dx = -1
                  elseif move.dir == "right" then dx = 1
                  elseif move.dir == "up" then dy = -1
                  elseif move.dir == "down" then dy = 1 end

                  for i=1,move.dist do
                     cur.x = cur.x + dx
                     cur.y = cur.y + dy
                     room.grid[cur.x][cur.y] = { geometry.mark }
                  end
               end
            end

            if geometry.style == "points" then
               for _,point in ipairs(geometry.points) do
                  room.grid[point.x][point.y] = { geometry.mark }
               end
            end

         end

         if input.objects then
            for _,object in ipairs(input.objects) do

               if object.class == "miasma" then
                  for x=object.x,object.x+object.width-1 do
                     for y=object.y,object.y+object.height-1 do
                        room.grid[x][y] = { "miasma" }
                     end
                  end
               end

               if object.class == "block" then
                  table.insert(room.objects, object )
                  for x=object.x,object.x+object.width-1 do
                     for y=object.y,object.y+object.height-1 do
                        room.grid[x][y].obj = object
                     end
                  end
               end

            end
         end
      end
   end

   return room
end

function updateRoom()

   for i=0,current_room.width-1 do
      for j=0,current_room.height-1 do
         if current_room.grid[i][j][1] == 'miasma' then 
            -- Chance to spread
            if math.random() < MIASMA_SPREAD_CHANCE then
               -- select direction
               -- if not wall/edge, change to miasma
               local x = i
               local y = j
               local r_dir = math.random(4)
               if r_dir == 1 then x = x - 1
               elseif r_dir == 2 then x = x + 1
               elseif r_dir == 3 then y = y - 1
               elseif r_dir == 4 then y = y + 1 end

               if x >= 0 and x < current_room.width and y >= 0 and y < current_room.height then
                  if current_room.grid[x][y][1] ~= 'wall' then 
                     current_room.grid[x][y] = { "miasma" }
                  end
               end
            end
         end
      end
   end

   -- Objects
   if player.state == "magnet" and not player.magnet_target then
      getMagnetTarget()
   end

   if player.magnet_target then
      local mt = player.magnet_target
      -- Apply magnet force

      if (player.facing == "down" and player.magnet_pull) or (player.facing == "up" and not player.magnet_pull) then mt.velocity.y = mt.velocity.y + 1 end
      if (player.facing == "up" and player.magnet_pull) or (player.facing == "down" and not player.magnet_pull) then mt.velocity.y = mt.velocity.y - 1 end
      if (player.facing == "right" and player.magnet_pull) or (player.facing == "left" and not player.magnet_pull) then mt.velocity.x = mt.velocity.x + 1 end
      if (player.facing == "left" and player.magnet_pull) or (player.facing == "right" and not player.magnet_pull) then mt.velocity.x = mt.velocity.x - 1 end

   end

   for _,object in ipairs(current_room.objects) do

      if object.class == "chain" then
         -- Pull the attached object towards the origin

      end

      if object.class == "block" then

         if object.velocity then
            local vel = object.velocity

            if vel.x > MAX_VELOCITY then vel.x = MAX_VELOCITY end
            if vel.x < -MAX_VELOCITY then vel.x = -MAX_VELOCITY end
            if vel.y > MAX_VELOCITY then vel.y = MAX_VELOCITY end
            if vel.y < -MAX_VELOCITY then vel.y = -MAX_VELOCITY end

            if vel.x ~= 0 then
               object.x_move_ticks = object.x_move_ticks + 1
               if object.x_move_ticks >= math.floor(60 / math.abs(vel.x)) then
                  object.x_move_ticks = 0
                  
                  -- Try to move
                  if (vel.x > 0) then
                     if (moveObject( object, 1, 0 )) then
                        -- success
                        vel.x = vel.x - 1
                     else 
                        -- collision TODO sound effect
                        vel.x = 0
                     end
                  end
                  if (vel.x < 0) then
                     if (moveObject( object, -1, 0 )) then
                        -- success
                        vel.x = vel.x + 1
                     else 
                        -- collision TODO sound effect
                        vel.x = 0
                     end
                  end
               end
            end

            if vel.y ~= 0 then
               object.y_move_ticks = object.y_move_ticks + 1
               if object.y_move_ticks >= math.floor(60 / math.abs(vel.y)) then
                  object.y_move_ticks = 0
                  
                  -- Try to move
                  if (vel.y > 0) then
                     if (moveObject( object, 0, 1 )) then
                        -- success
                        vel.y = vel.y - 1
                     else 
                        -- collision TODO sound effect
                        vel.y = 0
                     end
                  end
                  if (vel.y < 0) then
                     if (moveObject( object, 0, -1 )) then
                        -- success
                        vel.y = vel.y + 1
                     else 
                        -- collision TODO sound effect
                        vel.y = 0
                     end
                  end
               end
            end
         end
      end 
      
      if object.class == "" then
      end
   end

end

function drawRoom()

   gfx.setBackgroundColor( FLOOR_SAND )
   gfx.clear()

   -- Static stuff
   for i=0,current_room.width-1 do
      for j=0,current_room.height-1 do

         -- Top level stuff
         if current_room.grid[i][j][1] == 'miasma' then 
            gfx.setColor( MIASMA )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 

         -- Mid level stuff

         -- Underneath stuff
         elseif current_room.grid[i][j][1] == 'wall' then 
            gfx.setColor( WALL_SAND )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         elseif current_room.grid[i][j][1] == 'door' then 
            gfx.setColor( FLOOR_SAND )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         elseif current_room.grid[i][j][1] == 'hole' then 
            gfx.setColor( BLACK )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         elseif current_room.grid[i][j][1] == 'drawing' then 
            gfx.setColor( DRAWING_SAND )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         end

      end
   end
end

--- Player

function initPlayer()
   player = { x = 2, y = 31, facing = 'down',
                    color = 0, 
                    state = "normal",
                    anim_timer = 0,
                    magnet_pull = false,
                    unlocked = { } }
   player_start = { 2, 31 }
   player.unlocked[0] = true
   player.unlocked[1] = true
   player.unlocked[2] = true
   player.unlocked[3] = true
   player.unlocked[4] = true
   player.unlocked[5] = true
   player.unlocked[6] = true
end

function movePlayer( dx, dy )
   local new_x = player.x + dx
   local new_y = player.y + dy

   -- Check collisions
   local take_back = false
   if playerStaticCollisions( new_x, new_y ) then take_back = true end

   if not take_back then
      player.x = new_x
      player.y = new_y
      return true
   else
      return false
   end
end

function movePlayerTo( x, y )
   local new_x = x
   local new_y = y

   -- Check collisions
   local take_back = false
   if playerStaticCollisions( new_x, new_y ) then take_back = true end

   if not take_back then
      player.x = new_x
      player.y = new_y
      return true
   else
      return false
   end

end

function changeColor( change )
   if change == 'left' then
      player.color = player.color - 1
      if player.color <= 0 then player.color = 6 end
      while player.unlocked[player.color] == nil do
         player.color = player.color - 1
         if player.color <= 0 then player.color = 6 end
      end 
   elseif change == 'right' then
      player.color = player.color + 1
      if player.color >= 7 then player.color = 1 end
      while player.unlocked[player.color] == nil do
         player.color = player.color + 1
         if player.color >= 7 then player.color = 1 end
      end
   else
      if player.unlocked[change] ~= nil then
         player.color = change
      end
   end
end

function getMagnetTarget()
   if player.facing == "left" or player.facing == "right" then
      local x = player.x
      local dx = -1
      local end_x = 2
      if player.facing == "right" then
         x = x + 2
         dx = 1
         end_x = current_room.height - 3
      end

      while x ~= end_x and not player.magnet_target do
         x = x + dx
         for y=player.y,player.y+2 do
            local obj = current_room.grid[x][y].obj
            if obj and obj.magnetic then -- TODO Multicolor
               player.magnet_target = current_room.grid[x][y].obj
               if not player.magnet_target.velocity then
                  player.magnet_target.velocity = { x=0, y=0 }
               end
               player.magnet_target.test = "fail"
               player.magnet_target.x_move_ticks = 0
               player.magnet_target.y_move_ticks = 0
               break
            end
         end
      end

   elseif player.facing == "up" or player.facing == "down" then
      local y = player.y
      local dy = -1
      local end_y = 2
      if player.facing == "down" then
         y = y + 2
         dy = 1
         end_y = current_room.height - 3
      end

      while y ~= end_y and not player.magnet_target do
         y = y + dy
         for x=player.x,player.x+2 do
            local obj = current_room.grid[x][y].obj
            if obj and obj.magnetic then -- TODO Multicolor
               player.magnet_target = current_room.grid[x][y].obj
               if not player.magnet_target.velocity then
                  player.magnet_target.velocity = { x=0, y=0 }
               end
               player.magnet_target.test = "fail"
               player.magnet_target.x_move_ticks = 0
               player.magnet_target.y_move_ticks = 0
               break
            end
         end
      end
   end
end

function playerActionOn()
   player.anim_timer = 0
   if player.color == 1 then
      player.state = "magnet"
      player.magnet_pull = not player.magnet_pull

      getMagnetTarget()

   elseif player.color == 2 then
      if player.warppoint then
         movePlayerTo( player.warppoint[1], player.warppoint[2] )
         player.warppoint = nil
      else
         player.warppoint = { player.x, player.y }
      end

   elseif player.color == 3 then
      -- TODO light mechanics
   elseif player.color == 4 then
      -- Launch wind or control wind
   elseif player.color == 5 then
      -- Lay bomb or kick bomb
   elseif player.color == 6 then
      -- Sword attack
   end
end

function playerActionOff()
   if player.color == 1 then
      player.state = "normal"
      player.magnet_target = nil

   elseif player.color == 3 then
   elseif player.color == 4 then
   elseif player.color == 5 then
   elseif player.color == 6 then
   end

end

function drawPlayer()
   -- Draw stuff as if facing up, and use rotate
   translateRotate( player.x + 1.5, player.y + 1.5, player.facing )

   gfx.setColor( BLACK )
   gfx.rectangle( 'fill', -1.5, -1.5, 3, 3 )

   if player.color == 1 then
      gfx.setColor( RED_MAGNET )
      gfx.rectangle( 'fill', -1.5, -1.5, 1, 2 )
      gfx.rectangle( 'fill', -0.5, -0.5, 1, 1 )
      gfx.rectangle( 'fill', 0.5, -1.5, 1, 2 )
   end
   if player.color == 2 then
      gfx.setColor( ORANGE_WARP )
      gfx.rectangle( 'fill', -1.5, -1.5, 1, 1 )
      gfx.rectangle( 'fill', -0.5, -0.5, 1, 1 )
      gfx.rectangle( 'fill', 0.5, 0.5, 1, 1 )
      gfx.rectangle( 'fill', 0.5, -1.5, 1, 1 )
      gfx.rectangle( 'fill', -1.5, 0.5, 1, 1 )
   end
   if player.color == 3 then
      gfx.setColor( YELLOW_TORCH )
      gfx.rectangle( 'fill', -0.5, -0.5, 1, 1 )
   end
   if player.color == 4 then
      gfx.setColor( GREEN_WHIRLWIND )
      gfx.rectangle( 'fill', -0.5, -1.5, 2, 1 )
      gfx.rectangle( 'fill', -0.5, -0.5, 1, 1 )
   end
   if player.color == 5 then
      gfx.setColor( BLUE_BOMB )
      gfx.rectangle( 'fill', -1.5, -0.5, 3, 1 )
      gfx.rectangle( 'fill', -0.5, -1.5, 1, 3 )
   end
   if player.color == 6 then
      gfx.setColor( VIOLET_SWORD )
      gfx.rectangle( 'fill', -0.5, -1.5, 1, 2 )
   end

   -- Effects
   if player.state == "magnet" then
      player.anim_timer = player.anim_timer + 1
      if player.anim_timer > MAGNET_LINE_TIME * 4 then player.anim_timer = 0 end

      local y = -2.5
      if player.magnet_pull then
         if player.anim_timer > MAGNET_LINE_TIME * 3 then y = -5.5
         elseif player.anim_timer > MAGNET_LINE_TIME * 2 then y = -4.5
         elseif player.anim_timer > MAGNET_LINE_TIME then y = -3.5 end
         gfx.setColor( RED_MAGNET )
         gfx.rectangle( 'fill', -1.5, y, 3, 1 )
         gfx.rectangle( 'fill', -2.5, y+1, 1, 1 )
         gfx.rectangle( 'fill', 1.5, y+1, 1, 1 )

         gfx.rectangle( 'fill', -1.5, y-4, 3, 1 )
         gfx.rectangle( 'fill', -2.5, y-3, 1, 1 )
         gfx.rectangle( 'fill', 1.5, y-3, 1, 1 )

         gfx.rectangle( 'fill', -1.5, y-8, 3, 1 )
         gfx.rectangle( 'fill', -2.5, y-7, 1, 1 )
         gfx.rectangle( 'fill', 1.5, y-7, 1, 1 )

      else
         if player.anim_timer > MAGNET_LINE_TIME * 3 then y = -3.5
         elseif player.anim_timer > MAGNET_LINE_TIME * 2 then y = -4.5
         elseif player.anim_timer > MAGNET_LINE_TIME then y = -5.5 end
         gfx.setColor( RED_MAGNET )
         gfx.rectangle( 'fill', -1.5, y, 3, 1 )
         gfx.rectangle( 'fill', -1.5, y-4, 3, 1 )
         gfx.rectangle( 'fill', -2.5, y-8, 5, 1 )
      end

   end

   deTranslateRotate( player.x + 1.5, player.y + 1.5, player.facing ) 
end


function restartRoom()
   loadNewRoom( current_room.name )
   player.x = player_start[1]
   player.y = player_start[2]
end

--- Effects

function drawEffects()
   if player.warppoint then
      local pw = player.warppoint
      gfx.setColor( ORANGE_WARP )
      gfx.rectangle( 'fill', pw[1], pw[2]+1, 1, 1 )
      gfx.rectangle( 'fill', pw[1]+1, pw[2], 1, 1 )
      gfx.rectangle( 'fill', pw[1]+1, pw[2]+2, 1, 1 )
      gfx.rectangle( 'fill', pw[1]+2, pw[2]+1, 1, 1 )
   end
end

--- Collisions and Interactions

function playerStaticCollisions( new_x, new_y )
   for x=new_x,new_x+2 do
      for y=new_y,new_y+2 do
         if current_room.grid[x][y][1] == 'wall'
            or current_room.grid[x][y][1] == 'hole'
            or (current_room.grid[x][y].obj and not current_room.grid[x][y].obj.passable)
            then
            return true
         end

         if current_room.grid[x][y][1] == 'miasma' then 
            -- Dead
            restartRoom()
            return true
         end

         if current_room.grid[x][y][1] == 'door' then 
            local direction = current_room.grid[x][y][2]
            loadNewRoom( current_room.grid[x][y][3] )
            if direction == 'left' then player.x = current_room.width - 4
            elseif direction == 'right' then player.x = 1
            elseif direction == 'up' then player.y = current_room.height - 4
            elseif direction == 'down' then player.y = 1 end
            player_start = { player.x, player.y }
            return true
         end
      end
   end
   return false
end

function playerUpdateCollisions()
   for x=player.x,player.x+2 do
      for y=player.y,player.y+2 do
         if current_room.grid[x][y][1] == 'miasma' then 
            -- Dead
            restartRoom()
         end
      end
   end
end

function objectStaticCollisions( object, new_x, new_y )
   if new_x <= player.x + 2 and new_x + object.width-1 >= player.x
      and new_y <= player.y + 2 and new_y + object.width-1 >= player.y then
      return true
   end

   for x=new_x,new_x+object.width-1 do
      for y=new_y,new_y+object.height-1 do
         if current_room.grid[x][y][1] == 'wall'
            or current_room.grid[x][y][1] == 'hole'
            or current_room.grid[x][y][1] == 'door' 
            or (current_room.grid[x][y].obj and 
               not current_room.grid[x][y].obj.passable and not current_room.grid[x][y].obj == object)
            then 
            return true
         end
      end
   end
   return false

end

--- Love callbacks

function love.conf(t)
  t.version = '0.10.1'

  t.window.title = 'Low Res Adventure'
  t.window.width  = 640
  t.window.height = 640
  t.window.resizable = false
  t.window.borderless = false
  t.window.vsync = true

  t.modules.joystick = false
  t.modules.physics = false
end

function love.load()
   setZoom( 10 )

   gfx.setDefaultFilter('nearest', 'nearest', 0)

   canvas64 = gfx.newCanvas(64, 64)

   font = gfx.newFont('res/minifont.ttf', 16)
   fpsText = gfx.newText(font, '')
   nameText = gfx.newText(font, '')
   magnetText = gfx.newText(font, '')

   gfx.setLineWidth( 1 )
   gfx.setLineStyle( "rough" )

   love.window.setTitle( 'Low Res Adventure' )

   initPlayer()
   loadNewRoom( "magnetpuzzle1" )
end

function love.keypressed(key, scancode, isrepeat)
   if key == 'escape' then love.event.quit() end

   if key == 'kp+' then setZoom( zoom + 1 ) end
   if key == 'kp-' then setZoom( zoom - 1 ) end

   if player.state == "normal" then
      if key == 'z' then changeColor( "left" ) end
      if key == 'x' then changeColor( "right" ) end
      if key == '1' then changeColor( 1 ) end
      if key == '2' then changeColor( 2 ) end
      if key == '3' then changeColor( 3 ) end
      if key == '4' then changeColor( 4 ) end
      if key == '5' then changeColor( 5 ) end
      if key == '6' then changeColor( 6 ) end
      if key == '0' then changeColor( 0 ) end
      if key == 'space' then playerActionOn() end
   end
   
   if key == 'r' then restartRoom() end
end

function love.keyreleased(key)
   if key == 'space' then playerActionOff() end
end

local moved_last_time = false
function love.update(dt)
   local fps = love.timer.getFPS()
   fpsText:set(fps..' fps')

   if player.state == "normal" and not moved_last_time then
      if love.keyboard.isDown("up") then 
         movePlayer( 0, -speed ) 
         player.facing = 'up'
         moved_last_time = true 
      end
      if love.keyboard.isDown("down") then 
         movePlayer( 0, speed ) 
         player.facing = 'down'
         moved_last_time = true 
      end
      if love.keyboard.isDown("left") then 
         movePlayer( -speed, 0 ) 
         player.facing = 'left'
         moved_last_time = true 
      end
      if love.keyboard.isDown("right") then 
         movePlayer( speed, 0 ) 
         player.facing = 'right'
         moved_last_time = true 
      end
   else moved_last_time = false end

   if current_room.active then
      updateRoom()
      playerUpdateCollisions()
   end
end

local test_x = 1
local test_y = 1
function love.draw()
   gfx.setCanvas( canvas64 )

      gfx.setBackgroundColor( 210, 180, 140 )
      gfx.clear()

      drawRoom()
      drawEffects()
      drawObjects()
      drawPlayer()

      if love.keyboard.isDown("f") then 
         gfx.setColor( 255, 255, 255, 255 )
         gfx.draw( fpsText, 0, 0 )
      end
      if love.keyboard.isDown("n") then 
         gfx.setColor( 255, 255, 255, 255 )
         nameText:set(current_room.name)
         gfx.draw( nameText, 0, 0 )
      end
      if player.magnet_target then 
         gfx.setColor( 255, 255, 255, 255 )
         local mt = player.magnet_target
         magnetText:set(mt.test .. " xt:" .. mt.x_move_ticks .. " vy:" .. mt.velocity.y)
         gfx.draw( magnetText, 0, 0 )
      end

   gfx.setCanvas()

   gfx.setColor( 255, 255, 255, 255 )
   gfx.draw( canvas64, 0, 0, 0, zoom, zoom )
end
