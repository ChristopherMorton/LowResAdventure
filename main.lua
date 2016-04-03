require "rooms"

gfx = love.graphics

--- Data

-- Declarations

local game_state = "play"
local player
local current_room
local prev_room
local camera = { x = 0, y = 0 }
local speed = 1
local zoom = 10
local effect_id = 1
local font

-- Constants

CAMERA_EDGE = 20

MIASMA_SPREAD_CHANCE = 0.1

MAGNET_LINE_TIME = 6

BASE_SPEED = 1
MAGNET_SPEED = 4

MAX_VELOCITY = 29

WARP_EFFECT_ALPHA = 20
WARP_EFFECT_DURATION = 24

BOMB_TIMER_SEGMENT = 60
BOMB_KICK_VELOCITY = 15

SWORD_ANIM_TIME = 16
SWORD_SWING_TIME = 11
SWORD_LENGTH = 7.9

RUBBLE_DURATION_SEGMENT = 5
EXPLOSION_DURATION = 15

BLOB_WIDTH = 7
BLOB_HEIGHT = 7
BLOB_MAX_VELOCITY = 15
BLOB_ANIM_TIMER = 18
BLOB_MOVE_CHANCE = 0.3

-- Colors

BLACK = { 0, 0, 0 }
DARK_GRAY = { 80, 80, 80 }
LIGHT_GRAY = { 160, 160, 160 }
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
BLUE_BOMB_EDGE = { 0, 0, 215 }
VIOLET_SWORD = { 195, 10, 105 }
VIOLET_SWORD_FILL = { 255, 50, 165 }

-- Images

img_explosion = gfx.newImage( "res/explosionred.png" )
img_explosionblue = gfx.newImage( "res/explosionblue.png" )
img_blobblack1 = gfx.newImage( "res/blobblack1.png" )
img_blobblack2 = gfx.newImage( "res/blobblack2.png" )
img_blobred1 = gfx.newImage( "res/blobred1.png" )
img_blobred2 = gfx.newImage( "res/blobred2.png" )

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

function shallowcopy( orig )
   local copy = {}
   for key, value in pairs( orig ) do
      copy[key] = value
   end
   return copy
end

function randomDirection()
   local rand = math.random(4)
   if rand == 1 then return "up" end
   if rand == 2 then return "right" end
   if rand == 3 then return "down" end
   return "left"
end

function addDirection( thing, dir )
   if dir == "up" then thing.y = thing.y - 1 end
   if dir == "down" then thing.y = thing.y + 1 end
   if dir == "left" then thing.x = thing.x - 1 end
   if dir == "right" then thing.x = thing.x + 1 end
end

function intersects( thing1, thing2 )
   if thing1.x <= thing2.x + thing2.width - 1 
      and thing1.x + thing1.width-1 >= thing2.x
      and thing1.y <= thing2.y + thing2.height-1 
      and thing1.y + thing1.height-1 >= thing2.y then
      return true
   else
      return false
   end
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

function destroyObject( object )

   current_room.objects[object.id] = nil

   if object.class == "block" then


      for x=object.x,object.x+object.width-1 do
         for y=object.y,object.y+object.height-1 do
            current_room.grid[x][y].obj = nil

            createEffect( "rubble", object.color, x, y )
         end
      end

   end

   if object.class == "bomb" then
      createEffect( "explosion", "blue", object.x - 2, object.y - 2 )
   end

end

function drawObjects()
   for _,object in pairs(current_room.objects) do

      if object.class == "bomb" then
         gfx.setColor( BLUE_BOMB_EDGE )
         gfx.rectangle( "fill", object.x, object.y, 3, 3 )
         gfx.setColor( BLUE_BOMB )
         gfx.rectangle( "fill", object.x+1, object.y+1, 1, 1 )

         -- Fuse
         gfx.setColor( BLACK )
         if object.timer > 3 * BOMB_TIMER_SEGMENT then
            gfx.rectangle( "fill", object.x+1, object.y-1, 1, 1 )
            gfx.rectangle( "fill", object.x+2, object.y-2, 2, 1 )
            gfx.setColor( RED_MAGNET )
            gfx.rectangle( "fill", object.x+4, object.y-1, 1, 1 )
         elseif object.timer > 2 * BOMB_TIMER_SEGMENT then
            gfx.rectangle( "fill", object.x+1, object.y-1, 1, 1 )
            gfx.rectangle( "fill", object.x+2, object.y-2, 1, 1 )
            gfx.setColor( RED_MAGNET )
            gfx.rectangle( "fill", object.x+3, object.y-2, 1, 1 )
         elseif object.timer > 1 * BOMB_TIMER_SEGMENT then
            gfx.rectangle( "fill", object.x+1, object.y-1, 1, 1 )
            gfx.setColor( RED_MAGNET )
            gfx.rectangle( "fill", object.x+2, object.y-2, 1, 1 )
         else
            gfx.setColor( RED_MAGNET )
            gfx.rectangle( "fill", object.x+1, object.y-1, 1, 1 )
         end
      end

      if object.class == "block" then
         if object.multicolor then

         else
            if object.color == "red" then gfx.setColor( RED_MAGNET ) end
            if object.color == "blue" then gfx.setColor( BLUE_BOMB ) end
            if object.color == "black" then gfx.setColor( DARK_GRAY ) end

            gfx.rectangle( "fill", object.x, object.y, object.width, object.height )

            if object.color == "red" then gfx.setColor( RED_MAGNET_EDGE ) end
            if object.color == "blue" then gfx.setColor( BLUE_BOMB_EDGE ) end
            if object.color == "black" then gfx.setColor( BLACK ) end

            gfx.rectangle( "line", object.x+1, object.y+1, object.width-1, object.height-1 )
         end
      end

      if object.class == "lock" then
         local lock_color = 255 - (object.locks * 25)
         if lock_color < 105 then lock_color = 105 end
         gfx.setColor( lock_color, lock_color, lock_color )
         gfx.rectangle( "fill", object.x, object.y, object.width, object.height )
         gfx.setColor( WHITE )
         gfx.rectangle( "line", object.x+1, object.y+1, object.width-1, object.height-1 )
         gfx.setColor( BLACK )
         if object.height >= 5 then
            gfx.rectangle( "fill", math.floor(object.x + (object.width / 2)),
                                   math.floor(object.y + (object.height / 2) - 1), 1, 2 )
         elseif object.width >= 5 then
            gfx.rectangle( "fill", math.floor(object.x + (object.width / 2) - 1),
                                   math.floor(object.y + (object.height / 2)), 2, 1 )
         else
            gfx.rectangle( "fill", math.floor(object.x + (object.width / 2)),
                                   math.floor(object.y + (object.height / 2)), 1, 1 )
         end
      end
   end
