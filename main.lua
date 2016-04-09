require "rooms"

gfx = love.graphics

--- Data

-- Declarations

local game_state = "play"
local game_state_timer = 0
local game_state_backup = "play"
local player
local current_room
local prev_room
local camera = { x = 0, y = 0 }
local speed = 1
local zoom = 10
local id_cnt = 1
local font

-- Constants

-- Commented are at 30 fps

CAMERA_EDGE = 24

MIASMA_SPREAD_CHANCE = 0.1 --0.2

MAGNET_LINE_TIME = 6 --4

BASE_SPEED = 1 -- 0
MAGNET_SPEED = 4 -- 2

MAX_VELOCITY = 29 --19
VELOCITY_INVERSE = 59 --39

WARP_EFFECT_ALPHA = 20
WARP_EFFECT_DURATION = 24 --14

FLAME_TIMEOUT = 400 --200
FLAME_POWER = 20
FLAME_FADE_SPEED = 8 --4
FLAME_FADE_TIME = 160 --80
FLAMES_MAX = 4

WIND_TIMER = 3
WIND_MAX_TURNS = 3

BOMB_TIMER_SEGMENT = 66 --33
BOMB_KICK_VELOCITY = 15

SWORD_ANIM_TIME = 18 --10
SWORD_SWING_TIME = 13 --7
SWORD_LENGTH = 7.9

DEATH_DURATION_SEGMENT = 15 --3
DEATH_TIME = 100
RUBBLE_DURATION_SEGMENT = 7 --3
EXPLOSION_DURATION = 20 --8

BLOB_WIDTH = 7
BLOB_HEIGHT = 7
BLOB_MAX_VELOCITY = 15
BLOB_ANIM_TIMER = 24 --18
BLOB_MOVE_CHANCE = 0.2 --0.5
BLOB_MOVE_CHANCE_MODIFIER = 0.3 --0.5

ARCHER_WIDTH = 9
ARCHER_HEIGHT = 9
ARCHER_IDLE_TIMER = 12
ARCHER_FIRE_TIMER = 30
ARCHER_FIRE_CHANCE = 0.2
ARCHER_PAUSE_TIMER = 30
ARCHER_PAUSE_CHANCE = 0.1
ARCHER_FLEE_TIMER = 5
ARCHER_FLEE_RADIUS = 30
ARCHER_ANIM_TIMER = 24

ARROW_SPEED = 30

BOSS1_BASIC_TIMER = 8
BOSS1_FAST_TIMER = 3
BOSS1_FLASH_TIMER = 12
BOSS1_DEATH_TIME = 240
BOSS1_OPENING_TIMER = 60

BOSS1_NUM_FLASHES = 6
BOSS1_SWORD_LENGTH = 10.9

ACQUIRE_POWER_TIME = 180
SHOW_POWER_TIME = 120

HIDDEN_DOOR_TIMER = 40

-- Colors

BLACK = { 0, 0, 0 }
DARK_GRAY = { 80, 80, 80 }
LIGHT_GRAY = { 160, 160, 160 }
WHITE = { 255, 255, 255 }
MIASMA = { 55, 0, 55 }

FLOOR_SAND = { 210, 180, 140 }

WALL_SAND = { 110, 80, 40 }

DRAWING_SAND = { 180, 140, 110 }
WHITE_SAND = { 235, 235, 235 }

RED_MAGNET = { 205, 0, 0 }
RED_MAGNET_EDGE = { 145, 0, 0 }
ORANGE_WARP = { 215, 120, 0 }
YELLOW_LAMP = { 205, 205, 0 }
GREEN_WHIRLWIND = { 0, 185, 0 }
BLUE_BOMB = { 50, 50, 255 }
BLUE_BOMB_EDGE = { 0, 0, 215 }
VIOLET_SWORD = { 195, 10, 105 }
VIOLET_SWORD_FILL = { 255, 50, 165 }

-- Images

img_stairs_up = gfx.newImage( "res/stairs.png" )
img_stairs_down = gfx.newImage( "res/stairsdown.png" )
img_explosion = gfx.newImage( "res/explosionred.png" )
img_explosionblue = gfx.newImage( "res/explosionblue.png" )
img_wind = gfx.newImage( "res/thewind.png" )
img_wind_turn = gfx.newImage( "res/thewindturns.png" )
img_spikes = { up = gfx.newImage( "res/spikeup.png" ),
               right = gfx.newImage( "res/spikeright.png" ),
               down = gfx.newImage( "res/spikedown.png" ),
               left = gfx.newImage( "res/spikeleft.png" ), }

img_blobblack1 = gfx.newImage( "res/blobblack1.png" )
img_blobblack2 = gfx.newImage( "res/blobblack2.png" )
img_blobred1 = gfx.newImage( "res/blobred1.png" )
img_blobred2 = gfx.newImage( "res/blobred2.png" )
img_blobblue1 = gfx.newImage( "res/blobblue1.png" )
img_blobblue2 = gfx.newImage( "res/blobblue2.png" )
img_blobviolet1 = gfx.newImage( "res/blobviolet1.png" )
img_blobviolet2 = gfx.newImage( "res/blobviolet2.png" )

img_archerblack1 = gfx.newImage( "res/archerblack1.png" )
img_archerblack2 = gfx.newImage( "res/archerblack2.png" )
img_archerred1 = gfx.newImage( "res/archerred1.png" )
img_archerred2 = gfx.newImage( "res/archerred2.png" )
img_arrowblack = gfx.newImage( "res/arrowblack.png" )
img_arrowred = gfx.newImage( "res/arrowred.png" )

img_boss1_mid = {
   gfx.newImage( "res/boss1mid.png" ),
   gfx.newImage( "res/boss1mid2.png" ),
   gfx.newImage( "res/boss1mid3.png" ),
   gfx.newImage( "res/boss1mid4.png" ) }
img_boss1_right = {
   gfx.newImage( "res/boss1right.png" ),
   gfx.newImage( "res/boss1right2.png" ),
   gfx.newImage( "res/boss1right3.png" ),
   gfx.newImage( "res/boss1right4.png" ) }
img_boss1_left = {
   gfx.newImage( "res/boss1left.png" ),
   gfx.newImage( "res/boss1left2.png" ),
   gfx.newImage( "res/boss1left3.png" ),
   gfx.newImage( "res/boss1left4.png" ) }

img_magnet = gfx.newImage( "res/magnet.png" )
img_warp = gfx.newImage( "res/warp.png" )
img_lamp = gfx.newImage( "res/lamp.png" )
img_whirlwind = gfx.newImage( "res/whirlwind.png" )
img_bomb = gfx.newImage( "res/bomb.png" )
img_sword = gfx.newImage( "res/sword.png" )

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
   local collides = objectStaticCollisions( object, new_x, new_y )

   if not collides then
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
   end

   if collides.hit == "spikes" then
      destroyObject( object )
   end

   return false
end

function destroyObject( object )

   current_room.objects[object.id] = nil

   if object.class == "block" then


      for x=object.x,object.x+object.width-1 do
         for y=object.y,object.y+object.height-1 do
            current_room.grid[x][y].obj = nil

            if object.color == "multicolor" then
               local color = object.color1
               if math.random() < 0.5 then color = object.color2 end
               createEffect( "rubble", color, x, y )
            else
               createEffect( "rubble", object.color, x, y )
            end
         end
      end

   end

   if object.class == "bomb" then
      createEffect( "explosion", "blue", object.x - 2, object.y - 2 )
   end

   if object.class == "flame" then
      current_room.flamecount = current_room.flamecount - 1
      current_room.lights[object.id] = nil
   end

   if object.class == "magnet" then
      for x=object.x,object.x+object.width-1 do
         for y=object.y,object.y+object.height-1 do
            current_room.grid[x][y].obj = nil
            createEffect( "rubble", RED_MAGNET, x, y )
         end
      end
   end

   if object.class == "warp" then
      for x=object.x,object.x+object.width-1 do
         for y=object.y,object.y+object.height-1 do
            current_room.grid[x][y].obj = nil
            createEffect( "rubble", ORANGE_WARP, x, y )
         end
      end
   end

   if object.class == "lamp" then
      current_room.lights.lamp = nil
      for x=object.x,object.x+object.width-1 do
         for y=object.y,object.y+object.height-1 do
            current_room.grid[x][y].obj = nil
            createEffect( "rubble", YELLOW_LAMP, x, y )
         end
      end
   end

   if object.class == "whirlwind" then
      for x=object.x,object.x+object.width-1 do
         for y=object.y,object.y+object.height-1 do
            current_room.grid[x][y].obj = nil
            createEffect( "rubble", GREEN_WHIRLWIND, x, y )
         end
      end
   end

   if object.class == "bigbomb" then
      for x=object.x,object.x+object.width-1 do
         for y=object.y,object.y+object.height-1 do
            current_room.grid[x][y].obj = nil
            createEffect( "rubble", BLUE_BOMB, x, y )
         end
      end
   end

   if object.class == "sword" then
      for x=object.x,object.x+object.width-1 do
         for y=object.y,object.y+object.height-1 do
            current_room.grid[x][y].obj = nil
            createEffect( "rubble", VIOLET_SWORD, x, y )
         end
      end
   end

end