end

function drawTriggers()
   for _,trigger in pairs(current_room.triggers) do

      if trigger.class == "button" then
         if trigger.color == "red" then gfx.setColor( RED_MAGNET ) end
         if trigger.color == "black" then gfx.setColor( LIGHT_GRAY ) end

         gfx.rectangle( "fill", trigger.x, trigger.y, trigger.width, trigger.height )

         if trigger.color == "red" then gfx.setColor( RED_MAGNET_EDGE ) end
         if trigger.color == "black" then gfx.setColor( BLACK ) end

         if not trigger.pressed then
            gfx.rectangle( "line", trigger.x+2, trigger.y+2, trigger.width-3, trigger.height-3 )
         end
         gfx.rectangle( "fill", trigger.x, trigger.y, 1, 1 )
         gfx.rectangle( "fill", trigger.x + trigger.width-1, trigger.y, 1, 1 )
         gfx.rectangle( "fill", trigger.x + trigger.width-1, trigger.y + trigger.height-1, 1, 1 )
         gfx.rectangle( "fill", trigger.x, trigger.y + trigger.height-1, 1, 1 )
      end
   end
end

function addLock( lock )
   if lock and lock.locks then lock.locks = lock.locks + 1 end
end

function removeLock( lock )
   if lock.locks then lock.locks = lock.locks - 1 end

   if lock.class == "bombtrap" then
      for _,object in pairs(current_room.objects) do
         if object.explodable and intersects( object, lock ) then
            destroyObject( object )
         end
      end
      for _,enemy in pairs(current_room.enemies) do
         if enemy.explodable and intersects( enemy, lock ) then
            destroyEnemy( enemy )
         end
      end

      createEffect( "explosion", "black", lock.x, lock.y )
   end

   if lock.locks == 0 then
      -- Remove the lock
      if lock.class == "lock" then
         current_room.objects[lock.id] = nil

         for x=lock.x,lock.x+lock.width-1 do
            for y=lock.y,lock.y+lock.height-1 do
               current_room.grid[x][y].obj = nil
            end
         end

         -- Save completion
         for _,object in pairs(roomDatabase[current_room.name].objects) do
            if object.id == lock.id then
               object.cleared = true
            end
         end
      end
      return true
   end
   return false
end

--- Room