function drawObjects()
   if current_room.objects.chains then
      for _,chain in pairs(current_room.objects.chains) do
         local link = current_room.objects[chain.link]
         local lx = link.x + (link.width/2)
         local ly = link.y + (link.height/2)
         gfx.setColor( LIGHT_GRAY )
         gfx.rectangle( "fill", chain.x, chain.y, 1, 1 )
         gfx.setColor( LIGHT_GRAY[1], LIGHT_GRAY[2], LIGHT_GRAY[3], 127 )
         gfx.line( chain.x+0.5, chain.y+0.5, lx+0.5, ly+0.5 )
      end
   end

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

      if object.class == "spikes" then
         gfx.setColor( WHITE )
         if object.facing == "right" or object.facing == "left" then
            for y=object.y,object.y+object.height-2,4 do
               gfx.draw( img_spikes[object.facing], object.x, y )
            end
         else
            for x=object.x,object.x+object.width-2,4 do
               gfx.draw( img_spikes[object.facing], x, object.y )
            end

         end
      end

      if object.class == "block" then
         if object.color == "multicolor" then
            if object.color1 == "red" then gfx.setColor( RED_MAGNET_EDGE ) end
            if object.color1 == "blue" then gfx.setColor( BLUE_BOMB_EDGE ) end
            if object.color1 == "violet" then gfx.setColor( VIOLET_SWORD ) end
            if object.color1 == "black" then gfx.setColor( BLACK ) end

            gfx.rectangle( "fill", object.x, object.y, object.width, object.height )

            if object.color1 == "red" then gfx.setColor( RED_MAGNET ) end
            if object.color1 == "blue" then gfx.setColor( BLUE_BOMB ) end
            if object.color1 == "violet" then gfx.setColor( VIOLET_SWORD_FILL ) end
            if object.color1 == "black" then gfx.setColor( DARK_GRAY ) end

            gfx.rectangle( "fill", object.x+1, object.y+1, object.width-2, object.height-2 )

            if object.color2 == "red" then gfx.setColor( RED_MAGNET_EDGE ) end
            if object.color2 == "blue" then gfx.setColor( BLUE_BOMB_EDGE ) end
            if object.color2 == "violet" then gfx.setColor( VIOLET_SWORD ) end
            if object.color2 == "black" then gfx.setColor( BLACK ) end

            gfx.rectangle( "fill", object.x, object.y,
                                   math.floor(object.width/2), math.floor(object.height/2) )
            gfx.rectangle( "fill", object.x+math.floor(object.width/2), 
                                   object.y+math.floor(object.height/2), 
                                   math.ceil(object.width/2), math.ceil(object.height/2) )

            if object.color2 == "red" then gfx.setColor( RED_MAGNET ) end
            if object.color2 == "blue" then gfx.setColor( BLUE_BOMB ) end
            if object.color2 == "violet" then gfx.setColor( VIOLET_SWORD_FILL ) end
            if object.color2 == "black" then gfx.setColor( DARK_GRAY ) end

            gfx.rectangle( "fill", object.x+1, object.y+1,
                                   math.floor(object.width/2)-1, math.floor(object.height/2)-1 )
            gfx.rectangle( "fill", object.x+math.floor(object.width/2), 
                                   object.y+math.floor(object.height/2), 
                                   math.ceil(object.width/2)-1, math.ceil(object.height/2)-1 )

         else
            if object.color == "red" then gfx.setColor( RED_MAGNET_EDGE ) end
            if object.color == "blue" then gfx.setColor( BLUE_BOMB_EDGE ) end
            if object.color == "violet" then gfx.setColor( VIOLET_SWORD ) end
            if object.color == "black" then gfx.setColor( BLACK ) end

            gfx.rectangle( "fill", object.x, object.y, object.width, object.height )

            if object.color == "red" then gfx.setColor( RED_MAGNET ) end
            if object.color == "blue" then gfx.setColor( BLUE_BOMB ) end
            if object.color == "violet" then gfx.setColor( VIOLET_SWORD_FILL ) end
            if object.color == "black" then gfx.setColor( DARK_GRAY ) end

            gfx.rectangle( "fill", object.x+1, object.y+1, object.width-2, object.height-2 )
         end
      end

      if object.class == "lock" then
         local lock_color = 255 - (object.locks * 25)
         if lock_color < 105 then lock_color = 105 end
         gfx.setColor( WHITE )
         gfx.rectangle( "fill", object.x, object.y, object.width, object.height )
         gfx.setColor( lock_color, lock_color, lock_color )
         gfx.rectangle( "fill", object.x+1, object.y+1, object.width-2, object.height-2 )
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

      if object.class == "torch" then
         gfx.setColor( DARK_GRAY )
         gfx.rectangle( 'fill', object.x, object.y, 5, 5 )

         if object.on then
            gfx.setColor( YELLOW_LAMP )
         else
            gfx.setColor( WALL_SAND )
         end
         gfx.rectangle( 'fill', object.x+1, object.y+1, 3, 3 )
         
         if object.on then
            gfx.setColor( ORANGE_WARP )
         else
            gfx.setColor( RED_MAGNET_EDGE )
         end
         gfx.rectangle( 'fill', object.x+2, object.y+2, 1, 1 )
      end

      if object.class == "flame" then
         gfx.setColor( YELLOW_LAMP )
         gfx.rectangle( 'fill', object.x-1, object.y-1, 3, 3 )
         gfx.setColor( ORANGE_WARP )
         gfx.rectangle( 'fill', object.x, object.y, 1, 1 )
      end

      if object.class == "magnet" then
         gfx.setColor( WHITE )
         gfx.draw( img_magnet, object.x, object.y )
      end
      if object.class == "warp" then
         gfx.setColor( WHITE )
         gfx.draw( img_warp, object.x, object.y )
      end
      if object.class == "lamp" then
         gfx.setColor( WHITE )
         gfx.draw( img_lamp, object.x, object.y )
      end
      if object.class == "whirlwind" then
         gfx.setColor( WHITE )
         gfx.draw( img_whirlwind, object.x, object.y )
      end
      if object.class == "bigbomb" then
         gfx.setColor( WHITE )
         gfx.draw( img_bomb, object.x, object.y )
      end
      if object.class == "sword" then
         gfx.setColor( WHITE )
         gfx.draw( img_sword, object.x, object.y )
      end
   end
end

function drawTriggers()
   for _,trigger in pairs(current_room.triggers) do

      if trigger.class == "button" or trigger.class == "numberbutton" then
         gfx.setColor( LIGHT_GRAY )

         gfx.rectangle( "fill", trigger.x, trigger.y, trigger.width, trigger.height )

         gfx.setColor( BLACK )

         gfx.rectangle( "fill", trigger.x, trigger.y, 1, 1 )
         gfx.rectangle( "fill", trigger.x + trigger.width-1, trigger.y, 1, 1 )
         gfx.rectangle( "fill", trigger.x + trigger.width-1, trigger.y + trigger.height-1, 1, 1 )
         gfx.rectangle( "fill", trigger.x, trigger.y + trigger.height-1, 1, 1 )

         if not trigger.pressed then
            gfx.rectangle( "fill", trigger.x+1, trigger.y+1, trigger.width-2, trigger.height-2 )
            gfx.setColor( LIGHT_GRAY )
            gfx.rectangle( "fill", trigger.x+2, trigger.y+2, trigger.width-4, trigger.height-4 )
         end
      end
   end
end

function removeLocks( object )
   if object.targets then
      for index,t in pairs(object.targets) do
         local target = current_room.objects[t]
         if not target then target = current_room.enemies[t] end
         singleRemoveLock( target ) 
      end
   end
end

function addLocks( object )
   if object.targets then
      for index,t in pairs(object.targets) do
         local target = current_room.objects[t]
         if not target then target = current_room.enemies[t] end
         singleAddLock( target ) 
      end
   end
end

function singleAddLock( lock )
   if lock and lock.locks then lock.locks = lock.locks + 1 end
end

function singleRemoveLock( lock )
   if not lock then return end

   if lock.locks then lock.locks = lock.locks - 1 end

   if lock.class == "torch" then
      lock.timeout = nil
      lock.to_timeout = nil
   end

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

      createEffect( "explosion", DARK_GRAY, lock.x, lock.y )
   end

   if lock.class == "boss1" then
      game_state = "boss1opening"
      game_state_timer = BOSS1_OPENING_TIMER * 4
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

         removeLocks( lock )
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
                  flamecount = 0,
                  objects = { },
                  enemies = { },
                  triggers = { },
                  effects = { },
                  images = { },
                  lights = { },
                  numbers = { },
                  number = 0,
                }

   if input.darkness then room.darkness = input.darkness
   else room.darkness = 0 end

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
            if door.closed_on and player.unlocked[door.closed_on] then
               -- door is closed - used for boss rooms
               if door.side == 'up' then
                  for i=door.start,door.finish do
                     room.grid[i][1] = { id=nil }
                  end
               elseif door.side == 'down' then
                  for i=door.start,door.finish do
                     room.grid[i][room.height-2] = { id=nil }
                  end
               elseif door.side == 'right' then
                  for j=door.start,door.finish do
                     room.grid[room.width-2][j] = { id=nil }
                  end
               elseif door.side == 'left' then
                  for j=door.start,door.finish do
                     room.grid[1][j] = { id=nil }
                  end
               end
            elseif door.hidden then
               -- door is hidden... until later
               room.hiddendoor = shallowcopy( door )
            else
               if door.side == 'stairs' then
                  for x=door.x,door.x+6 do
                     for y=door.y,door.y+6 do
                        room.grid[x][y] = { id='stairs', side=door.side, to=door.to, to_x=door.to_x, to_y=door.to_y }
                     end
                  end
                  room.effects[id_cnt] = { class='stairs', dir=door.dir, x=door.x, y = door.y }
                  id_cnt = id_cnt + 1
               elseif door.side == 'up' then
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
      end

      if input.floor then
         for _,geometry in pairs(input.floor) do

            if geometry.style == 'image' then
               table.insert(room.images, { class="image", image=gfx.newImage( geometry.source ), x=geometry.x, y=geometry.y })
            end

            if geometry.style == 'text' then
               table.insert(room.images, { class="text", text=gfx.newText( font, geometry.text ), x=geometry.x, y=geometry.y })
            end

            if geometry.style == 'rectangle' then
               for x=geometry.x,geometry.x+geometry.width-1 do
                  for y=geometry.y,geometry.y+geometry.height-1 do
                     room.grid[x][y] = { id=geometry.mark }
                  end
               end
            end

            if geometry.style == 'spottedrectangle' then
               for x=geometry.x,geometry.x+geometry.width-1 do
                  for y=geometry.y,geometry.y+geometry.height-1 do
                     if (x + y) % 2 == 0 then
                        room.grid[x][y] = { id=geometry.mark }
                     end
                  end
               end
            end

            if geometry.style == 'line' then
               local cur = {}
               cur.x = geometry.x
               cur.y = geometry.y
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

            if geometry.style == "altar" then
               for x=19,44 do
                  for y=9,34 do
                     room.grid[x][y] = { id="white" }
                  end
               end
               for x=29,34 do
                  for y=27,39 do
                     if y % 2 == 0 then
                        room.grid[x][y] = { id="white" }
                     else
                        room.grid[x][y] = { id="drawing" }
                     end
                  end
               end
               -- Outer edge
               for x=19,44 do
                  room.grid[x][9] = { id="black" }
               end
               for y=9,34 do
                  room.grid[19][y] = { id="black" }
                  room.grid[44][y] = { id="black" }
               end
               for x=19,28 do
                  room.grid[x][34] = { id="black" }
               end
               for x=35,44 do
                  room.grid[x][34] = { id="black" }
               end
               -- Inner edge
               for x=25,38 do
                  room.grid[x][15] = { id="black" }
               end
               for y=15,28 do
                  room.grid[25][y] = { id="black" }
                  room.grid[38][y] = { id="black" }
               end
               for x=25,28 do
                  room.grid[x][28] = { id="black" }
               end
               for x=35,38 do
                  room.grid[x][28] = { id="black" }
               end
               -- Corners
               for x=19,25 do
                  room.grid[x][x-10] = { id="black" }
                  room.grid[x][53-x] = { id="black" }
               end
               for x=38,44 do
                  room.grid[x][53-x] = { id="black" }
                  room.grid[x][x-10] = { id="black" }
               end
               -- Ramp
               for y=27,39 do
                  room.grid[28][y] = { id="black" }
                  room.grid[35][y] = { id="black" }
               end 
            end

            -- Custom shapes! Scatter these around ;D
            -- magnet, warpdot, lamp, whirlwind, bomb, sword
            -- miasmamark, chain,
            -- cat, fish, deer, scarab,
            -- eye, ankh, apple, heart,
            -- invader, companion,
            if geometry.style == "magnet" then
               for y=geometry.y,geometry.y+6 do
                  room.grid[geometry.x + 0][y] = { id=geometry.mark }
                  room.grid[geometry.x + 1][y] = { id=geometry.mark }
                  room.grid[geometry.x + 2][y] = { id=geometry.mark }
                  room.grid[geometry.x + 5][y] = { id=geometry.mark }
                  room.grid[geometry.x + 6][y] = { id=geometry.mark }
                  room.grid[geometry.x + 7][y] = { id=geometry.mark }
               end
               room.grid[geometry.x + 1][geometry.y + 1] = { id=nil }
               room.grid[geometry.x + 6][geometry.y + 1] = { id=nil }
               for x=geometry.x+1,geometry.x+6 do
                  room.grid[x][geometry.y+5] = { id=geometry.mark }
                  room.grid[x][geometry.y+6] = { id=geometry.mark }
                  room.grid[x][geometry.y+7] = { id=geometry.mark }
               end
            end

            if geometry.style == "lamp" then
               room.grid[geometry.x + 0][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 7] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 7] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 7] = { id=geometry.mark }
            end

            if geometry.style == "whirlwind" then
               for x=geometry.x+1,geometry.x+6 do
                  room.grid[x][geometry.y + 0] = { id=geometry.mark }
                  room.grid[x][geometry.y + 7] = { id=geometry.mark }
               end
               for x=geometry.x+1,geometry.x+4 do
                  room.grid[x][geometry.y + 2] = { id=geometry.mark }
               end
               for y=geometry.y+1,geometry.y+6 do
                  room.grid[geometry.x + 7][y] = { id=geometry.mark }
               end
               for y=geometry.y+3,geometry.y+6 do
                  room.grid[geometry.x + 0][y] = { id=geometry.mark }
               end
               room.grid[geometry.x + 5][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 4] = { id=geometry.mark }
            end

            if geometry.style == "sword" then
               room.grid[geometry.x + 6][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 6] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 7] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 7] = { id=geometry.mark }
            end

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

            if geometry.style == "miasmamark" then
               room.grid[geometry.x + 0][geometry.y - 1] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y - 2] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x - 2][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x - 1][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 0] = { id=geometry.mark }
            end

            if geometry.style == "chain" then
               room.grid[geometry.x + 1][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 0] = { id=geometry.mark }

               room.grid[geometry.x + 0][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 9][geometry.y + 1] = { id=geometry.mark }

               room.grid[geometry.x + 1][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 2] = { id=geometry.mark }

            end

            if geometry.style == "warpdot" then
               room.grid[geometry.x + 0][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 2] = { id=geometry.mark }
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

            if geometry.style == "snake" then

            end

            if geometry.style == "fish" then
               room.grid[geometry.x + 0][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 9][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 2][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 5][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 7][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 4] = { id=geometry.mark }
               room.grid[geometry.x + 9][geometry.y + 5] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 2] = { id=geometry.mark }
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

            if geometry.style == "kirby" then
               room.grid[geometry.x + 1][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 0][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 1][geometry.y + 4] = { id=geometry.mark }

               room.grid[geometry.x + 3][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 4][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 3][geometry.y + 3] = { id=geometry.mark }

               room.grid[geometry.x + 6][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 6][geometry.y + 1] = { id=geometry.mark }

               room.grid[geometry.x + 8][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 8][geometry.y + 1] = { id=geometry.mark }

               room.grid[geometry.x + 10][geometry.y + 0] = { id=geometry.mark }
               room.grid[geometry.x + 11][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 11][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 11][geometry.y + 3] = { id=geometry.mark }
               room.grid[geometry.x + 10][geometry.y + 4] = { id=geometry.mark }

               room.grid[geometry.x + 13][geometry.y + 1] = { id=geometry.mark }
               room.grid[geometry.x + 14][geometry.y + 2] = { id=geometry.mark }
               room.grid[geometry.x + 13][geometry.y + 3] = { id=geometry.mark }
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
               if (not object.cleared) or room.regenerate then
                  local obj = shallowcopy( object )
                  room.objects[obj.id] = obj

                  for x=obj.x,obj.x+obj.width-1 do
                     for y=obj.y,obj.y+obj.height-1 do
                        room.grid[x][y].obj = obj
                     end
                  end 
               end
            end

            if object.class == "torch" then
               local obj = shallowcopy( object )
               room.objects[obj.id] = obj
               for x=obj.x,obj.x+4 do
                  for y=obj.y,obj.y+4 do
                     room.grid[x][y].obj = obj
                  end
               end 
               obj.width = 5
               obj.height = 5

               if obj.on then lightTorch( obj, room ) end
            end
            
            if object.class == "spikes" then
               local obj = shallowcopy( object )
               room.objects[obj.id] = obj
               if obj.facing == "right" or obj.facing == "left" then
                  obj.width = 4
                  if (obj.height - 1) % 4 ~= 0 then
                     obj.height = obj.height - ((obj.height - 1) % 4)
                  end
               else
                  obj.height = 4
                  if (obj.width - 1) % 4 ~= 0 then
                     obj.width = obj.width - ((obj.width - 1) % 4)
                  end
               end
               for x=obj.x,obj.x+obj.width-1 do
                  for y=obj.y,obj.y+obj.height-1 do
                     room.grid[x][y].obj = obj
                  end
               end
            end

            if object.class == "chain" then
               local obj = shallowcopy( object )
               obj.passable = true
               if not room.objects.chains then room.objects.chains = { } end
               room.objects.chains[obj.id] = obj
            end

            if object.class == "magnet" then
               if not player.unlocked[1] then
                  local obj = shallowcopy( object )
                  room.objects[obj.id] = obj

                  for x=obj.x,obj.x+obj.width-1 do
                     for y=obj.y,obj.y+obj.height-1 do
                        room.grid[x][y].obj = obj
                     end
                  end
               else
                  openHiddenDoor( room, 1 )
                  openHiddenDoor( room, 2 )
               end
            end
            if object.class == "warp" then
               if not player.unlocked[2] then
                  local obj = shallowcopy( object )
                  room.objects[obj.id] = obj

                  for x=obj.x,obj.x+obj.width-1 do
                     for y=obj.y,obj.y+obj.height-1 do
                        room.grid[x][y].obj = obj
                     end
                  end
               else
                  openHiddenDoor( room, 1 )
                  openHiddenDoor( room, 2 )
               end
            end
            if object.class == "lamp" then
               if not player.unlocked[3] then
                  local obj = shallowcopy( object )
                  room.objects[obj.id] = obj
                  room.lights[obj.id] = { id="lamp", x=obj.x + 3, y = obj.y + 3, power = 20, pure = 5 }

                  for x=obj.x,obj.x+obj.width-1 do
                     for y=obj.y,obj.y+obj.height-1 do
                        room.grid[x][y].obj = obj
                     end
                  end
               else
                  openHiddenDoor( room, 1 )
                  openHiddenDoor( room, 2 )
               end
            end
            if object.class == "whirlwind" then
               if not player.unlocked[4] then
                  local obj = shallowcopy( object )
                  room.objects[obj.id] = obj

                  for x=obj.x,obj.x+obj.width-1 do
                     for y=obj.y,obj.y+obj.height-1 do
                        room.grid[x][y].obj = obj
                     end
                  end
               else
                  openHiddenDoor( room, 1 )
                  openHiddenDoor( room, 2 )
               end
            end
            if object.class == "bigbomb" then
               if not player.unlocked[5] then
                  local obj = shallowcopy( object )
                  room.objects[obj.id] = obj

                  for x=obj.x,obj.x+obj.width-1 do
                     for y=obj.y,obj.y+obj.height-1 do
                        room.grid[x][y].obj = obj
                     end
                  end
               else
                  openHiddenDoor( room, 1 )
                  openHiddenDoor( room, 2 )
               end
            end
            if object.class == "sword" then
               if not player.unlocked[6] then
                  local obj = shallowcopy( object )
                  room.objects[obj.id] = obj

                  for x=obj.x,obj.x+obj.width-1 do
                     for y=obj.y,obj.y+obj.height-1 do
                        room.grid[x][y].obj = obj
                     end
                  end
               else
                  openHiddenDoor( room, 1 )
                  openHiddenDoor( room, 2 )
               end
            end

         end
      end

      if input.enemies then
         for _,enemy in pairs(input.enemies) do

            if enemy.class == "blob" then
               local e = shallowcopy(enemy)

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

            if enemy.class == "archer" then
               local e = shallowcopy(enemy)

               e.width = ARCHER_WIDTH
               e.height = ARCHER_HEIGHT
               e.facing = "down"

               e.state = "idle"
               e.state_timer = ARCHER_IDLE_TIMER
               
               room.enemies[e.id] = e
            end

            if enemy.class == "boss1" then
               local e = { id="boss1", class="boss1", x=enemy.x, y=enemy.y,
                           width = 8, height = 8, facing = "right",
                           state = "sleeping", state_timer = BOSS1_BASIC_TIMER,
                           damage = 1, damage_flashes = 0, damage_flash_timer = 0,
                           anim_state = 1, anim_timer = BOSS1_BASIC_TIMER,
                           explodable = true,
                        }
               room.enemies[e.id] = e
            end
            
      end end

      if input.triggers then
         for _,trigger in pairs(input.triggers) do

            if trigger.class == "button" then
               local trig = shallowcopy( trigger )
               trig.pressed = false
               room.triggers[trig.id] = trig 
            end

            if trigger.class == "numberbutton" then
               local trig = shallowcopy( trigger )
               trig.pressed = false
               room.triggers[trig.id] = trig 
               room.numbers[trig.number] = trig
            end

            if trigger.class == "area" then
               local trig = shallowcopy( trigger )
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
                  if current_room.grid[x][y].id ~= 'wall' 
                     and not (current_room.grid[x][y].obj and 
                             (current_room.grid[x][y].obj.class == "lock"
                             or current_room.grid[x][y].obj.class == "block")) then 
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
   local killed = { }

   if current_room.objects.chains then
      for _,chain in pairs(current_room.objects.chains) do
         if chain.class == "chain" then
            -- Pull the attached object towards the origin
            local link = current_room.objects[chain.link]
            if not link.velocity then 
               link.velocity = { x=0, y=0 } 
               link.x_move_ticks = 0
               link.y_move_ticks = 0
            end
            local dx = chain.x - (link.x + ((link.width-1)/2))
            local dy = chain.y - (link.y + ((link.height-1)/2))
            local dsum = math.abs(dx) + math.abs(dy)

            local r2 = chain.length * chain.length
            local dsquared = (dx * dx) + (dy * dy)
            if math.random() < (dsquared / r2) then
               if math.random() < (math.abs(dx) / dsum) then
                  local dxv = -1
                  if dx > 0 then dxv = 1 end
                  link.velocity.x = link.velocity.x + dxv 
               else
                  local dyv = -1
                  if dy > 0 then dyv = 1 end
                  link.velocity.y = link.velocity.y + dyv
               end
            end
         end
      end
   end

   for _,object in pairs(current_room.objects) do

      if object.class == "flame" then
         object.timeout = object.timeout - 1

         if object.timeout == 0 then
            destroyed[object.id] = object
         end

         if object.timeout <= FLAME_FADE_TIME then
            object.power = math.floor(object.timeout / FLAME_FADE_SPEED)
         end
         
         -- TODO flicker

      end

      if object.class == "torch" and object.timeout then
         object.timeout = object.timeout - 1

         if object.timeout == 0 then
            quenchTorch( object )
         end
         
         -- TODO flicker

      end

      if object.class == "bomb" then

         object.timer = object.timer - 1

         if object.timer <= 0 then
            -- Explode
            destroyed.bomb = object

            for x=object.x-2,object.x+4 do
               for y=object.y-2,object.y+4 do
                  if x >= 0 and y >= 0 and x < current_room.width and y < current_room.height and
                     current_room.grid[x][y].obj and current_room.grid[x][y].obj.bombable then
                     local obj = current_room.grid[x][y].obj
                     destroyed[ obj.id ] = obj
            end end end

            local explosion = { x = object.x-2, y = object.y-2, width = 7, height = 7 }
            for _,enemy in pairs(current_room.enemies) do
               if enemy.bombable and intersects( enemy, explosion ) then
                  killed[enemy.id] = enemy
               end
            end

         else

            local vel = object.velocity

            if vel.x ~= 0 then
               object.x_move_ticks = object.x_move_ticks + 1
               if object.x_move_ticks >= math.floor(VELOCITY_INVERSE / math.abs(vel.x)) then
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
               if object.y_move_ticks >= math.floor(VELOCITY_INVERSE / math.abs(vel.y)) then
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
               if object.x_move_ticks >= math.floor(VELOCITY_INVERSE / math.abs(vel.x)) then
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
               if object.y_move_ticks >= math.floor(VELOCITY_INVERSE / math.abs(vel.y)) then
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

         local move_chance = BLOB_MOVE_CHANCE
         if dsum < 100 then 
            move_chance = move_chance + ((10 - math.sqrt(dsum)) * BLOB_MOVE_CHANCE_MODIFIER / 10)
         end

         if math.random() < move_chance then
            if math.random(dsum) <= math.abs(dx) then
               if dx > 0 then enemy.velocity.x = enemy.velocity.x + 1
               else enemy.velocity.x = enemy.velocity.x - 1 end
            else
               if dy > 0 then enemy.velocity.y = enemy.velocity.y + 1
               else enemy.velocity.y = enemy.velocity.y - 1 end
            end
         end
      end

      if enemy.class == "archer" then
         local dx = (player.x + 1) - (enemy.x + 4)
         local dy = (player.y + 1) - (enemy.y + 4)
         local dsum = math.abs(dx) + math.abs(dy)

         -- If idle, walk in random directions
         -- If 'sees' player in a sightline, fire an arrow
         -- If player gets close, run away
         if dsum <= ARCHER_FLEE_RADIUS and enemy.state ~= "fire" then 
            enemy.state = "flee" 
         end

         if enemy.state == "pause" then
            enemy.state_timer = enemy.state_timer - 1
            if enemy.state_timer == 0 then
               enemy.state = "idle"
               enemy.state_timer = ARCHER_IDLE_TIMER
               enemy.facing = randomDirection()
            end
         end

         if enemy.state == "flee" then
            if dsum > ARCHER_FLEE_RADIUS then
               enemy.state = "idle"
               enemy.state_timer = ARCHER_IDLE_TIMER
            else
               -- Turn away from player
               local ratio = math.abs(dx / dy)
               if math.abs(dx) >= math.abs(dy) then
                  if dx < 0 then enemy.facing = "right" else enemy.facing = "left" end
                  ratio = math.abs(dy / dx)
               else
                  if dy < 0 then enemy.facing = "down" else enemy.facing = "up" end
               end
               enemy.state_timer = enemy.state_timer - 1
               if enemy.state_timer == 0 then
                  enemy.state_timer = ARCHER_FLEE_TIMER
                  -- Move
                  local dx1 = 0
                  local dy1 = 0
                  if dx < 0 then dx1 = 1 elseif dx > 0 then dx1 = -1 end
                  if dy < 0 then dy1 = 1 elseif dy > 0 then dy1 = -1 end
                  if math.abs(dx) >= math.abs(dy) then
                     if math.random() > ratio then dy1 = 0 end
                  else
                     if math.random() > ratio then dx1 = 0 end
                  end

                  if not moveEnemy( enemy, dx1, dy1 ) then 
                     local can_move = true
                     if math.abs(dx) >= math.abs(dy) then
                        can_move = moveEnemy( enemy, dx1, 0 )
                     else
                        can_move = moveEnemy( enemy, 0, dy1 )
                     end
                  end
               end
            end
         end

         if enemy.state == "idle" or enemy.state == "cooldown" then
            enemy.state_timer = enemy.state_timer - 1
            if enemy.state_timer == 0 then
               if not moveEnemyForward( enemy ) or math.random() < ARCHER_PAUSE_CHANCE then
                  enemy.state = "pause"
                  enemy.state_timer = ARCHER_PAUSE_TIMER
               else
                  enemy.state_timer = ARCHER_IDLE_TIMER
               end
            end
         end

         if enemy.state ~= "fire" and enemy.state ~= "cooldown" and 
            ((enemy.state ~= "flee" and math.random() < ARCHER_FIRE_CHANCE)
            or (enemy.state == "flee" and math.random() * 2 < ARCHER_FIRE_CHANCE)) then
            -- Check if player is in sightline
            local lr_sight = { x = 0, y = enemy.y+2, width = current_room.width, height = enemy.height-4 }
            if intersects( player, lr_sight ) then
               if player.x < enemy.x then
                  enemy.facing = "left"
               else
                  enemy.facing = "right"
               end
               enemy.state = "fire"
               enemy.state_timer = ARCHER_FIRE_TIMER * 2
            end
            local ud_sight = { x = enemy.x+2, y = 0, width = enemy.width-4, height = current_room.height }
            if intersects( player, ud_sight ) then
               if player.y < enemy.y then
                  enemy.facing = "up"
               else
                  enemy.facing = "down"
               end
               enemy.state = "fire"
               enemy.state_timer = ARCHER_FIRE_TIMER * 2
            end
         end

         if enemy.state == "fire" then
            enemy.state_timer = enemy.state_timer - 1
            if enemy.state_timer == ARCHER_FIRE_TIMER then
               -- Fire
               if enemy.facing == "up" then
                  fireArrow( enemy.x+3, enemy.y-2, enemy.facing, enemy.color )
               elseif enemy.facing == "down" then
                  fireArrow( enemy.x+3, enemy.y+enemy.height+1, enemy.facing, enemy.color )
               elseif enemy.facing == "left" then
                  fireArrow( enemy.x-2, enemy.y+3, enemy.facing, enemy.color )
               elseif enemy.facing == "up" then
                  fireArrow( enemy.x+enemy.width+1, enemy.y+3, enemy.facing, enemy.color )
               end
            elseif enemy.state_timer == 0 then
               enemy.state = "cooldown"
               enemy.state_timer = ARCHER_IDLE_TIMER
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
            if enemy.x_move_ticks >= math.floor(VELOCITY_INVERSE / math.abs(vel.x)) then
               enemy.x_move_ticks = 0
               
               -- Try to move
               if (vel.x > 0) then
                  if (moveEnemy( enemy, 1, 0 )) then
                     -- success
                     if not enemy.frictionless then
                        vel.x = vel.x - 1
                     end
                  else 
                     -- collision 
                     vel.x = 0
                  end
               end
               if (vel.x < 0) then
                  if (moveEnemy( enemy, -1, 0 )) then
                     -- success
                     if not enemy.frictionless then
                        vel.x = vel.x + 1
                     end
                  else 
                     -- collision 
                     vel.x = 0
         end end end end

         if vel.y ~= 0 then
            enemy.y_move_ticks = enemy.y_move_ticks + 1
            if enemy.y_move_ticks >= math.floor(VELOCITY_INVERSE / math.abs(vel.y)) then
               enemy.y_move_ticks = 0
               
               -- Try to move
               if (vel.y > 0) then
                  if (moveEnemy( enemy, 0, 1 )) then
                     -- success
                     if not enemy.frictionless then
                        vel.y = vel.y - 1
                     end
                  else 
                     -- collision 
                     vel.y = 0
                  end
               end
               if (vel.y < 0) then
                  if (moveEnemy( enemy, 0, -1 )) then
                     -- success
                     if not enemy.frictionless then
                        vel.y = vel.y + 1
                     end
                  else 
                     -- collision 
                     vel.y = 0
         end end end end

      end

      if enemy.class == "arrow" then
         arrowRotate( enemy )
         if (math.abs(enemy.velocity.x) + math.abs(enemy.velocity.y)) < (ARROW_SPEED / 3)
            and not (player.magnet_target and player.magnet_target.id == enemy.id) then
            killed[enemy.id] = enemy
         end
      end

      if enemy.class == "boss1" then
         if enemy.damage_flashes > 0 then
            enemy.damage_flash_timer = enemy.damage_flash_timer - 1
            if enemy.damage_flash_timer == 0 then
               enemy.damage_flashes = enemy.damage_flashes - 1

               if enemy.damage_flashes == 0 then
                  enemy.explodable = true
               else
                  enemy.damage_flash_timer = 2 * BOSS1_FLASH_TIMER
               end
            end
         end

         if enemy.state == "walking" then
            local dx = (player.x + 1) - (enemy.x + 4)
            local dy = (player.y + 1) - (enemy.y + 4)
            local will_swing = false

            -- Turn to player
            local ratio = math.abs(dx / dy)
            if math.abs(dx) >= math.abs(dy) then
               if dx < 0 then enemy.facing = "left" else enemy.facing = "right" end
               ratio = math.abs(dy / dx)
            else
               if dy < 0 then enemy.facing = "up" else enemy.facing = "down" end
            end

            -- Move
            enemy.state_timer = enemy.state_timer - 1
            if enemy.state_timer == 0 then
               if enemy.damage < 3 then
                  enemy.state_timer = BOSS1_BASIC_TIMER
               else
                  enemy.state_timer = BOSS1_FAST_TIMER
               end

               -- Move
               local dx1 = 0
               local dy1 = 0
               if dx < 0 then dx1 = -1 elseif dx > 0 then dx1 = 1 end
               if dy < 0 then dy1 = -1 elseif dy > 0 then dy1 = 1 end
               if math.abs(dx) >= math.abs(dy) then
                  if math.random() > ratio then dy1 = 0 end
               else
                  if math.random() > ratio then dx1 = 0 end
               end

               if not moveEnemy( enemy, dx1, dy1 ) then will_swing = true end
            end

            -- If player in range or blocked, swing
            if will_swing or ((dx * dx) + (dy * dy)) < (BOSS1_SWORD_LENGTH * BOSS1_SWORD_LENGTH) then
               enemy.state = "swingprep"
               if enemy.damage < 3 then
                  enemy.state_timer = BOSS1_BASIC_TIMER * 5
               else
                  enemy.state_timer = BOSS1_FAST_TIMER * 5
               end
            end
         end

         if enemy.state == "swingprep" then
            enemy.state_timer = enemy.state_timer - 1
            if enemy.state_timer == 0 then

               enemySwingSword( enemy )

               enemy.state = "swinging"

               if enemy.damage < 3 then
                  enemy.state_timer = BOSS1_BASIC_TIMER * 5
               else
                  enemy.state_timer = BOSS1_FAST_TIMER * 5
               end
            end
         end

         if enemy.state == "swinging" then
            enemy.state_timer = enemy.state_timer - 1
            if enemy.state_timer == 0 then
               enemy.state = "walking"
               if enemy.damage < 3 then
                  enemy.state_timer = BOSS1_BASIC_TIMER
               else
                  enemy.state_timer = BOSS1_FAST_TIMER
               end
            end
         end
      end

   end

   -- Triggers
   for _,trigger in pairs(current_room.triggers) do

      if (trigger.class == "button" or trigger.class == "numberbutton")
         and trigger.targets and trigger.targets ~= { } then
         local pressed = false

         for _,obj in pairs(current_room.objects) do
            if obj.class == "block" and
               trigger.x <= obj.x + obj.width-1 and trigger.x + trigger.width-1 >= obj.x
               and trigger.y <= obj.y + obj.height-1 and trigger.y + trigger.height-1 >= obj.y then
               pressed = true
            end 
         end
         if player.x <= trigger.x + trigger.width-1 and player.x + 2 >= trigger.x
            and player.y <= trigger.y + trigger.height-1 and player.y + 2 >= trigger.y then
            pressed = true
         end

         if pressed and not trigger.pressed then
            if trigger.class == "numberbutton" then
               if current_room.number == trigger.number - 1 then
                  current_room.number = trigger.number
                  trigger.pressed = true
                  removeLocks( trigger )
               else
                  -- Wrong order
                  for n=1,current_room.number do
                     local t = current_room.numbers[n]
                     t.pressed = false
                     addLocks( t )
                  end
                  current_room.number = 0
               end
            else
               trigger.pressed = true
               removeLocks( trigger )
            end
         elseif not pressed and trigger.pressed and trigger.class ~= "numberbutton" then
            trigger.pressed = false
            addLocks( trigger )
         end
      end

      if trigger.class == "area" then
         if not trigger.activated and intersects( trigger, player ) then
            trigger.activated = true

            removeLocks( trigger )
         end
      end

   end

   if current_room.wind then
      local wind = current_room.wind
      wind.move_ticks = wind.move_ticks - 1
      if wind.move_ticks == 0 then
         if wind.turning then
            wind.turning = nil
            if wind.dir == "up" then wind.dir = "right"
            elseif wind.dir == "right" then wind.dir = "down"
            elseif wind.dir == "down" then wind.dir = "left"
            else wind.dir = "up" end

            local temp = wind.width
            wind.width = wind.height
            wind.height = temp

            wind.turns = wind.turns + 1
         else
            windPush()
            if wind.x < 0 or wind.y < 0 or wind.x >= current_room.width or wind.y >= current_room.height then
               current_room.wind = nil
            end
         end
         wind.move_ticks = WIND_TIMER
      end
   end

   -- Destruction
   for _,object in pairs(destroyed) do
      destroyObject( object )
   end

   for _,enemy in pairs(killed) do
      destroyEnemy( enemy )
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
            gfx.setColor( WHITE )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         elseif current_room.grid[i][j].id == 'stairs' then 
            gfx.setColor( FLOOR_SAND )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         elseif current_room.grid[i][j].id == 'black' then 
            gfx.setColor( BLACK )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         elseif current_room.grid[i][j].id == 'drawing' then 
            gfx.setColor( DRAWING_SAND )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         elseif current_room.grid[i][j].id == 'white' then 
            gfx.setColor( WHITE_SAND )
            gfx.rectangle( 'fill', i, j, 1, 1 ) 
         end

      end
   end