function loadNewRoom( name )
   if current_room and current_room.name == name then
      current_room = generateRoom( roomDatabase[name] )
   elseif prev_room and prev_room.name == name and not prev_room.regenerate then
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
                  regenerate = input.regenerate, 
                  objects = { },
                  enemies = { },
                  triggers = { },
                  effects = { },
                  images = { },
                }

   if input.custom_grid then
      room.grid = input.custom_grid
   else
      -- Grid setup
      room.grid = {}
      for i=0,room.width-1 do
         room.grid[i] = {}
         for j=0,room.height-1 do
            room.grid[i][j] = { id=nil }
         end
      end

      -- Base Walls
      for i=0,room.width-1 do
         room.grid[i][0] = { id='wall' }
         room.grid[i][1] = { id='wall' }
         room.grid[i][room.height-1] = { id='wall' }
         room.grid[i][room.height-2] = { id='wall' }
      end
      for j=0,room.height-1 do
         room.grid[0][j] = { id='wall' }
         room.grid[1][j] = { id='wall' }
         room.grid[room.width-1][j] = { id='wall' }
         room.grid[room.width-2][j] = { id='wall' }
      end

      if input.doors then
         for _,door in pairs(input.doors) do
            if door.side == 'up' then
               for i=door.start,door.finish do
                  room.grid[i][0] = { id='door', side=door.side, to=door.to, to_x=door.to_x, to_y=door.to_y }
                  room.grid[i][1] = { id=nil }
               end
            elseif door.side == 'down' then
               for i=door.start,door.finish do
                  room.grid[i][room.height-1] = { id='door', side=door.side, to=door.to, to_x=door.to_x, to_y=door.to_y }
                  room.grid[i][room.height-2] = { id=nil }
               end
            elseif door.side == 'right' then
               for j=door.start,door.finish do
                  room.grid[room.width-1][j] = { id='door', side=door.side, to=door.to, to_x=door.to_x, to_y=door.to_y }
                  room.grid[room.width-2][j] = { id=nil }
               end
            elseif door.side == 'left' then
               for j=door.start,door.finish do
                  room.grid[0][j] = { id='door', side=door.side, to=door.to, to_x=door.to_x, to_y=door.to_y }
                  room.grid[1][j] = { id=nil }
               end
            end
         end
      end

      if input.floor then
         for _,geometry in pairs(input.floor) do

            if geometry.style == 'image' then
               table.insert(room.images, { class="image", image=gfx.newImage( geometry.source ), x=geometry.x, y=geometry.y })
            end

            if geometry.style == 'text' then
               table.insert(room.images, { class="text", text=gfx.newText( font, geometry.text ), x=geometry.x, y=geometry.y })
            end

            if geometry.style == 'line' then
               local cur = {}
               cur.x = geometry.start.x
               cur.y = geometry.start.y
               room.grid[cur.x][cur.y] = { id=geometry.mark }
               for _,move in pairs(geometry.moves) do
                  local dx = 0
                  local dy = 0
                  if move.dir == "left" then dx = -1
                  elseif move.dir == "right" then dx = 1
                  elseif move.dir == "up" then dy = -1
                  elseif move.dir == "down" then dy = 1 end

                  for i=1,move.dist do
                     cur.x = cur.x + dx
                     cur.y = cur.y + dy
                     room.grid[cur.x][cur.y] = { id=geometry.mark }
                  end
               end
            end

            if geometry.style == "points" then
               for _,point in pairs(geometry.points) do
                  room.grid[point.x][point.y] = { id=geometry.mark }
               end
            end

            -- Custom shapes! Scatter these around ;D
            if geometry.style == "bomb" then
               room.grid[geometry.x + 0][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 4] = { id=geometry.mark }

               room.grid[geometry.x + 1][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 1] = { id=geometry.mark }
            end

            if geometry.style == "eye" then
               room.grid[geometry.x + 3][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 2] = { id=geometry.mark }

               room.grid[geometry.x + 1][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 1] = { id=geometry.mark }

               room.grid[geometry.x + 0][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 2] = { id=geometry.mark }
            end

            if geometry.style == "cat" then
               room.grid[geometry.x + 1][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 0] = { id=geometry.mark }

               room.grid[geometry.x + 4][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 0] = { id=geometry.mark }

               room.grid[geometry.x + 3][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 4] = { id=geometry.mark }
            end

            if geometry.style == "deer" then
               room.grid[geometry.x + 0][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 0] = { id=geometry.mark }

               room.grid[geometry.x + 2][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 4] = { id=geometry.mark }

               room.grid[geometry.x + 5][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 9][geometry.y + 3] = { id=geometry.mark }

               room.grid[geometry.x + 5][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 6] = { id=geometry.mark }

            end

            if geometry.style == "ankh" then
               room.grid[geometry.x + 3][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 3] = { id=geometry.mark }

               room.grid[geometry.x + 0][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 4] = { id=geometry.mark }

               room.grid[geometry.x + 3][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 7] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 8] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 9] = { id=geometry.mark }
            end

            if geometry.style == "spiral" then
               room.grid[geometry.x + 0][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 3] = { id=geometry.mark }
            end

            if geometry.style == "apple" then
               room.grid[geometry.x + 2][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 4] = { id=geometry.mark }

               room.grid[geometry.x + 1][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 7] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 8] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 9] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 9] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 9] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 8] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 7] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 4] = { id=geometry.mark }
            end

            if geometry.style == "heart" then
               room.grid[geometry.x + 0][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 4] = { id=geometry.mark }
            end

            if geometry.style == "scarab" then
               room.grid[geometry.x + 3][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 1] = { id=geometry.mark }

               room.grid[geometry.x + 2][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 6] = { id=geometry.mark }

               room.grid[geometry.x + 1][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 7] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 7] = { id=geometry.mark }
            end

            if geometry.style == "invader" then
               room.grid[geometry.x + 0][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 7] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 7] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 7] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 7] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 9][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 9][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 10][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 10][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 10][geometry.y + 6] = { id=geometry.mark }

            end

            if geometry.style == "companion" then
               room.grid[geometry.x + 0][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 5] = { id=geometry.mark }

               room.grid[geometry.x + 2][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 3] = { id=geometry.mark }
            end

         end
      end

      if input.objects then
         for _,object in pairs(input.objects) do

            if object.class == "miasma" then
               for x=object.x,object.x+object.width-1 do
                  for y=object.y,object.y+object.height-1 do
                     room.grid[x][y] = { id="miasma", miasma=true }
                  end
               end
            end
             
            if object.class == "bombtrap" then
               local obj = shallowcopy( object )
               obj.locks = 1000
               obj.passable = true
               obj.width = 7
               obj.height = 7
               room.objects[obj.id] = obj
            end

            if object.class == "block" then
               local obj = shallowcopy( object )
               room.objects[obj.id] = obj
               if obj.resistance then
                  obj.resistance_left = obj.resistance
               end
               for x=obj.x,obj.x+obj.width-1 do
                  for y=obj.y,obj.y+obj.height-1 do
                     room.grid[x][y].obj = obj
                  end
               end
            end

            if object.class == "lock" then
               if not object.cleared then
                  local obj = shallowcopy( object )
                  room.objects[obj.id] = obj

                  for x=obj.x,obj.x+obj.width-1 do
                     for y=obj.y,obj.y+obj.height-1 do
                        room.grid[x][y].obj = obj
                     end
                  end 
               end
            end

         end
      end

      if input.enemies then
         for _,enemy in pairs(input.enemies) do

            if enemy.class == "blob" then
               local e = shallowcopy(enemy)
               if e.deathtarget then e.deathtarget = room.objects[e.deathtarget] end

               e.width = BLOB_WIDTH
               e.height = BLOB_HEIGHT

               e.anim_timer = BLOB_ANIM_TIMER
               e.anim_state = 1
               e.velocity = { x = 0, y = 0 }
               e.x_move_ticks = 0
               e.y_move_ticks = 0
               e.max_velocity = BLOB_MAX_VELOCITY
               
               room.enemies[e.id] = e
            end
            
      end end

      if input.triggers then
         for _,trigger in pairs(input.triggers) do
            if trigger.class == "button" then
               local trig = shallowcopy( trigger )
               trig.target = room.objects[trig.target]
               trig.pressed = false
               room.triggers[trig.id] = trig 
            end
         end
      end

   end

   return room