end

function openHiddenDoor( room, step )
   local door = room.hiddendoor
   if not door then return end

   if door.side == 'up' then
      for i=door.start,door.finish do
         if step == 1 then
            room.grid[i][1] = { id=nil }
            createEffect( "rubble", WALL_SAND, i, 1, room )
         else
            room.grid[i][0] = { id='door', side=door.side, to=door.to, to_x=door.to_x, to_y=door.to_y }
            createEffect( "rubble", WALL_SAND, i, 0, room )
         end
      end
   elseif door.side == 'down' then
      for i=door.start,door.finish do
         if step == 1 then
            room.grid[i][room.height-2] = { id=nil }
            createEffect( "rubble", WALL_SAND, i, room.height-2, room )
         else
            room.grid[i][room.height-1] = { id='door', side=door.side, to=door.to, to_x=door.to_x, to_y=door.to_y }
            createEffect( "rubble", WALL_SAND, i, room.height-1, room )
         end
      end
   elseif door.side == 'right' then
      for j=door.start,door.finish do
         if step == 1 then
            room.grid[room.width-2][j] = { id=nil }
            createEffect( "rubble", WALL_SAND, room.width-2, j, room )
         else
            room.grid[room.width-1][j] = { id='door', side=door.side, to=door.to, to_x=door.to_x, to_y=door.to_y }
            createEffect( "rubble", WALL_SAND, room.width-1, j, room )
         end
      end
   elseif door.side == 'left' then
      for j=door.start,door.finish do
         room.grid[0][j] = { id='door', side=door.side, to=door.to, to_x=door.to_x, to_y=door.to_y }
         room.grid[1][j] = { id=nil }
         if step == 1 then
            room.grid[1][j] = { id=nil }
            createEffect( "rubble", WALL_SAND, 1, j, room )
         else
            room.grid[0][j] = { id='door', side=door.side, to=door.to, to_x=door.to_x, to_y=door.to_y }
            createEffect( "rubble", WALL_SAND, 0, j, room )
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

function moveEnemyForward( enemy )
   if not enemy.facing then return false end

   local dx = 0
   local dy = 0
   if enemy.facing == "up" then dy = -1 end
   if enemy.facing == "down" then dy = 1 end
   if enemy.facing == "left" then dx = -1 end
   if enemy.facing == "right" then dx = 1 end

   return moveEnemy( enemy, dx, dy )
end

function moveEnemy( enemy, dx, dy )
   local new_x = enemy.x + dx
   local new_y = enemy.y + dy

   -- Check collisions
   local collides = objectStaticCollisions( enemy, new_x, new_y )

   if (not collides) or (collides.hit == "white" and enemy.passable ) then
      enemy.x = new_x
      enemy.y = new_y

      if player.state == "magnet" and not (player.magnet_target) then
         getMagnetTarget()
      end

      return true
   end

   if collides.hit == 'player' then
      -- Dead
      killPlayer()
   end

   if collides.hit == 'enemy' and enemy.class == "arrow" then
      if collides.enemy.color and collides.enemy.color == enemy.color then
         destroyEnemy( collides.enemy )
      end
   end

   if collides.hit == 'spikes' or enemy.class == "arrow" then
      destroyEnemy( enemy )
   end

   return false
end

function fireArrow( x, y, dir, color )
   if not color then color = "black" end

   local arrow = { id=id_cnt, class="arrow", color=color, x=x, y=y, width=3, height=3, passable=true, frictionless = true }
   id_cnt = id_cnt + 1

   arrow.velocity = { x = 0, y = 0 }
   if dir == "up" then arrow.velocity.y = -ARROW_SPEED
   elseif dir == "down" then arrow.velocity.y = ARROW_SPEED
   elseif dir == "left" then arrow.velocity.x = -ARROW_SPEED
   elseif dir == "right" then arrow.velocity.x = ARROW_SPEED end
   arrow.x_move_ticks = 0
   arrow.y_move_ticks = 0

   arrowRotate( arrow )

   if arrow.color == "red" then arrow.magnetic = true end

   current_room.enemies[arrow.id] = arrow
end

function arrowRotate( arrow )
   local dx = arrow.velocity.x
   local dy = arrow.velocity.y
   if math.abs(dx) > math.abs(dy) then
      if dx < 0 then arrow.facing = "left" else arrow.facing = "right" end
   else
      if dy < 0 then arrow.facing = "up" else arrow.facing = "down" end
   end
end

function destroyEnemy( enemy )

   if enemy.class == "boss1" then
      enemy.damage = enemy.damage + 1

      enemy.explodable = false
      enemy.damage_flashes = BOSS1_NUM_FLASHES
      enemy.damage_flash_timer = BOSS1_FLASH_TIMER

      if enemy.damage == 5 then
         -- VICTORY

         createEffect( "boss1death", BLACK, enemy.x, enemy.y )

         current_room.enemies[enemy.id] = nil
      end

      return
   end

   current_room.enemies[enemy.id] = nil

   removeLocks( enemy )

   if enemy.class == "blob" then

      local color = WHITE
      if enemy.color == "red" then color = RED_MAGNET end
      if enemy.color == "green" then color = GREEN_WHIRLWIND end
      if enemy.color == "blue" then color = BLUE_BOMB end
      if enemy.color == "violet" then color = VIOLET_SWORD end

      for x=enemy.x,enemy.x+enemy.width-1 do
         for y=enemy.y,enemy.y+enemy.height-1 do 
            createEffect( "rubble", color, x, y )
         end
      end
   end

   if enemy.class == "archer" then

      local color = DARK_GRAY

      for x=enemy.x+1,enemy.x+enemy.width-2 do
         for y=enemy.y+1,enemy.y+enemy.height-2 do 
            createEffect( "rubble", color, x, y )
         end
      end
   end

   if enemy.class == "arrow" then
      local color = BLACK
      if enemy.color == "red" then color = RED_MAGNET end
      local xmin = enemy.x + 1
      local xmax = xmin
      local ymin = enemy.y + 1
      local ymax = ymin
      if enemy.facing == "up" then ymax = ymin + 4
      elseif enemy.facing == "down" then ymin = ymin - 4
      elseif enemy.facing == "left" then xmax = xmax + 4
      elseif enemy.facing == "right" then xmin = xmin - 4 end
      for x=xmin,xmax do
         for y=ymin,ymax do
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
            elseif enemy.color == "red" then gfx.draw( img_blobred1, enemy.x, enemy.y )
            elseif enemy.color == "blue" then gfx.draw( img_blobblue1, enemy.x, enemy.y )
            elseif enemy.color == "violet" then gfx.draw( img_blobviolet1, enemy.x, enemy.y ) end
         else
            if enemy.color == "black" then gfx.draw( img_blobblack2, enemy.x, enemy.y )
            elseif enemy.color == "red" then gfx.draw( img_blobred2, enemy.x, enemy.y )
            elseif enemy.color == "blue" then gfx.draw( img_blobblue2, enemy.x, enemy.y )
            elseif enemy.color == "violet" then gfx.draw( img_blobviolet2, enemy.x, enemy.y ) end
         end 
      end

      if enemy.class == "archer" then
         translateRotate( enemy.x+(enemy.width/2), enemy.y+(enemy.height/2), enemy.facing )
         
         if enemy.state == "fire" then
            gfx.setColor( WHITE )
            if enemy.color == "red" then
               gfx.draw( img_archerred2, -(enemy.width/2), -(enemy.height/2) )
            else
               gfx.draw( img_archerblack2, -(enemy.width/2), -(enemy.height/2) )
            end
            if enemy.state_timer > ARCHER_FIRE_TIMER then
               -- Draw cocked arrow
               if enemy.color == "red" then
                  gfx.draw( img_arrowred, -1.5, -6.5 )
               else
                  gfx.draw( img_arrowblack, -1.5, -6.5 )
               end
            end
         else
            gfx.setColor( WHITE )
            if enemy.color == "red" then
               gfx.draw( img_archerred1, -(enemy.width/2), -(enemy.height/2) )
            else
               gfx.draw( img_archerblack1, -(enemy.width/2), -(enemy.height/2) )
            end
         end

         deTranslateRotate( enemy.x+(enemy.width/2), enemy.y+(enemy.height/2), enemy.facing )
      end

      if enemy.class == "arrow" then
         translateRotate( enemy.x+(enemy.width/2), enemy.y+(enemy.height/2), enemy.facing )

         gfx.setColor( WHITE )
         if enemy.color == "red" then
            gfx.draw( img_arrowred, -1.5, -1.5 )
         else
            gfx.draw( img_arrowblack, -1.5, -1.5 )
         end

         deTranslateRotate( enemy.x+(enemy.width/2), enemy.y+(enemy.height/2), enemy.facing )
      end

      if enemy.class == "boss1" then

         if enemy.state == "walking" then
            enemy.anim_timer = enemy.anim_timer - 1

            if enemy.anim_timer == 0 then 
               enemy.anim_state = enemy.anim_state + 1
               if enemy.anim_state == 5 then enemy.anim_state = 1 end

               if enemy.damage < 3 then
                  enemy.anim_timer = BOSS1_BASIC_TIMER * 3 
               else
                  enemy.anim_timer = BOSS1_FAST_TIMER * 3 
               end
            end
         end

         translateRotate( enemy.x+4, enemy.y+4, enemy.facing )

         if enemy.state == "walking" then
            gfx.setColor( WHITE )
            if enemy.damage_flashes > 0 and enemy.damage_flash_timer < BOSS1_FLASH_TIMER then
               gfx.setColor( BLACK )
            end

            if enemy.anim_state == 1 or enemy.anim_state == 3 then
               gfx.draw( img_boss1_mid[enemy.damage], -4, -4 )
            elseif enemy.anim_state == 2 then
               gfx.draw( img_boss1_right[enemy.damage], -4, -4 )
            elseif enemy.anim_state == 4 then
               gfx.draw( img_boss1_left[enemy.damage], -4, -4 )
            end
         elseif enemy.state == "swingprep" then

            gfx.setColor( WHITE )
            if enemy.damage_flashes > 0 and enemy.damage_flash_timer < BOSS1_FLASH_TIMER then
               gfx.setColor( BLACK )
            end
            gfx.draw( img_boss1_right[enemy.damage], -4, -4 )
            gfx.setColor( DARK_GRAY )
            gfx.rectangle( 'fill', -BOSS1_SWORD_LENGTH, -3, BOSS1_SWORD_LENGTH+1, 1 )
            gfx.setColor( LIGHT_GRAY )
            gfx.rectangle( 'fill', -BOSS1_SWORD_LENGTH+1, -4, BOSS1_SWORD_LENGTH-1, 1 )

         elseif enemy.state == "swinging" then
            gfx.setColor( WHITE )
            if enemy.damage_flashes > 0 and enemy.damage_flash_timer < BOSS1_FLASH_TIMER then
               gfx.setColor( BLACK )
            end
            gfx.draw( img_boss1_left[enemy.damage], -4, -4 )

            local a = ((enemy.state_timer / (BOSS1_BASIC_TIMER * 5)) * 200)
            if enemy.damage >= 3 then
               a = ((enemy.state_timer / (BOSS1_FAST_TIMER * 5)) * 300)
            end
            if a > 255 then a = 255 end
            gfx.setColor( LIGHT_GRAY[1], LIGHT_GRAY[2], LIGHT_GRAY[3], a )
            gfx.arc( 'fill', 0, -3, BOSS1_SWORD_LENGTH, -math.pi - 0.1, 0, 20 )

            gfx.setColor( DARK_GRAY )
            gfx.rectangle( 'fill', -1, -3, BOSS1_SWORD_LENGTH+1, 1 )

         elseif enemy.state == "sleeping" then

            gfx.setColor( WHITE )
            gfx.draw( img_boss1_mid[enemy.damage], -4, -4 )

            gfx.setColor( DARK_GRAY )
            gfx.rectangle( 'fill', -(BOSS1_SWORD_LENGTH/2)-1, -4, BOSS1_SWORD_LENGTH, 1 )
            gfx.setColor( LIGHT_GRAY )
            gfx.rectangle( 'fill', -(BOSS1_SWORD_LENGTH/2), -5, BOSS1_SWORD_LENGTH-2, 1 )
            gfx.setColor( BLACK )
            gfx.rectangle( 'fill', 2, -5, 1, 2 )

         elseif enemy.state == "grabsword" then

            gfx.setColor( WHITE )
            gfx.draw( img_boss1_right[enemy.damage], -4, -4 )

            gfx.setColor( DARK_GRAY )
            gfx.rectangle( 'fill', -(BOSS1_SWORD_LENGTH/2)-1, -4, BOSS1_SWORD_LENGTH, 1 )
            gfx.setColor( LIGHT_GRAY )
            gfx.rectangle( 'fill', -(BOSS1_SWORD_LENGTH/2), -5, BOSS1_SWORD_LENGTH-2, 1 )
            gfx.setColor( BLACK )
            gfx.rectangle( 'fill', 2, -5, 1, 2 )
         end

         deTranslateRotate( enemy.x+4, enemy.y+4, enemy.facing )
      end

   end