end

function updateRoom()

   for i=0,current_room.width-1 do
      for j=0,current_room.height-1 do
         if current_room.grid[i][j].miasma then 
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
                  if current_room.grid[x][y].id ~= 'wall' then 
                     if current_room.grid[x][y].miasma == false then
                        current_room.grid[x][y].miasma = nil
                     else
                        current_room.grid[x][y].miasma = true
                     end
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

      if mt.resistance_left then
         mt.resistance_left = mt.resistance_left - 1
      end

      if (not mt.resistance_left) or mt.resistance_left == 0 then
         if (player.facing == "down" and player.magnet_pull) or (player.facing == "up" and not player.magnet_pull) then mt.velocity.y = mt.velocity.y + 1 end
         if (player.facing == "up" and player.magnet_pull) or (player.facing == "down" and not player.magnet_pull) then mt.velocity.y = mt.velocity.y - 1 end
         if (player.facing == "right" and player.magnet_pull) or (player.facing == "left" and not player.magnet_pull) then mt.velocity.x = mt.velocity.x + 1 end
         if (player.facing == "left" and player.magnet_pull) or (player.facing == "right" and not player.magnet_pull) then mt.velocity.x = mt.velocity.x - 1 end
      end

      if mt.resistance_left and mt.resistance_left == 0 then
         mt.resistance_left = mt.resistance
      end
   end

   local destroyed = { }
   for _,object in pairs(current_room.objects) do

      if object.class == "chain" then
         -- Pull the attached object towards the origin

      end

      if object.class == "bomb" then

         object.timer = object.timer - 1

         if object.timer <= 0 then
            -- Explode
            destroyed.bomb = object

            for x=object.x-2,object.x+4 do
               for y=object.y-2,object.y+4 do
                  if current_room.grid[x][y].obj and current_room.grid[x][y].obj.bombable then
                     local obj = current_room.grid[x][y].obj
                     destroyed[ obj.id ] = obj
            end end end

         else

            local vel = object.velocity

            if vel.x ~= 0 then
               object.x_move_ticks = object.x_move_ticks + 1
               if object.x_move_ticks >= math.floor(59 / math.abs(vel.x)) then
                  object.x_move_ticks = 0
                  
                  -- Move
                  if (vel.x > 0) then
                     if not objectStaticCollisions( object, object.x + 1, object.y ) then
                        object.x = object.x + 1
                        vel.x = vel.x - 1
                     else
                        vel.x = 0
                     end
                  else
                     if not objectStaticCollisions( object, object.x - 1, object.y ) then
                        object.x = object.x - 1
                        vel.x = vel.x + 1
                     else
                        vel.x = 0
            end end end end

            if vel.y ~= 0 then
               object.y_move_ticks = object.y_move_ticks + 1
               if object.y_move_ticks >= math.floor(59 / math.abs(vel.y)) then
                  object.y_move_ticks = 0
                  
                  -- Move
                  if (vel.y > 0) then
                     if not objectStaticCollisions( object, object.x, object.y + 1 ) then
                        object.y = object.y + 1
                        vel.y = vel.y - 1
                     else
                        vel.y = 0
                     end
                  else
                     if not objectStaticCollisions( object, object.x, object.y - 1 ) then
                        object.y = object.y - 1
                        vel.y = vel.y + 1
                     else
                        vel.y = 0
            end end end end
         end
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
               if object.x_move_ticks >= math.floor(59 / math.abs(vel.x)) then
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
            end end end end

            if vel.y ~= 0 then
               object.y_move_ticks = object.y_move_ticks + 1
               if object.y_move_ticks >= math.floor(59 / math.abs(vel.y)) then
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
            end end end end

         end
      end 
      
      if object.class == "" then
      end
   end

   -- Enemies
   for _,enemy in pairs(current_room.enemies) do
       
      -- AI
      if enemy.class == "blob" then
         local dx = player.x - enemy.x
         local dy = player.y - enemy.y
         local dsum = math.abs(dx) + math.abs(dy)

         if math.random() < BLOB_MOVE_CHANCE then
            if math.random(dsum) <= math.abs(dx) then
               if dx > 0 then enemy.velocity.x = enemy.velocity.x + 1
               else enemy.velocity.x = enemy.velocity.x - 1 end
            else
               if dy > 0 then enemy.velocity.y = enemy.velocity.y + 1
               else enemy.velocity.y = enemy.velocity.y - 1 end
            end
         end

      end

      if enemy.velocity then
         local vel = enemy.velocity

         if vel.x > MAX_VELOCITY then vel.x = MAX_VELOCITY end
         if vel.x < -MAX_VELOCITY then vel.x = -MAX_VELOCITY end
         if vel.y > MAX_VELOCITY then vel.y = MAX_VELOCITY end
         if vel.y < -MAX_VELOCITY then vel.y = -MAX_VELOCITY end

         if vel.x ~= 0 then
            enemy.x_move_ticks = enemy.x_move_ticks + 1
            if enemy.x_move_ticks >= math.floor(59 / math.abs(vel.x)) then
               enemy.x_move_ticks = 0
               
               -- Try to move
               if (vel.x > 0) then
                  if (moveObject( enemy, 1, 0 )) then
                     -- success
                     vel.x = vel.x - 1
                  else 
                     -- collision 
                     vel.x = 0
                  end
               end
               if (vel.x < 0) then
                  if (moveObject( enemy, -1, 0 )) then
                     -- success
                     vel.x = vel.x + 1
                  else 
                     -- collision 
                     vel.x = 0
         end end end end

         if vel.y ~= 0 then
            enemy.y_move_ticks = enemy.y_move_ticks + 1
            if enemy.y_move_ticks >= math.floor(59 / math.abs(vel.y)) then
               enemy.y_move_ticks = 0
               
               -- Try to move
               if (vel.y > 0) then
                  if (moveObject( enemy, 0, 1 )) then
                     -- success
                     vel.y = vel.y - 1
                  else 
                     -- collision 
                     vel.y = 0
                  end
               end
               if (vel.y < 0) then
                  if (moveObject( enemy, 0, -1 )) then
                     -- success
                     vel.y = vel.y + 1
                  else 
                     -- collision 
                     vel.y = 0
         end end end end

      end

   end

   -- Triggers
   for _,trigger in pairs(current_room.triggers) do

      if trigger.class == "button" and trigger.target and trigger.target.locks > 0 then
         local pressed = false

         for _,obj in pairs(current_room.objects) do
            if obj.class == "block" and obj.color == trigger.color and
               trigger.x <= obj.x + obj.width-1 and trigger.x + trigger.width-1 >= obj.x
               and trigger.y <= obj.y + obj.height-1 and trigger.y + trigger.height-1 >= obj.y then
               pressed = true
            end 
         end
         if trigger.color == "black" and
            player.x <= trigger.x + trigger.width-1 and player.x + 2 >= trigger.x
            and player.y <= trigger.y + trigger.height-1 and player.y + 2 >= trigger.y then
            pressed = true
         end

         if pressed and not trigger.pressed then
            trigger.pressed = true
            if removeLock( trigger.target ) then
               -- Lock target gone for good
               trigger.target = nil
            end
         elseif not pressed and trigger.pressed then
            trigger.pressed = false
            addLock( trigger.target )
         end
      end

   end

   -- Destruction
   for _,thing in pairs(destroyed) do
      destroyObject( thing )
   end
end

function drawRoom()

   gfx.setColor( FLOOR_SAND )
   gfx.rectangle( 'fill', 0, 0, current_room.width, current_room.height)

   for _,image in pairs(current_room.images) do
      if image.class == "image" then
         gfx.setColor( WHITE )
         gfx.draw( image.image, image.x, image.y )
      elseif image.class == "text" then
         gfx.setColor( DRAWING_SAND )
         gfx.draw( image.text, image.x, image.y )
      end
   end

   -- Static stuff
   for i=0,current_room.width-1 do
      for j=0,current_room.height-1 do

         -- Top level stuff
         if current_room.grid[i][j].miasma then
            gfx.setColor( MIASMA )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 

         -- Mid level stuff

         -- Underneath stuff
         elseif current_room.grid[i][j].id == 'wall' then 
            gfx.setColor( WALL_SAND )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         elseif current_room.grid[i][j].id == 'door' then 
            gfx.setColor( FLOOR_SAND )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         elseif current_room.grid[i][j].id == 'black' then 
            gfx.setColor( BLACK )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         elseif current_room.grid[i][j].id == 'drawing' then 
            gfx.setColor( DRAWING_SAND )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         end

      end
   end
end

--- Camera

function fitCamera()
   if current_room.width > 64 then
      if camera.x < 0 then camera.x = 0 end
      if camera.x + 64 > current_room.width then camera.x = current_room.width - 64 end
   end
   if current_room.height > 64 then
      if camera.y < 0 then camera.y = 0 end
      if camera.y + 64 > current_room.height then camera.y = current_room.height - 64 end
   end
end

function centerCamera()
   if current_room.width <= 64 then camera.x = -math.floor((64 - current_room.width) / 2)
   else camera.x = player.x - 32
   end
   if current_room.height <= 64 then camera.y = -math.floor((64 - current_room.height) / 2)
   else camera.y = player.y - 32
   end

   fitCamera()
end

function followCamera()
   if current_room.width > 64 then
      if player.x - CAMERA_EDGE < camera.x then camera.x = player.x - CAMERA_EDGE end
      if player.x + CAMERA_EDGE > camera.x + 64 then camera.x = player.x + CAMERA_EDGE - 64 end
   end
   if current_room.height > 64 then
      if player.y - CAMERA_EDGE < camera.y then camera.y = player.y - CAMERA_EDGE end
      if player.y + CAMERA_EDGE > camera.y + 64 then camera.y = player.y + CAMERA_EDGE - 64 end
   end

   fitCamera()
end

--- Enemies

function destroyEnemy( enemy )

   current_room.enemies[enemy.id] = nil

   if enemy.deathtarget then removeLock( enemy.deathtarget ) end

   if enemy.class == "blob" then

      local color = WHITE

      for x=enemy.x,enemy.x+enemy.width-1 do
         for y=enemy.y,enemy.y+enemy.height-1 do 
            createEffect( "rubble", color, x, y )
         end
      end

   end
end


function drawEnemies()
   for _,enemy in pairs(current_room.enemies) do

      if enemy.class == 'blob' then
         enemy.anim_timer = enemy.anim_timer - 1
         if enemy.anim_timer == 0 then 
            enemy.anim_timer = BLOB_ANIM_TIMER 
            if enemy.anim_state == 1 then enemy.anim_state = 2 else enemy.anim_state = 1 end
         end

         gfx.setColor( WHITE )
         if enemy.anim_state == 1 then
            if enemy.color == "black" then gfx.draw( img_blobblack1, enemy.x, enemy.y )
            elseif enemy.color == "red" then gfx.draw( img_blobred1, enemy.x, enemy.y ) end
         else
            if enemy.color == "black" then gfx.draw( img_blobblack2, enemy.x, enemy.y )
            elseif enemy.color == "red" then gfx.draw( img_blobred2, enemy.x, enemy.y ) end
         end 
      end

   end