end

--- Player

function initPlayer( x, y )
   player = { x = x, y = y, facing = 'down', width = 3, height = 3,
                    color = 0, 
                    state = "normal",
                    anim_timer = 0,
                    magnet_pull = false,
                    unlocked = { } }
   player_start = { x = player.x, y = player.y }
   player.unlocked[0] = true
   --player.unlocked[1] = true
   --player.unlocked[2] = true
   --player.unlocked[3] = true
   --player.unlocked[4] = true
   --player.unlocked[5] = true
   --player.unlocked[6] = true
end

function killPlayer()
   game_state = "dead"
   game_state_timer = DEATH_TIME

   for x=player.x,player.x+2 do
      for y=player.y,player.y+2 do
         createEffect( "playerdeath", BLACK, x, y )
         createEffect( "playerdeath", BLACK, x, y )
         createEffect( "playerdeath", BLACK, x, y )
      end
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
   if not player.unlocked[1] then return end

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
      local searchbox = { x = end_x, y = player.y, width = x + 1 - end_x, height = 3 }
      if player.facing == "right" then
         x = x + 2
         dx = 1
         end_x = current_room.width - 3
         searchbox = { x = x + 2, y = player.y, width = end_x + 1 - x, height = 3 }
      end

      local enemies = { }
      for _,enemy in pairs(current_room.enemies) do
         if enemy.magnetic and intersects( enemy, searchbox ) then
            enemies[enemy.id] = { e=enemy, near_x = enemy.x + enemy.width - 1 }
            if player.facing == "right" then
               enemies[enemy.id].near_x = enemy.x
            end
         end
      end

      if (player.facing == "left" and x > end_x) or (player.facing == "right" and x < end_x) then
         while x ~= end_x and not player.magnet_target do
            for _,enemy in pairs(enemies) do
               if enemy.near_x == x then
                  player.magnet_target = enemy.e
               end
            end
            for y=player.y,player.y+2 do
               local obj = current_room.grid[x][y].obj
               if obj and obj.magnetic then
                  player.magnet_target = current_room.grid[x][y].obj
               end
            end
            if player.magnet_target then
               if not player.magnet_target.velocity then player.magnet_target.velocity = { x=0, y=0 } end
               if not player.magnet_target.x_move_ticks then player.magnet_target.x_move_ticks = 0 end
               if not player.magnet_target.y_move_ticks then player.magnet_target.y_move_ticks = 0 end
            end
            x = x + dx
         end
      end

   elseif player.facing == "up" or player.facing == "down" then
      local y = player.y
      local dy = -1
      local end_y = 2
      local searchbox = { x = player.x, y = end_y, width = 3, height = y + 1 - end_y }
      if player.facing == "down" then
         y = y + 2
         dy = 1
         end_y = current_room.height - 3
         searchbox = { x = player.x, y = y, width = 3, height = end_y + 1 - y }
      end

      local enemies = { }
      for _,enemy in pairs(current_room.enemies) do
         if enemy.magnetic and intersects( enemy, searchbox ) then
            enemies[enemy.id] = { e=enemy, near_y = enemy.y + enemy.height - 1 }
            if player.facing == "down" then
               enemies[enemy.id].near_y = enemy.y
            end
         end
      end

      if (player.facing == "up" and y > end_y) or (player.facing == "down" and y < end_y) then
         while y ~= end_y and not player.magnet_target do
            for _,enemy in pairs(enemies) do
               if enemy.near_y == y then
                  player.magnet_target = enemy.e
               end
            end
            for x=player.x,player.x+2 do
               local obj = current_room.grid[x][y].obj
               if obj and obj.magnetic then
                  player.magnet_target = current_room.grid[x][y].obj
               end
            end
            if player.magnet_target then
               if not player.magnet_target.velocity then player.magnet_target.velocity = { x=0, y=0 } end
               if not player.magnet_target.x_move_ticks then player.magnet_target.x_move_ticks = 0 end
               if not player.magnet_target.y_move_ticks then player.magnet_target.y_move_ticks = 0 end
            end
            y = y + dy
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
   local destroyed = { }
   for x=x_min,x_max do
      for y=y_min,y_max do
         local dx = x - player.x
         local dy = y - player.y
         local dist = (dx * dx) + (dy * dy)
         if dist <= r2 then
            current_room.grid[x][y].miasma = false
            if current_room.grid[x][y].obj and current_room.grid[x][y].obj.swordable then
               destroyed[current_room.grid[x][y].obj.id] = current_room.grid[x][y].obj
            end
         end
      end
   end

   for _,object in pairs(destroyed) do
      destroyObject( object )
   end

   destroyed = { }
   for _,enemy in pairs(current_room.enemies) do
      local box = { x = x_min, y = y_min, width = (x_max - x_min + 1), height = (y_max - y_min + 1) }
      if intersects( enemy, box ) then
         local hit = false
         for x=enemy.x,enemy.x+enemy.width-1,enemy.width-1 do
            for y=enemy.y,enemy.y+enemy.height-1,enemy.height-1 do
               local dx = x - (player.x + 1)
               local dy = y - (player.y + 1)
               if (dx * dx) + (dy * dy) <= r2 then
                  hit = true
               end
            end
         end

         if hit then
            if enemy.swordable then
               destroyed[enemy.id] = enemy
            end
         end
      end
   end

   for _,enemy in pairs(destroyed) do
      destroyEnemy( enemy )
   end
end

-- Used by boss1
function enemySwingSword( enemy )
   local sword = { x = enemy.x + 4, y = enemy.y + 1 }
   if enemy.facing == "down" then sword.y = enemy.y+7 end
   if enemy.facing == "left" then 
      sword.x = enemy.x+1 
      sword.y = enemy.y+4 
   end
   if enemy.facing == "right" then 
      sword.x = enemy.x+7 
      sword.y = enemy.y+4 
   end

   local x_min = sword.x - math.ceil(BOSS1_SWORD_LENGTH)
   local x_max = sword.x + math.ceil(BOSS1_SWORD_LENGTH)
   local y_min = sword.y - math.ceil(BOSS1_SWORD_LENGTH)
   local y_max = sword.y + math.ceil(BOSS1_SWORD_LENGTH)
   if enemy.facing == "up" then y_max = sword.y end
   if enemy.facing == "down" then y_min = sword.y end
   if enemy.facing == "left" then x_max = sword.x end
   if enemy.facing == "right" then x_min = sword.x end
   if x_min < 2 then x_min = 2 end
   if y_min < 2 then y_min = 2 end
   if x_max >= current_room.width-2 then x_max = current_room.width-3 end
   if y_max >= current_room.height-2 then y_max = current_room.height-3 end

   local r2 = BOSS1_SWORD_LENGTH * BOSS1_SWORD_LENGTH
   for x=x_min,x_max do
      for y=y_min,y_max do
         local dx = x - sword.x
         local dy = y - sword.y
         local dist = (dx * dx) + (dy * dy)
         if dist <= r2 then
            if current_room.grid[x][y].id == "wall" then
               current_room.grid[x][y].id = nil
               createEffect( "rubble", WALL_SAND, x, y )
               createEffect( "rubble", DRAWING_SAND, x, y )
            end
         end
      end
   end

   local dead = false
   for x=player.x,player.x+2 do
      for y=player.y,player.y+2 do
         local dx = x - sword.x
         local dy = y - sword.y
         local dist = (dx * dx) + (dy * dy)
         if dist <= r2 then
            dead = true
         end
      end
   end
   if dead then
      killPlayer()
   end
end

function playerActionOn()
   player.anim_timer = 0
   if player.color == 1 then
      -- Enter magnet state
      player.state = "magnet"
      speed = MAGNET_SPEED

      getMagnetTarget()

   elseif player.color == 2 then
      -- Place warppoint or warp to it
      if player.warppoint then
         movePlayerTo( player.warppoint[1], player.warppoint[2] )
         player.warppoint = nil
      else
         player.warppoint = { player.x, player.y }
         player.warpeffect = WARP_EFFECT_DURATION
      end

   elseif player.color == 3 then
      -- Check for a nearby torch
      local nearby_torch = nil
      for x=player.x-1,player.x+3 do
         for y=player.y-1,player.y+3 do
            if current_room.grid[x][y].obj and current_room.grid[x][y].obj.class == "torch" then
               nearby_torch = current_room.grid[x][y].obj
            end
         end
      end

      if nearby_torch then
         lightTorch( nearby_torch )
      elseif current_room.flamecount < FLAMES_MAX then 
         dropFlame()
      end
   elseif player.color == 4 then
      -- Launch wind or turn wind
      if current_room.wind then
         -- Turn the wind
         if current_room.wind.turns < WIND_MAX_TURNS then
            current_room.wind.move_ticks = WIND_TIMER * 2
            current_room.wind.turning = true
         end
      else
         local wind = { id="wind", class="wind", passable = true, turns = 0, move_ticks = WIND_TIMER,
                        width = 5, height = 9,
                        x = player.x + 1, y = player.y + 1, dir = player.facing }
         addDirection( wind, wind.dir )
         if wind.dir == "up" or wind.dir == "down" then
            wind.width = 9
            wind.height = 5
         end
         current_room.wind = wind
      end

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
      player.magnet_pull = not player.magnet_pull
      speed = BASE_SPEED
   end