end

--- Player

function initPlayer()
   player = { x = 13, y = 2, facing = 'down', width = 3, height = 3,
                    color = 0, 
                    state = "normal",
                    anim_timer = 0,
                    magnet_pull = false,
                    unlocked = { } }
   player_start = { x = player.x, y = player.y }
   player.unlocked[0] = true
   player.unlocked[1] = true
   player.unlocked[2] = true
   player.unlocked[3] = true
   player.unlocked[4] = true
   player.unlocked[5] = true
   player.unlocked[6] = true
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
      if player.state == "magnet" then 
         player.magnet_target = nil
      end
      followCamera()
      return true
   else
      return false
   end
end

function movePlayer( direction )
   local new_x = player.x
   local new_y = player.y
   if direction == "up" then new_y = new_y - 1
   elseif direction == "down" then new_y = new_y + 1
   elseif direction == "left" then new_x = new_x - 1
   elseif direction == "right" then new_x = new_x + 1
   end

   -- Check collisions
   local take_back = false
   if playerStaticCollisions( new_x, new_y, direction ) then take_back = true end

   if not take_back then
      player.x = new_x
      player.y = new_y
      if player.state == "magnet" then 
         player.magnet_target = nil
      end
      followCamera()
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
               if not player.magnet_target.x_move_ticks then player.magnet_target.x_move_ticks = 0 end
               if not player.magnet_target.y_move_ticks then player.magnet_target.y_move_ticks = 0 end
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
               if not player.magnet_target.x_move_ticks then player.magnet_target.x_move_ticks = 0 end
               if not player.magnet_target.y_move_ticks then player.magnet_target.y_move_ticks = 0 end
               break
            end
         end
      end
   end
end

function swingSword()
   local x_min = player.x - math.ceil(SWORD_LENGTH)
   local x_max = player.x + math.ceil(SWORD_LENGTH)
   local y_min = player.y - math.ceil(SWORD_LENGTH)
   local y_max = player.y + math.ceil(SWORD_LENGTH)
   if player.facing == "up" then y_max = player.y end
   if player.facing == "down" then y_min = player.y end
   if player.facing == "left" then x_max = player.x end
   if player.facing == "right" then x_min = player.x end
   if x_min < 0 then x_min = 0 end
   if y_min < 0 then y_min = 0 end
   if x_max >= current_room.width then x_max = current_room.width-1 end
   if y_max >= current_room.height then y_max = current_room.height-1 end

   local r2 = SWORD_LENGTH * SWORD_LENGTH
   for x=x_min,x_max do
      for y=y_min,y_max do
         local dx = x - player.x
         local dy = y - player.y
         local dist = (dx * dx) + (dy * dy)
         if dist <= r2 then
            current_room.grid[x][y].miasma = false
            -- TODO Push back sword-able things

         end
      end
   end
end

function playerActionOn()
   player.anim_timer = 0
   if player.color == 1 then
      player.state = "magnet"
      player.magnet_pull = not player.magnet_pull
      speed = MAGNET_SPEED

      getMagnetTarget()

   elseif player.color == 2 then
      if player.warppoint then
         movePlayerTo( player.warppoint[1], player.warppoint[2] )
         player.warppoint = nil
      else
         player.warppoint = { player.x, player.y }
         player.warpeffect = WARP_EFFECT_DURATION
      end

   elseif player.color == 3 then
      -- TODO light mechanics
   elseif player.color == 4 then
      -- Launch wind or control wind
   elseif player.color == 5 then
      if current_room.objects.bomb then
         -- Try to kick it
         local bomb = current_room.objects.bomb
         if bomb.x <= player.x + 3 and bomb.x + 2 >= player.x - 1
            and bomb.y <= player.y + 2 and bomb.y + 2 >= player.y - 1 then
            -- Close enough to kick
            if player.facing == "up" then bomb.velocity.y = -BOMB_KICK_VELOCITY end
            if player.facing == "down" then bomb.velocity.y = BOMB_KICK_VELOCITY end
            if player.facing == "left" then bomb.velocity.x = -BOMB_KICK_VELOCITY end
            if player.facing == "right" then bomb.velocity.x = BOMB_KICK_VELOCITY end
         end
      else
         -- Lay a bomb
         local bomb = { id="bomb", class="bomb", passable = true, lightweight = true, 
                        timer = BOMB_TIMER_SEGMENT * 4, 
                        velocity = { x = 0, y = 0 }, x_move_ticks = 0, y_move_ticks = 0,
                        x = player.x, y = player.y, width = 3, height = 3 }
         current_room.objects.bomb = bomb
         
      end
   elseif player.color == 6 then
      -- Sword attack
      player.state = "sword"
      player.sword_anim = SWORD_ANIM_TIME
   end
end

function playerActionOff()
   if player.color == 1 then
      player.state = "normal"
      player.magnet_target = nil
      speed = BASE_SPEED
   end
end

function drawPlayer()
   -- Draw stuff as if facing up, and use rotate
   translateRotate( player.x + 1.5, player.y + 1.5, player.facing )

   gfx.setColor( BLACK )
   gfx.rectangle( 'fill', -1.5, -1.5, 3, 3 )

   if player.sword_anim then
      if player.sword_anim > SWORD_SWING_TIME then
         gfx.setColor( VIOLET_SWORD )
         gfx.rectangle( 'fill', -SWORD_LENGTH, -0.5, SWORD_LENGTH, 1 )
      elseif player.sword_anim == SWORD_SWING_TIME then
         gfx.setColor( VIOLET_SWORD_FILL )
         gfx.arc( 'fill', 0, 0, SWORD_LENGTH, -(math.pi / 2) - 0.1, 0, 15 )
         gfx.setColor( VIOLET_SWORD )
         gfx.rectangle( 'fill', -0.5, -SWORD_LENGTH, 1, SWORD_LENGTH )
         
      else
         local a = 255 - ((player.sword_anim / SWORD_SWING_TIME) * 300)
         if a > 255 then a = 255 end
         gfx.setColor( VIOLET_SWORD_FILL[1], VIOLET_SWORD_FILL[2], VIOLET_SWORD_FILL[3], a )
         gfx.arc( 'fill', 0, 0, SWORD_LENGTH, -math.pi - 0.1, 0, 15 )
         gfx.setColor( VIOLET_SWORD )
         gfx.rectangle( 'fill', 0, -0.5, SWORD_LENGTH, 1 )
      end
   end

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
      gfx.rectangle( 'fill', -1.5, -1.5, 3, 1 )
      gfx.rectangle( 'fill', -1.5, -0.5, 1, 1 )
      gfx.rectangle( 'fill', 0.5, -0.5, 1, 1 )
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
   player.x = player_start.x
   player.y = player_start.y
   centerCamera()
end

--- Effects

function createEffect( class, color, x, y )

   if class == "rubble" then
      current_room.effects[effect_id] = { id=effect_id, class="rubble", color=color, dir=randomDirection(), timer = 3 * RUBBLE_DURATION_SEGMENT, x=x, y=y }
   end

   if class == "explosion" then
      current_room.effects[effect_id] = { id=effect_id, class="explosion", color=color, timer = EXPLOSION_DURATION, x=x, y=y }
   end

   effect_id = effect_id + 1
end

function drawEffects()
   if player.warppoint then
      local pw = player.warppoint
      gfx.setColor( ORANGE_WARP )
      gfx.rectangle( 'fill', pw[1], pw[2]+1, 1, 1 )
      gfx.rectangle( 'fill', pw[1]+1, pw[2], 1, 1 )
      gfx.rectangle( 'fill', pw[1]+1, pw[2]+2, 1, 1 )
      gfx.rectangle( 'fill', pw[1]+2, pw[2]+1, 1, 1 )

      if player.warpeffect and player.warpeffect > 0 then
         local alpha = WARP_EFFECT_ALPHA * player.warpeffect
         if alpha > 255 then alpha = 255 end
         gfx.setColor( ORANGE_WARP[1], ORANGE_WARP[2], ORANGE_WARP[3], alpha )
         gfx.rectangle( 'fill', pw[1]-1, pw[2]-1, 2, 1 )
         gfx.rectangle( 'fill', pw[1]-1, pw[2], 1, 1 )

         gfx.rectangle( 'fill', pw[1]+2, pw[2]-1, 1, 1 )
         gfx.rectangle( 'fill', pw[1]+3, pw[2]-1, 1, 2 )

         gfx.rectangle( 'fill', pw[1]-1, pw[2]+2, 1, 1 )
         gfx.rectangle( 'fill', pw[1]-1, pw[2]+3, 2, 1 )

         gfx.rectangle( 'fill', pw[1]+2, pw[2]+3, 1, 1 )
         gfx.rectangle( 'fill', pw[1]+3, pw[2]+2, 1, 2 )
         player.warpeffect = player.warpeffect - 1
         if player.warpeffect == 0 then player.warpeffect = nil end
      end
   end

   local expired = { }
   for _,effect in pairs(current_room.effects) do

      if effect.class == "rubble" then
         effect.timer = effect.timer - 1

         if effect.timer == RUBBLE_DURATION_SEGMENT * 2 or
            effect.timer == RUBBLE_DURATION_SEGMENT then
            addDirection( effect, effect.dir )
         end
         if effect.timer == 0 then expired[effect.id] = true end

         local a = math.floor((effect.timer * 255) / (RUBBLE_DURATION_SEGMENT * 3))

         if effect.color == "blue" then 
            gfx.setColor( BLUE_BOMB[1], BLUE_BOMB[2], BLUE_BOMB[3], a ) 
         else
            gfx.setColor( effect.color[1], effect.color[2], effect.color[3], a )
         end
         gfx.rectangle( 'fill', effect.x, effect.y, 1, 1 )
      end

      if effect.class == "explosion" then
         effect.timer = effect.timer - 1
         if effect.timer == 0 then expired[effect.id] = true end

         local a = math.floor((effect.timer * 255) / (EXPLOSION_DURATION))
         gfx.setColor( 255, 255, 255, a )
         if effect.color == "blue" then 
            gfx.draw( img_explosion, effect.x, effect.y )
         else
            gfx.draw( img_explosion, effect.x, effect.y )
         end

      end

   end
   for id,_ in pairs(expired) do
      current_room.effects[id] = nil
   end
end

--- Collisions and Interactions