end

function drawPlayer()
   if game_state == "dead" then return end
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
         local a = ((player.sword_anim / SWORD_SWING_TIME) * 300)
         if a > 255 then a = 255 end
         gfx.setColor( VIOLET_SWORD_FILL[1], VIOLET_SWORD_FILL[2], VIOLET_SWORD_FILL[3], a )
         gfx.arc( 'fill', 0, 0, SWORD_LENGTH, -math.pi - 0.1, 0, 15 )
         gfx.setColor( VIOLET_SWORD )
         gfx.rectangle( 'fill', 0, -0.5, SWORD_LENGTH, 1 )
      end
   end

   local a = 255
   if game_state == "gotmagnet" or
      game_state == "gotlamp" or
      game_state == "gotbigbomb" or
      game_state == "gotwarp" or
      game_state == "gotwind" or
      game_state == "gotsword" then
      a = math.floor(255 * (SHOW_POWER_TIME - game_state_timer) / SHOW_POWER_TIME)
   end
   if player.color == 1 then
      gfx.setColor( RED_MAGNET[1], RED_MAGNET[2], RED_MAGNET[3], a )
      if player.magnet_pull then
         gfx.rectangle( 'fill', -1.5, -1.5, 3, 1 )
         gfx.rectangle( 'fill', -1.5, -0.5, 1, 1 )
         gfx.rectangle( 'fill', 0.5, -0.5, 1, 1 )
      else
         gfx.rectangle( 'fill', -1.5, -1.5, 1, 2 )
         gfx.rectangle( 'fill', -0.5, -0.5, 1, 1 )
         gfx.rectangle( 'fill', 0.5, -1.5, 1, 2 )
      end
   end
   if player.color == 2 then
      gfx.setColor( ORANGE_WARP[1], ORANGE_WARP[2], ORANGE_WARP[3], a )
      gfx.rectangle( 'fill', -1.5, -1.5, 1, 1 )
      gfx.rectangle( 'fill', -0.5, -0.5, 1, 1 )
      gfx.rectangle( 'fill', 0.5, 0.5, 1, 1 )
      gfx.rectangle( 'fill', 0.5, -1.5, 1, 1 )
      gfx.rectangle( 'fill', -1.5, 0.5, 1, 1 )
   end
   if player.color == 3 then
      gfx.setColor( YELLOW_LAMP[1], YELLOW_LAMP[2], YELLOW_LAMP[3], a )
      gfx.rectangle( 'fill', -0.5, -0.5, 1, 1 )
   end
   if player.color == 4 then
      gfx.setColor( GREEN_WHIRLWIND[1], GREEN_WHIRLWIND[2], GREEN_WHIRLWIND[3], a )
      gfx.rectangle( 'fill', -0.5, -1.5, 2, 1 )
      gfx.rectangle( 'fill', -0.5, -0.5, 1, 1 )
   end
   if player.color == 5 then
      gfx.setColor( BLUE_BOMB[1], BLUE_BOMB[2], BLUE_BOMB[3], a )
      gfx.rectangle( 'fill', -1.5, -0.5, 3, 1 )
      gfx.rectangle( 'fill', -0.5, -1.5, 1, 3 )
   end
   if player.color == 6 then
      gfx.setColor( VIOLET_SWORD[1], VIOLET_SWORD[2], VIOLET_SWORD[3], a )
      gfx.rectangle( 'fill', -1.5, -1.5, 3, 2 )
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
   for x=player.x,player.x+2 do
      for y=player.y,player.y+2 do
         if current_room.grid[x][y].id == "stairs" then
            player.onstairs = true
         end
      end
   end
   player.warppoint = nil
   centerCamera()
end

--- Effects

function createEffect( class, color, x, y, room )
   if not room then room = current_room end

   if class == "rubble" then
      room.effects[id_cnt] = { id=id_cnt, class="rubble", color=color, dir=randomDirection(), timer = 3 * RUBBLE_DURATION_SEGMENT, x=x, y=y }
   end

   if class == "playerdeath" then
      room.effects[id_cnt] = { id=id_cnt, class="playerdeath", color=color, dir=randomDirection(), timer = 4 * DEATH_DURATION_SEGMENT, x=x, y=y }
   end

   if class == "explosion" then
      room.effects[id_cnt] = { id=id_cnt, class="explosion", color=color, timer = EXPLOSION_DURATION, x=x, y=y }
   end

   if class == "acquirepower" then
      room.effects[id_cnt] = { id=id_cnt, class="acquirepower", color=color, timer = ACQUIRE_POWER_TIME, x=x, y=y }
   end

   if class == "acquire1" then
      local rotate = math.random() * math.pi * 2
      local dx = 10 * math.cos(rotate)
      local dy = 10 * math.sin(rotate)
      room.effects[id_cnt] = { id=id_cnt, class="acquire1", color=color, x=x + dx, y=y + dy, dx= -(dx/50), dy = (-dy/50) }
   end

   if class == "boss1death" then
      room.effects[id_cnt] = { id=id_cnt, class="boss1death", color=color, timer = BOSS1_DEATH_TIME, x=x, y=y }
      room.effects.boss1 = room.enemies.boss1
   end

   id_cnt = id_cnt + 1
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

      if effect.class == "stairs" then
         gfx.setColor( WHITE )
         if effect.dir == "up" then gfx.draw( img_stairs_up, effect.x, effect.y )
         else gfx.draw( img_stairs_down, effect.x, effect.y ) end
      end

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
         elseif effect.color == "red" then 
            gfx.setColor( RED_MAGNET[1], RED_MAGNET[2], RED_MAGNET[3], a ) 
         elseif effect.color == "violet" then 
            gfx.setColor( VIOLET_SWORD_FILL[1], VIOLET_SWORD_FILL[2], VIOLET_SWORD_FILL[3], a ) 
         elseif effect.color == "black" then 
            gfx.setColor( DARK_GRAY[1], DARK_GRAY[2], DARK_GRAY[3], a ) 
         else
            gfx.setColor( effect.color[1], effect.color[2], effect.color[3], a )
         end
         gfx.rectangle( 'fill', effect.x, effect.y, 1, 1 )
      end

      if effect.class == "playerdeath" then
         effect.timer = effect.timer - 1

         if effect.timer == DEATH_DURATION_SEGMENT * 3 or
            effect.timer == DEATH_DURATION_SEGMENT * 2 or
            effect.timer == DEATH_DURATION_SEGMENT then
            addDirection( effect, effect.dir )
         end
         if effect.timer == 0 then expired[effect.id] = true end

         local a = math.floor((effect.timer * 255) / (DEATH_DURATION_SEGMENT * 4))

         gfx.setColor( BLACK[1], BLACK[2], BLACK[3], a ) 
         gfx.rectangle( 'fill', effect.x, effect.y, 1, 1 )
      end

      if effect.class == "explosion" then
         effect.timer = effect.timer - 1
         if effect.timer == 0 then expired[effect.id] = true end

         local a = math.floor((effect.timer * 255) / (EXPLOSION_DURATION))
         gfx.setColor( 255, 255, 255, a )
         if effect.color == "blue" then 
            gfx.draw( img_explosionblue, effect.x, effect.y )
         else
            gfx.draw( img_explosion, effect.x, effect.y )
         end

      end

      if effect.class == "acquirepower" then
         effect.timer = effect.timer - 1
         if effect.timer == 0 then expired[effect.id] = true end

         createEffect( "acquire1", effect.color, effect.x, effect.y )
      end

      if effect.class == "acquire1" then
         effect.x = effect.x + effect.dx
         effect.y = effect.y + effect.dy
         effect.dx = effect.dx * 1.1
         effect.dy = effect.dy * 1.1

         gfx.setColor( effect.color )
         gfx.rectangle( 'fill', math.floor(effect.x), math.floor(effect.y), 1, 1 )

         if effect.dx > 0 and effect.x > player.x then expired[effect.id] = true end
         if effect.dx < 0 and effect.x < player.x+2 then expired[effect.id] = true end
         if effect.dy > 0 and effect.y > player.y then expired[effect.id] = true end
         --if effect.dy < 0 and effect.y > player.y+2 then expired[effect.id] = true end
      end

      if effect.class == "boss1death" then
         effect.timer = effect.timer - 1
         if effect.timer == 0 then 
            expired[effect.id] = true 
            expired["boss1"] = true 
            singleRemoveLock( current_room.objects["lock"] )
         end

         for i=1,8 do
            local x = effect.x + math.random(8) - 1
            local y = effect.y + math.random(8) - 1
            createEffect( "rubble", RED_MAGNET, x, y )
         end

      end

      if effect.class == "boss1" then
         translateRotate( effect.x+4, effect.y+4, effect.facing )

         gfx.setColor( WHITE )
         gfx.draw( img_boss1_mid[4], -4, -4 )

         deTranslateRotate( effect.x+4, effect.y+4, effect.facing )
      end

   end

   if current_room.wind then
      local wind = current_room.wind
      translateRotate( wind.x+0.5, wind.y+0.5, wind.dir )

      gfx.setColor( WHITE )
      if wind.turning then
         gfx.draw( img_wind_turn, -4.5, -4.5 )
      else
         gfx.draw( img_wind, -4.5, -2.5 )
      end

      deTranslateRotate( wind.x, wind.y, wind.dir )
   end

   for id,_ in pairs(expired) do
      current_room.effects[id] = nil
   end
end

--- Collisions and Interactions

function windPush()
   local wind = current_room.wind
   local blowable = { }

   for _,obj in pairs(current_room.objects) do
      if obj.lightweight and
         wind.x-math.floor(wind.width/2) <= obj.x + obj.width-1 and 
         wind.x+math.floor(wind.width/2) >= obj.x and
         wind.y-math.floor(wind.height/2) <= obj.y + obj.height-1 and 
         wind.y+math.floor(wind.height/2) >= obj.y then
         blowable[obj.id] = obj
      end
   end

   local dx = 0
   local dy = 0
   if wind.dir == "up" then dy = -1 end
   if wind.dir == "down" then dy = 1 end
   if wind.dir == "left" then dx = -1 end
   if wind.dir == "right" then dx = 1 end

   -- TODO Sort based on what's in front - maybe not necessary
   for _,obj in pairs(blowable) do
      moveObject( obj, dx, dy )
   end

   addDirection( wind, wind.dir )
end

function playerStaticCollisions( new_x, new_y, direction )
   
   local player_on_stairs = false

   for _,enemy in pairs(current_room.enemies) do
      if new_x <= enemy.x + enemy.width-1 and new_x + 2 >= enemy.x
         and new_y <= enemy.y + enemy.height-1 and new_y + 2 >= enemy.y then
         -- Dead
         killPlayer()
         return true
      end
   end

   local pushable = nil

   for x=new_x,new_x+2 do
      for y=new_y,new_y+2 do
         local spot = current_room.grid[x][y]
         if spot.id == 'stairs' then player_on_stairs = true end

         if spot.obj and spot.obj.pushable then
            if pushable and pushable ~= spot.obj then
               return true -- Can't push two things at once
            end

            pushable = spot.obj
         end

         if spot.obj then
            if spot.obj.class == "magnet" then
               game_state = "getmagnet"
               game_state_timer = RUBBLE_DURATION_SEGMENT * 4
               destroyObject( spot.obj )

               return true
            elseif spot.obj.class == "warp" then
               game_state = "getwarp"
               game_state_timer = RUBBLE_DURATION_SEGMENT * 4
               destroyObject( spot.obj )

               return true
            elseif spot.obj.class == "lamp" then
               game_state = "getlamp"
               game_state_timer = RUBBLE_DURATION_SEGMENT * 4
               destroyObject( spot.obj )

               return true
            elseif spot.obj.class == "whirlwind" then
               game_state = "getwind"
               game_state_timer = RUBBLE_DURATION_SEGMENT * 4
               destroyObject( spot.obj )

               return true
            elseif spot.obj.class == "bigbomb" then
               game_state = "getbigbomb"
               game_state_timer = RUBBLE_DURATION_SEGMENT * 4
               destroyObject( spot.obj )

               return true
            elseif spot.obj.class == "sword" then
               game_state = "getsword"
               game_state_timer = RUBBLE_DURATION_SEGMENT * 4
               destroyObject( spot.obj )

               return true
            end

            if spot.obj.class == "spikes" then
               killPlayer()
               return true
            end
         end

         if spot.id == 'wall'
            or spot.id == 'black'
            or (spot.obj and not spot.obj.passable and not spot.obj.pushable)
            then
            return true
         end

         if spot.miasma then
            -- Dead
            killPlayer()
            return true
         end

         if spot.id == 'door' or (spot.id == 'stairs' and not player.onstairs) then 
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
            if spot.id == 'stairs' then player.onstairs = true end
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

   if player_on_stairs == false then player.onstairs = nil end

   return false