function playerStaticCollisions( new_x, new_y, direction )

   for _,enemy in pairs(current_room.enemies) do
      if new_x <= enemy.x + enemy.width-1 and new_x + 2 >= enemy.x
         and new_y <= enemy.y + enemy.height-1 and new_y + 2 >= enemy.y then
         -- Dead
         restartRoom()
         return true
      end
   end

   local pushable = nil

   for x=new_x,new_x+2 do
      for y=new_y,new_y+2 do
         local spot = current_room.grid[x][y]
         if spot.obj and spot.obj.pushable then
            if pushable and pushable ~= spot.obj then
               return true -- Can't push two things at once
            end

            pushable = spot.obj
         end

         if spot.id == 'wall'
            or spot.id == 'black'
            or (spot.obj and not spot.obj.passable and not spot.obj.pushable)
            then
            return true
         end

         if spot.miasma then
            -- Dead
            restartRoom()
            return true
         end

         if spot.id == 'door' then 
            local door = spot
            local direction = door.side
            loadNewRoom( door.to )
            if direction == 'left' then player.x = current_room.width - 4
            elseif direction == 'right' then player.x = 1
            elseif direction == 'up' then player.y = current_room.height - 4
            elseif direction == 'down' then player.y = 1 end
            if door.to_x then player.x = door.to_x end
            if door.to_y then player.y = door.to_y end
            player_start = { x = player.x, y = player.y }
            centerCamera()
            return true
         end
      end
   end

   if pushable and direction then
      pushable.resistance_left = pushable.resistance_left - 1
      if pushable.resistance_left == 0 then
         pushable.resistance_left = pushable.resistance
         local dx = 0
         local dy = 0
         if direction == "up" then dy = -1 end
         if direction == "down" then dy = 1 end
         if direction == "left" then dx = -1 end
         if direction == "right" then dx = 1 end
         local pushed = moveObject( pushable, dx, dy )
         if pushed then
            return false
         else 
            return true
         end
      else
         return true
      end
   end
   return false
end

function playerUpdateCollisions()
   for x=player.x,player.x+2 do
      for y=player.y,player.y+2 do
         if current_room.grid[x][y].miasma then
            -- Dead
            restartRoom()
         end
      end
   end
end

function objectStaticCollisions( object, new_x, new_y )
   if object.class ~= "bomb" and new_x <= player.x + 2 and new_x + object.width-1 >= player.x
      and new_y <= player.y + 2 and new_y + object.height-1 >= player.y then
      return true
   end

   for _,enemy in pairs(current_room.enemies) do
      if not enemy.passable and enemy.id ~= object.id and
         new_x <= enemy.x + enemy.width-1 and new_x + object.width-1 >= enemy.x
         and new_y <= enemy.y + enemy.height-1 and new_y + object.height-1 >= enemy.y then
         return true
      end
   end

   for _,obj in pairs(current_room.objects) do
      if not obj.passable and obj.id ~= object.id and
         new_x <= obj.x + obj.width-1 and new_x + object.width-1 >= obj.x
         and new_y <= obj.y + obj.height-1 and new_y + object.height-1 >= obj.y then
         return true
      end
   end


   for x=new_x,new_x+object.width-1 do
      for y=new_y,new_y+object.height-1 do
         if current_room.grid[x][y].id == 'wall'
            or current_room.grid[x][y].id == 'door' 
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
   infoText = gfx.newText(font, '')

   gfx.setLineWidth( 1 )
   gfx.setLineStyle( "rough" )

   love.window.setTitle( 'Low Res Adventure' )

   initPlayer()
   loadNewRoom( "enemyroom1" )
   centerCamera()
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

local move_timer = 0
function love.update(dt)
   local fps = love.timer.getFPS()
   fpsText:set(fps..' fps')

   if player.state == "sword" then
      player.sword_anim = player.sword_anim - 1

      if player.sword_anim == SWORD_SWING_TIME then
         swingSword()
      elseif player.sword_anim == 0 then 
         player.sword_anim = nil
         player.state = "normal"
      end

   elseif move_timer == 0 then
      if love.keyboard.isDown("up") then 
         movePlayer( "up" )
         if player.state == "normal" then player.facing = 'up' end
         move_timer = speed 
      end
      if love.keyboard.isDown("down") then 
         movePlayer( "down" )
         if player.state == "normal" then player.facing = 'down' end
         move_timer = speed 
      end
      if love.keyboard.isDown("left") then 
         movePlayer( "left" )
         if player.state == "normal" then player.facing = 'left' end
         move_timer = speed 
      end
      if love.keyboard.isDown("right") then 
         movePlayer( "right" )
         if player.state == "normal" then player.facing = 'right' end
         move_timer = speed
      end
   else move_timer = move_timer - 1 end

   updateRoom()
   playerUpdateCollisions()
end

local test_x = 1
local test_y = 1
function love.draw()
   gfx.setCanvas( canvas64 )

      gfx.setBackgroundColor( BLACK )
      gfx.clear()

      gfx.translate( -camera.x, -camera.y )
      drawRoom()
      drawTriggers()
      drawEffects()
      drawObjects()
      drawEnemies()
      drawPlayer()
      gfx.translate( camera.x, camera.y )

      if love.keyboard.isDown("f") then 
         gfx.setColor( 255, 255, 255, 255 )
         gfx.draw( fpsText, 0, 0 )
      end
      if love.keyboard.isDown("e") then 
         gfx.setColor( 255, 255, 255, 255 )
         infoText:set("effect_id:"..effect_id)
         gfx.draw( infoText, 0, 0 )
      end
      if love.keyboard.isDown("n") then 
         gfx.setColor( 255, 255, 255, 255 )
         infoText:set(current_room.name)
         gfx.draw( infoText, 0, 0 )
      end
      if love.keyboard.isDown("m") and player.magnet_target then 
         gfx.setColor( 255, 255, 255, 255 )
         local mt = player.magnet_target
         infoText:set("vx:" .. mt.velocity.x .. " vy:" .. mt.velocity.y)
         gfx.draw( infoText, 0, 0 )
      end
      if love.keyboard.isDown("b") and current_room.objects.bomb then 
         local bomb = current_room.objects.bomb
         gfx.setColor( 255, 255, 255, 255 )
         infoText:set( "xt:" .. bomb.x_move_ticks .. " vx:" .. bomb.velocity.x )
         gfx.draw( infoText, 0, 0 )
      end

   gfx.setCanvas()

   gfx.setColor( 255, 255, 255, 255 )
   gfx.draw( canvas64, 0, 0, 0, zoom, zoom )
end