end

function playerUpdateCollisions()
   for x=player.x,player.x+2 do
      for y=player.y,player.y+2 do
         if current_room.grid[x][y].miasma then
            -- Dead
            killPlayer()
         end
      end
   end
end

function objectStaticCollisions( object, new_x, new_y )

   for x=new_x,new_x+object.width-1 do
      for y=new_y,new_y+object.height-1 do
         if current_room.grid[x][y].id == 'wall'
            or current_room.grid[x][y].id == 'white' 
            or current_room.grid[x][y].id == 'door' 
            then 
            return { hit = current_room.grid[x][y].id }
         end
         if current_room.grid[x][y].obj and current_room.grid[x][y].obj.class == "spikes" then
            return { hit = "spikes" }
         end
      end
   end

   if object.class ~= "bomb" and new_x <= player.x + 2 and new_x + object.width-1 >= player.x
      and new_y <= player.y + 2 and new_y + object.height-1 >= player.y then
      return { hit = 'player' }
   end

   for _,enemy in pairs(current_room.enemies) do
      if not enemy.passable and enemy.id ~= object.id and
         new_x <= enemy.x + enemy.width-1 and new_x + object.width-1 >= enemy.x
         and new_y <= enemy.y + enemy.height-1 and new_y + object.height-1 >= enemy.y then
         return { hit = "enemy", enemy = enemy }
      end
   end

   for _,obj in pairs(current_room.objects) do
      if not obj.passable and obj.id and obj.id ~= object.id and
         new_x <= obj.x + obj.width-1 and new_x + object.width-1 >= obj.x
         and new_y <= obj.y + obj.height-1 and new_y + object.height-1 >= obj.y then
         return { hit = "object", object = object }
      end
   end

   return false

end

--- Darkness

function dropFlame()
   if player.flame then return end

   local flame = { id=id_cnt, class="flame", passable=true,
                   x=player.x + 1, y=player.y + 1, 
                   power = FLAME_POWER, pure = 0,
                   timeout = FLAME_TIMEOUT }
   id_cnt = id_cnt + 1

   current_room.lights[flame.id] = flame
   current_room.objects[flame.id] = flame
   current_room.flamecount = current_room.flamecount + 1
end

function lightTorch( torch, room )
   if torch.on == false then
      if not room then room = current_room end
      torch.on = true
      room.lights[torch.id] = torch

      removeLocks( torch )
   end
   if torch.to_timeout then torch.timeout = torch.to_timeout end
end

function quenchTorch( torch, room )
   if not room then room = current_room end
   torch.on = false
   room.lights[torch.id] = nil

   addLocks( torch )
end

function lightCircle( dark_grid, center_x, center_y, radius, pure_radius )
   -- Shadowcasting? haha no
   if not pure_radius then pure_radius = 0 end

   local search_r = math.ceil( radius )
   local light_r = radius - pure_radius

   for dx=-search_r,search_r do
      if center_x + dx >= 0 and center_x + dx < current_room.width then
         for dy=-search_r,search_r do
            if center_y + dy >= 0 and center_y + dy < current_room.height then

               local dist = math.sqrt((dx * dx) + (dy * dy))

               if dist > radius then
               elseif dist < pure_radius then
                  dark_grid[center_x+dx][center_y+dy] = 0
               else
                  local da = ((radius - dist) / light_r) * 255
                  if da > 0 then
                     dark_grid[center_x+dx][center_y+dy] = dark_grid[center_x+dx][center_y+dy] - da
                     if dark_grid[center_x+dx][center_y+dy] < 0 then 
                        dark_grid[center_x+dx][center_y+dy] = 0
                     end
                  end
               end

   end end end end
end

function drawDarkness()
   if current_room.darkness == 0 then return end

   local darkness = current_room.darkness
   local dark_grid = {}
   
   -- TODO: Only calculate for areas in camera view

   for x=0,current_room.width-1 do
      dark_grid[x] = {}
      for y=0,current_room.height-1 do
         dark_grid[x][y] = darkness
      end
   end

   -- Player
   if player.color == 3 then
      lightCircle( dark_grid, player.x + 1, player.y + 1, 11.9, 5 )
   else
      lightCircle( dark_grid, player.x + 1, player.y + 1, 4.9, 2 )
   end

   -- Light sources
   for _,light in pairs(current_room.lights) do
      if light.class == "torch" then 
         -- Put the light in the center of the torch
         light.x = light.x + 2
         light.y = light.y + 2
      end
      if light.timeout and light.timeout < (3 * light.power) then
         lightCircle( dark_grid, light.x, light.y, math.floor(light.timeout / 3), light.pure )
      else
         lightCircle( dark_grid, light.x, light.y, light.power, light.pure )
      end
      if light.class == "torch" then 
         light.x = light.x - 2
         light.y = light.y - 2
      end
   end

   local last_darkness = -1
   local last_y = 0
   local last_size = 0
   for x=0,current_room.width-1 do
      for y=0,current_room.height-1 do
         local d = dark_grid[x][y]
         if d == last_darkness then
            last_size = last_size + 1

         else
            if last_darkness ~= -1 then
               gfx.setColor( 0, 0, 0, last_darkness )
               gfx.rectangle('fill', x, last_y, 1, last_size)
            end

            last_darkness = d
            last_y = y
            last_size = 1
         end
      end
      gfx.setColor( 0, 0, 0, last_darkness )
      gfx.rectangle('fill', x, last_y, 1, last_size)
      last_darkness = -1
      last_y = 0
      last_size = 0
   end

end

--- Menu

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

   initPlayer( 16, 40 )
   loadNewRoom( "magnetpuzzle2" )
   centerCamera()
end

function love.keypressed(key, scancode, isrepeat)
   if key == 'escape' then 
      if game_state ~= "menu" then
         game_state_backup = game_state
         game_state = "menu" 
      else
         game_state = game_state_backup
      end
   end
   if key == 'q' then love.event.quit() end

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

   if key == 'f' then fireArrow( 12, 12, "down", "red" ) end
end

function love.keyreleased(key)
   if key == 'space' then playerActionOff() end
end

local move_timer = 0
function love.update(dt)

   local frameLock = love.timer.getDelta()
   local delay = (1/60) - frameLock
   if delay > 0 then love.timer.sleep(delay) end
   love.timer.step()

   local fps = love.timer.getFPS()
   fpsText:set(fps..' fps')

   if game_state == "dead" then
      game_state_timer = game_state_timer - 1
      if game_state_timer == 0 then
         game_state = "play"
         restartRoom()
      else
         return
      end
   end

   -- Bunch of custom scenes

   if game_state == "boss1opening" then
      if camera.x > 0 and game_state_timer > 0 then
         camera.x = camera.x - 1
      elseif game_state_timer > 0 then
         game_state_timer = game_state_timer - 1

         if game_state_timer == BOSS1_OPENING_TIMER * 3 then
            current_room.enemies.boss1.state = "grabsword"
         elseif game_state_timer == BOSS1_OPENING_TIMER * 2 then
            current_room.enemies.boss1.state = "swingprep"
         elseif game_state_timer == BOSS1_OPENING_TIMER * 1 then
            current_room.enemies.boss1.state = "swinging"
         end
      elseif camera.x + 64 < current_room.width then
         camera.x = camera.x + 1
      else
         game_state = "play"
      end

      if game_state ~= "play" then return end
   end

   -- Obtaining powers
   if game_state == "getmagnet" 
      or game_state == "getwarp"
      or game_state == "getlamp"
      or game_state == "getwind"
      or game_state == "getbigbomb"
      or game_state == "getsword" then
      game_state_timer = game_state_timer - 1
      if game_state_timer == 0 then
         game_state_timer = ACQUIRE_POWER_TIME
         game_state = string.gsub( game_state, "get", "acquire" )
         local color = RED_MAGNET
         if game_state == "acquirewarp" then color = ORANGE_WARP
         elseif game_state == "acquirelamp" then color = YELLOW_LAMP
         elseif game_state == "acquirewind" then color = GREEN_WHIRLWIND
         elseif game_state == "acquirebigbomb" then color = BLUE_BOMB
         elseif game_state == "acquiresword" then color = VIOLET_SWORD end
         createEffect( "acquirepower", color, player.x+1, player.y+1 )
      end
      return
   end
   if game_state == "acquiremagnet" 
      or game_state == "acquirewarp"
      or game_state == "acquirelamp"
      or game_state == "acquirewind"
      or game_state == "acquirebigbomb"
      or game_state == "acquiresword" then
      game_state_timer = game_state_timer - 1
      if game_state_timer == 0 then
         game_state_timer = SHOW_POWER_TIME
         game_state = string.gsub( game_state, "acquire", "got" )
         local cnum = 1
         if game_state == "gotwarp" then cnum = 2
         elseif game_state == "gotlamp" then cnum = 3
         elseif game_state == "gotwind" then cnum = 4
         elseif game_state == "gotbigbomb" then cnum = 5
         elseif game_state == "gotsword" then cnum = 6 end
         player.color = cnum
         player.unlocked[cnum] = true
      end
      return
   end
   if game_state == "gotmagnet" 
      or game_state == "gotwarp"
      or game_state == "gotlamp"
      or game_state == "gotwind"
      or game_state == "gotbigbomb"
      or game_state == "gotsword" then
      game_state_timer = game_state_timer - 1
      if game_state_timer == 0 then 
         game_state = "opendoor"
         game_state_timer = HIDDEN_DOOR_TIMER * 2
      end
      return
   end
   if game_state == "opendoor" then
      game_state_timer = game_state_timer - 1
      if game_state_timer == HIDDEN_DOOR_TIMER then
         openHiddenDoor( current_room, 1 )
      elseif game_state_timer == 0 then
         openHiddenDoor( current_room, 2 )
         game_state = "play"
      end
   end

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

      if game_state == "menu" then

      else
         gfx.translate( -camera.x, -camera.y )
         drawRoom()
         drawTriggers()
         drawEffects()
         drawObjects()
         drawEnemies()
         drawPlayer()
         drawDarkness()
         gfx.translate( camera.x, camera.y )

         if love.keyboard.isDown("f") then 
            gfx.setColor( 255, 255, 255, 255 )
            gfx.draw( fpsText, 0, 0 )
         end
         if love.keyboard.isDown("e") then 
            gfx.setColor( 255, 255, 255, 255 )
            infoText:set("id_cnt:"..id_cnt)
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

      end

   gfx.setCanvas()

   gfx.setColor( 255, 255, 255, 255 )
   gfx.draw( canvas64, 0, 0, 0, zoom, zoom )
end
