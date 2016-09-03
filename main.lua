--[[
Candy Jam

Rules
Make a game involving candies
Consider using the word "candy" several times, also "scroll", "memory", "saga" and "apple" might give bonus points

Deadline
3rd of February

Name: No candy for old man
Story: Poor Old Man wants to get some Candy for his grandson, but the King wants all Candy for himselfish
Gameplay: Stealth + Avoid Projectiles
- Old Man must take all possible Candy and flee undetected
- The King is Asleep on a mountain of Apples
- The King becomes Awake when Old Man grabs N Candy
- When Awake, the King does not move but throws Apples to Old Man, which, on impact, make him loose all Candy.
- Lawyers chase Old Man and grab him on touch, slowing him down for a while.
- The game finishes when the timer becomes 0.
Powerups:
- Scrolls: Grant temporary invisibility
Scoring:
- 1x Sweet!
- 2x Combo!
- 3x Sugar Crush!
- 4x Candy Saga!

Implementation:
- Old Man moves 8-way without inertia (animation cycle?
- All entities have Rectangle collision shapes
- Apples are Circles (single frame)
- Candy and Powerups (floating animation cycle?)
- Obstacles are Rectangles
- HUD

Design2:
- The King
   - Sits static on his throne
   - Throws Candy in parabolic arcs in random directions at slightly random period
   - After a while, throws apples in bullet-hell pattern (ex: rotating cross)
- The OldMan
   - Moves without inertia to collect the Candy while avoiding the Lawyers
- Lawyers
   - Chase OldMan
   - Continuously (loke rgdk follow?)
   - In straight lines (like rgdk kamikazes?)
   - Grab OldMan on touch, slowing him down for a while
   - Lawyers that touch Candy become sugar-powered, increase aggresivity (draw in different shade, red, blinking, eg)
   - Law books or judge hammers that fall from the sky?
   => Simpler
   - King throws Bombs randomly (when angry)
- Candy
   + Parabola and small bouncing and friction
   + Random colors
   + Disappear (timeout and blink)
   ? Different sizes/shapes => Scale or Type?
   - Crush OldMan if hit and vel_z < Candy.damage_vel < 0 ?
- Assets
  - Gfx
    - Background
    + OldMan
    + King
    - Lawyer
    + Candy (several colors) (could randomize modulated color with setColor(xxxx))
    + Candy Shadow
  - Sfx
    + King Throws Candy
    + OldMan Gets Candy
    - King throws bombs Evil Laugther
    - Combo
    - Lawyer attacks (dash)
    - Lawyer grabs OldMan
    - Trumpets notify next throw
  - Text
    - Font
    - Score
    + Message
      - Start
      - Combos

Implementation:
- Animation cycles
- Main menu, play, pause, exit
--]]

--[[
   local anim8 = require 'anim8-master/anim8'
--]]

function love.load()
   print("Loading...")

   -- Game state
   Game = {}
   Game.state = "Menu"
   Game.splashscreen = love.graphics.newImage( "data/NCFOM.png" )
   -- Map params
   Map = {}
   Map.width, Map.height = love.graphics.getDimensions()
   Map.background = love.graphics.newImage( "data/bg_grass.jpg" )
   Map.cGravity = -150
   print("Window " .. Map.width .."x".. Map.height)

   -- OldMan params
   OldMan = {}
   OldMan.image = love.graphics.newImage( "data/OldManD0.png" )
   OldMan.sound_death = love.audio.newSource("data/sfx/Death0.ogg", "static")
   OldMan.hs_x = OldMan.image:getWidth() / 2
   OldMan.hs_y = OldMan.image:getHeight() / 2
   OldMan.cSpeed = 200
   OldMan.cComboLifetime = 2
   OldMan.cDeathDuration = 5

   -- King params
   King = {}
   King.vec_sound_candy = {}
   King.vec_sound_candy[1] = love.audio.newSource("data/sfx/Throw0.wav", "static")
   King.vec_sound_candy[2] = love.audio.newSource("data/sfx/Throw1.wav", "static")
   King.vec_sound_candy[3] = love.audio.newSource("data/sfx/Throw2.wav", "static")
   King.vec_sound_candy[4] = love.audio.newSource("data/sfx/Throw3.wav", "static")
   King.vec_sound_bomb = {}
   King.vec_sound_bomb[1] = love.audio.newSource("data/sfx/EvilLaughter0.mp3", "static")
   King.vec_sound_bomb[2] = love.audio.newSource("data/sfx/EvilLaughter1.ogg", "static")
   King.image = love.graphics.newImage( "data/king_0.png" )
   King.hs_x = King.image:getWidth() / 2
   King.hs_y = King.image:getHeight() / 2
   King.cSpeed = 0
   King.cThrowPeriod = 5
   King.cMinCandy = 7
   King.cMinBomb = 5

   -- Candy params
   Candy = {}
   Candy.vec_sound_pickup = {}
   Candy.vec_sound_pickup[1] = love.audio.newSource("data/sfx/Pickup0.wav", "static")
   Candy.vec_sound_pickup[2] = love.audio.newSource("data/sfx/Pickup1.wav", "static")
   Candy.vec_sound_pickup[3] = love.audio.newSource("data/sfx/Pickup2.wav", "static")
   Candy.sound_pickup = love.audio.newSource("data/sfx/Pickup0.wav", "static")
   Candy.vec_images = {}
   -- Wrapped
   Candy.vec_images[1] = love.graphics.newImage( "data/yaycandies/size1/wrappedsolid_green.png" )
   Candy.vec_images[2] = love.graphics.newImage( "data/yaycandies/size1/wrappedsolid_orange.png" )
   Candy.vec_images[3] = love.graphics.newImage( "data/yaycandies/size1/wrappedsolid_purple.png" )
   Candy.vec_images[4] = love.graphics.newImage( "data/yaycandies/size1/wrappedsolid_red.png" )
   Candy.vec_images[5] = love.graphics.newImage( "data/yaycandies/size1/wrappedsolid_teal.png" )
   Candy.vec_images[6] = love.graphics.newImage( "data/yaycandies/size1/wrappedsolid_yellow.png" )
   -- Swirl
   Candy.vec_images[7] = love.graphics.newImage( "data/yaycandies/size1/swirl_blue.png" )
   Candy.vec_images[8] = love.graphics.newImage( "data/yaycandies/size1/swirl_green.png" )
   Candy.vec_images[9] = love.graphics.newImage( "data/yaycandies/size1/swirl_orange.png" )
   Candy.vec_images[10] = love.graphics.newImage( "data/yaycandies/size1/swirl_pink.png" )
   Candy.vec_images[11] = love.graphics.newImage( "data/yaycandies/size1/swirl_purple.png" )
   Candy.vec_images[12] = love.graphics.newImage( "data/yaycandies/size1/swirl_red.png" )
   -- Bean
   Candy.vec_images[13] = love.graphics.newImage( "data/yaycandies/size1/bean_blue.png" )
   Candy.vec_images[14] = love.graphics.newImage( "data/yaycandies/size1/bean_green.png" )
   Candy.vec_images[15] = love.graphics.newImage( "data/yaycandies/size1/bean_orange.png" )
   Candy.vec_images[16] = love.graphics.newImage( "data/yaycandies/size1/bean_pink.png" )
   Candy.vec_images[17] = love.graphics.newImage( "data/yaycandies/size1/bean_purple.png" )
   Candy.vec_images[18] = love.graphics.newImage( "data/yaycandies/size1/bean_red.png" )
   Candy.vec_images[19] = love.graphics.newImage( "data/yaycandies/size1/bean_yellow.png" )
   Candy.vec_shadow_images = {}
   Candy.vec_shadow_images[1] = love.graphics.newImage( "data/yaycandies/size1/wrappedsolid_shadow.png" )
   Candy.vec_shadow_images[2] = Candy.vec_shadow_images[1]
   Candy.vec_shadow_images[3] = Candy.vec_shadow_images[1]
   Candy.vec_shadow_images[4] = Candy.vec_shadow_images[1]
   Candy.vec_shadow_images[5] = Candy.vec_shadow_images[1]
   Candy.vec_shadow_images[6] = Candy.vec_shadow_images[1]
   Candy.vec_shadow_images[7] = love.graphics.newImage( "data/yaycandies/size1/swirl_shadow.png" )
   Candy.vec_shadow_images[8] = Candy.vec_shadow_images[7]
   Candy.vec_shadow_images[9] = Candy.vec_shadow_images[7]
   Candy.vec_shadow_images[10] = Candy.vec_shadow_images[7]
   Candy.vec_shadow_images[11] = Candy.vec_shadow_images[7]
   Candy.vec_shadow_images[12] = Candy.vec_shadow_images[7]
   Candy.vec_shadow_images[13] = love.graphics.newImage( "data/yaycandies/size1/bean_shadow.png" )
   Candy.vec_shadow_images[14] = Candy.vec_shadow_images[13]
   Candy.vec_shadow_images[15] = Candy.vec_shadow_images[13]
   Candy.vec_shadow_images[16] = Candy.vec_shadow_images[13]
   Candy.vec_shadow_images[17] = Candy.vec_shadow_images[13]
   Candy.vec_shadow_images[18] = Candy.vec_shadow_images[13]
   Candy.vec_shadow_images[19] = Candy.vec_shadow_images[13]
   Candy.hs_x = Candy.vec_images[1]:getWidth() / 2
   Candy.hs_y = Candy.vec_images[1]:getHeight() / 2
   Candy.max_z = 250
   Candy.cSpeed = 100
   Candy.cRestitution = 0.5
   Candy.cFriction = 0.6666
   Candy.cLifetime = 3

   -- Bomb params
   Bomb = {}
   Bomb.vec_images = {}
   Bomb.vec_images[1] = love.graphics.newImage( "data/bomb.png" )
   Bomb.shadow_image = love.graphics.newImage( "data/bomb.png" )
   Bomb.hs_x = Bomb.vec_images[1]:getWidth()/2
   Bomb.hs_y = Bomb.vec_images[1]:getHeight()/2
   Bomb.max_z = 250
   Bomb.cSpeed = 100
   Bomb.cRestitution = 0.5
   Bomb.cFriction = 0.6666
   Bomb.cLifetime = 3

   -- Explosion params
   Explosion = {}
   Explosion.vec_sound = {}
   Explosion.vec_sound[1] = love.audio.newSource("data/sfx/Bomb0.wav", "static")
   Explosion.vec_sound[2] = love.audio.newSource("data/sfx/Bomb1.wav", "static")
   Explosion.vec_sound[3] = love.audio.newSource("data/sfx/Bomb2.wav", "static")
   Explosion.cRadius = 150
   Explosion.cLifetime = 1

   -- Global params
   hud_font = love.graphics.newFont( 30 )
   message_font = love.graphics.newFont( 60 )
   love.graphics.setFont( hud_font )

   -- Music
   Music = {}
   Music.vec_music = {}
   Music.vec_music[1] = love.audio.newSource("data/CarnivalRides-Long-Mono-T24.ogg")
   --Music.vec_music[2] = love.audio.newSource("data/CarnivalRides-Long-Mono-T21.ogg")
   Music.vec_music[2] = love.audio.newSource("data/CarnivalRides-Long-Mono-T18.ogg")
   --Music.vec_music[4] = love.audio.newSource("data/CarnivalRides-Long-Mono-T15.ogg")
   Music.vec_music[3] = love.audio.newSource("data/CarnivalRides-Long-Mono-T12.ogg")
   Music.vec_duration = {}
   Music.vec_duration[1] = 24
   --Music.vec_duration[2] = 21
   Music.vec_duration[2] = 18
   --Music.vec_duration[4] = 15
   Music.vec_duration[3] = 12
   for i,m in ipairs(Music.vec_music) do
      m:setLooping( true )
      m:setVolume( 0.5 )
   end
   -- Start main menu music
   Music.type = 1
   Music.lifetime = Music.vec_duration[ Music.type ]
   Music.current = Music.vec_music[ Music.type ]
   Music.current:play()

   love.math.setRandomSeed( 666666.666666 )
   print("...Loaded")
end

function NewGame()
   collectgarbage()
   -- Map state
   Map.time = 0
   -- Oldman state
   OldMan.pos_x = 50
   OldMan.pos_y = 50
   OldMan.candy_count = 0
   OldMan.combo_timeout = 0
   OldMan.combo_count = 0
   OldMan.state = "Alive"
   -- King state
   King.pos_x = Map.width/2
   King.pos_y = Map.height/2
   King.throw_timeout = King.cThrowPeriod
   King.state = 1 -- 1 = Normal, 2 = Angry
   -- tables
   Candy.table = {}
   Bomb.table = {}
   Explosion.table = {}
   -- Messages
   Messages = {}
   -- Music
   Music.current:stop()
   Music.type = 1
   Music.lifetime = Music.vec_duration[ Music.type ]
   Music.current = Music.vec_music[ Music.type ]
   Music.current:play()
end

function love.focus(f)
   if Game.state == "Playing" and not f then
      Game.state = "Pause"
   elseif Game.state == "Death" and not f then
      Game.state = "Pause"
   elseif Game.state == "Pause" and f then
      if OldMan.state == "Alive" then
         Game.state = "Playing"
      else
         Game.state = "Death"
      end
   end
end

-- Standard random is INTEGER, thus random(-1,1) results only in -1,+1 values
function love.math.random_float( min, max )
   return min + (max-min) * (love.math.random(1000000) / 1000000)
end

-- Throw Stuff in random directions
function KingThrowStuff( Stuff, num_stuff )
   for i=1,num_stuff do
      s = {}
      s.pos_x = King.pos_x
      s.pos_y = King.pos_y
      s.pos_z = 0
      s.vel_x = Stuff.cSpeed * love.math.random_float(-1,1)
      s.vel_y = Stuff.cSpeed * love.math.random_float(-1,1)
      s.vel_z = Stuff.cSpeed * love.math.random_float(2,3)
      s.lifetime = Stuff.cLifetime
      s.type = love.math.random(1,table.getn(Stuff.vec_images))
      table.insert( Stuff.table, s )
   end
end

function NewMessage( text, lifetime, scale )
   message = {}
   message.text = text
   message.lifetime = lifetime
   message.scale = scale
   table.insert( Messages, message )
end

function love.keypressed(key)
   -- Game states
   if Game.state == "Menu" then
      Game.state = "Playing" --Any key starts match
      NewGame()
   elseif Game.state == "Playing" then
      if key == ' ' then
         KingThrowStuff(Candy,5)
      end
   elseif Game.state == "Game Over" then
      Game.state = "Menu" --Any key to menu
      Music.type = 1
   elseif Game.state == "Death" then
     -- Nothing...
   else --Game.state == "Pause"
      --Should not happen...
   end
   -- Fullscreen
   if key == '1' then
      love.window.setFullscreen( not love.window.getFullscreen() )
   end
end

function ApplyBorders( px, py, hsx, hsy )
   local x = px
   local y = py
   if( x-hsx < 0 ) then x = hsx end
   if( x+hsx > Map.width ) then x = Map.width-hsx end
   if( y-hsy < 0 ) then y = hsy end
   if( y+hsy > Map.height ) then y = Map.height-hsy end
   return x,y
end

function TestOverlap( px1, py1, hsx1, hsy1, px2, py2, hsx2, hsy2 )
   return math.abs(px1 - px2) < (hsx1 + hsx2) and math.abs(py1 - py2) < (hsy1 + hsy2)
end

function TestPointInCircle( px, py, cx, cy, r )
   return (px-cx)*(px-cx) + (py-cy)*(py-cy) < r*r
end

function love.update(dt)

   -- Update/loop music
   Music.lifetime = Music.lifetime - dt
   if Music.lifetime < 0 then
      Music.current:stop()
      Music.lifetime = Music.vec_duration[ Music.type ]
      Music.current = Music.vec_music[ Music.type ]
      Music.current:play()
   end

   if Game.state == "Menu" then
      -- TODO
   elseif Game.state == "Playing" then
      Map.time = Map.time + dt

      -- Player controls
      if love.keyboard.isDown("up") then
         OldMan.pos_y = OldMan.pos_y - dt * OldMan.cSpeed
      end
      if love.keyboard.isDown("down") then
         OldMan.pos_y = OldMan.pos_y + dt * OldMan.cSpeed
      end
      if love.keyboard.isDown("left") then
         OldMan.pos_x = OldMan.pos_x - dt * OldMan.cSpeed
      end
      if love.keyboard.isDown("right") then
         OldMan.pos_x = OldMan.pos_x + dt * OldMan.cSpeed
      end
      OldMan.combo_timeout = OldMan.combo_timeout - dt
      if OldMan.combo_timeout < 0 then
         OldMan.combo_timeout = 0
         OldMan.combo_count = 0
         Music.type = 1
      end

      -- AI
      King.throw_timeout = King.throw_timeout - dt
      if King.throw_timeout < 0 then
         if love.math.random(0,10) > 3 then
            King.vec_sound_candy[ love.math.random(1,table.getn(King.vec_sound_candy)) ]:play()
            KingThrowStuff( Candy, love.math.random( King.cMinCandy + OldMan.combo_count/2, King.cMinCandy + OldMan.combo_count ) )
         else
            King.vec_sound_bomb[ love.math.random(1,table.getn(King.vec_sound_bomb)) ]:play()
            KingThrowStuff( Bomb, love.math.random( King.cMinBomb + OldMan.combo_count/2, King.cMinBomb + OldMan.combo_count ) )
         end
         King.throw_timeout = King.cThrowPeriod
      end

      -- King kills OldMan on touch
      if TestOverlap( OldMan.pos_x, OldMan.pos_y, 1, 1,
                      King.pos_x, King.pos_y, King.hs_x, King.hs_y ) then
         OldMan.state = "Dead"
         OldMan.death_time = 0
         OldMan.sound_death:play()
      end

      -- Update Candy: Timeout/Move/Pickup
      local removed_candy = {}
      for i,c in ipairs(Candy.table) do
         -- Timeout
         if c.lifetime < 0 then
            table.insert( removed_candy, i )
         else
            -- Move
            c.vel_x = 0.999*c.vel_x
            c.vel_y = 0.999*c.vel_y
            c.vel_z = c.vel_z + Map.cGravity*dt
            c.pos_x = c.pos_x + dt * c.vel_x
            c.pos_y = c.pos_y + dt * c.vel_y
            c.pos_z = c.pos_z + dt * c.vel_z
            -- Pickup
            if TestOverlap( OldMan.pos_x, OldMan.pos_y, OldMan.hs_x, OldMan.hs_y,
                            c.pos_x, c.pos_y, Candy.hs_x, Candy.hs_y )
               and
               c.pos_z - Candy.hs_y < OldMan.hs_y
            then
               --Candy.sound_pickup:play()
               Candy.vec_sound_pickup[ love.math.random(1,table.getn(Candy.vec_sound_pickup)) ]:play()
               OldMan.candy_count = OldMan.candy_count + 1
               OldMan.combo_count = OldMan.combo_count + 1
               OldMan.combo_timeout = OldMan.cComboLifetime
               if OldMan.combo_count == 1 then
                  NewMessage( "¡Sweet!", OldMan.cComboLifetime, 0.5 )
                  Music.type = 1
               elseif OldMan.combo_count < 3 then
                  NewMessage( "¡Combo!", OldMan.cComboLifetime, 0.75 )
                  Music.type = 2
               elseif OldMan.combo_count < 5 then
                  NewMessage( "¡Yummy!", OldMan.cComboLifetime, 1 )
                  Music.type = 2
               elseif OldMan.combo_count < 10 then
                  NewMessage( "¡Sugar Crush!", OldMan.cComboLifetime, 1.5 )
                  Music.type = 3
               elseif OldMan.combo_count < 20 then
                  NewMessage( "¡Candy Saga!", OldMan.cComboLifetime, 2 )
                  Music.type = 3
               else
                  NewMessage( "¡OVERDOSE!", OldMan.cComboLifetime, 2.5 )
                  Music.type = 3
               end
               table.insert( removed_candy, i )
            end
         end
      end
      -- deferred remove
      for i,candy_index in ipairs(removed_candy) do
         table.remove( Candy.table, candy_index )
      end

      -- Update Bomb: Explode/Move
      local removed_bomb = {}
      for i,b in ipairs(Bomb.table) do
         -- Timeout
         if b.lifetime < 0 then
            e = {}
            e.pos_x = b.pos_x
            e.pos_y = b.pos_y
            e.lifetime = Explosion.cLifetime
            Explosion.vec_sound[ love.math.random(1,table.getn(Explosion.vec_sound)) ]:play()
            table.insert( Explosion.table, e )
            table.insert( removed_bomb, i )
         else
            -- Move
            b.vel_x = 0.999*b.vel_x
            b.vel_y = 0.999*b.vel_y
            b.vel_z = b.vel_z + Map.cGravity*dt
            b.pos_x = b.pos_x + dt * b.vel_x
            b.pos_y = b.pos_y + dt * b.vel_y
            b.pos_z = b.pos_z + dt * b.vel_z
         end
      end
      for i,bomb_index in ipairs(removed_bomb) do
         table.remove( Bomb.table, bomb_index )
      end

      -- Update Explosion: Timeout, Kill OldMan
      local removed_explosion = {}
      for i,e in ipairs(Explosion.table) do
         -- Timeout
         e.lifetime = e.lifetime - dt
         local lambda01 = e.lifetime/Explosion.cLifetime
         local radius = (1-lambda01) * Explosion.cRadius
         if e.lifetime < 0 then
            table.insert( removed_explosion, i )
         elseif TestPointInCircle( OldMan.pos_x, OldMan.pos_y,
                                   e.pos_x, e.pos_y, radius ) then
            OldMan.state = "Dead"
            OldMan.death_time = 0
            OldMan.sound_death:play()
         end
      end
      for i,explosion_index in ipairs(removed_explosion) do
         table.remove( Explosion.table, explosion_index )
      end

      -------- Borders
      OldMan.pos_x, OldMan.pos_y = ApplyBorders( OldMan.pos_x, OldMan.pos_y, OldMan.hs_x, OldMan.hs_y )
      King.pos_x, King.pos_y = ApplyBorders( King.pos_x, King.pos_y, King.hs_x, King.hs_y )
      -- Candy
      for i,c in ipairs(Candy.table) do
         c.pos_x, c.pos_y = ApplyBorders( c.pos_x, c.pos_y, Candy.hs_x, Candy.hs_y )
         if c.pos_z < 0 then
            c.pos_z = 0
            c.vel_z = -Candy.cRestitution*c.vel_z
            c.vel_x = Candy.cFriction*c.vel_x
            c.vel_y = Candy.cFriction*c.vel_y
         end
         -- On ground, start timeout
         if math.abs(c.pos_z) < 0.1 then
            c.lifetime = c.lifetime - dt
         end
      end
      -- Bombs
      for i,b in ipairs(Bomb.table) do
         b.pos_x, b.pos_y = ApplyBorders( b.pos_x, b.pos_y, Bomb.hs_x, Bomb.hs_y )
         if b.pos_z < 0 then
            b.pos_z = 0
            b.vel_z = -Bomb.cRestitution*b.vel_z
            b.vel_x = Bomb.cFriction*b.vel_x
            b.vel_y = Bomb.cFriction*b.vel_y
         end
         -- On ground, start timeout
         if math.abs(b.pos_z) < 0.1 then
            b.lifetime = b.lifetime - dt
         end
      end

      -- Messages
      removed_messages = {}
      for i,m in ipairs(Messages) do
         m.lifetime = m.lifetime - dt
         if m.lifetime < 0 then
            table.insert( removed_messages, i )
         end
      end
      for i,message_index in ipairs(removed_messages) do
         table.remove( Messages, message_index )
      end
      -- Kill OldMan
      if OldMan.state == "Dead" then
         Game.state = "Death"
      end
   elseif Game.state == "Death" then
      OldMan.death_time = OldMan.death_time + dt
      if OldMan.death_time > OldMan.cDeathDuration then
         Game.state = "Game Over"
         Music.type = 1
      end
   elseif Game.state == "Game Over" then
      -- Nothin
   else --Game.state == "Paused"
      -- Nothing
   end
end

function love.draw()
   if Game.state == "Menu" then
      love.graphics.setFont( message_font )
      love.graphics.setColor(255,255,255,255)
      love.graphics.draw( Game.splashscreen )
      love.graphics.setColor(255,255,255,255)
      text = "Press any key..."
      love.graphics.print( text,
                           (Map.width - message_font:getWidth( text ))/2,
                           Map.height - 1.1*message_font:getHeight() )
   elseif Game.state == "Playing" or Game.state == "Death" then
      -- Clear color
      love.graphics.setColor(255,255,255,255)
      -- Bgnd
      love.graphics.draw( Map.background )
      -- Candy shadows
      for i,c in ipairs(Candy.table) do
         local alpha01 = math.max(0.25, 1 - (c.pos_z / Candy.max_z))
         love.graphics.setColor( 255,
                                 255,
                                 255,
                                 alpha01*255 )
         love.graphics.draw( Candy.vec_shadow_images[c.type],
                             c.pos_x, c.pos_y,
                             0,
                             1, 1,
                             Candy.hs_x-5, Candy.hs_y-5 )
      end
      -- Bomb shadows
      for i,b in ipairs(Bomb.table) do
         local alpha01 = math.max(0.25, 1 - (b.pos_z / Bomb.max_z))
         love.graphics.setColor(0,0,0,alpha01*255)
         love.graphics.draw( Bomb.shadow_image,
                             b.pos_x, b.pos_y,
                             0,
                             1, 1,
                             Bomb.hs_x-5, Bomb.hs_y-5 )
      end

      -- Clear color
      love.graphics.setColor(255,255,255,255)
      -- Player
      love.graphics.draw( OldMan.image,
                          OldMan.pos_x, OldMan.pos_y,
                          0,
                          2, 2,
                          OldMan.hs_x, OldMan.hs_y )
      -- Enemy
      love.graphics.draw( King.image,
                          King.pos_x, King.pos_y,
                          0,
                          1, 1,
                          King.hs_x, King.hs_y )

      -- Clear color and draw Candy
      love.graphics.setColor(255,255,255,255)
      for i,c in ipairs(Candy.table) do
         local alpha01 = math.max( c.lifetime / Candy.cLifetime, 0 ) --blink faster as lifetime reduces
         love.graphics.setColor( 255,
                                 255,
                                 255,
                                 love.math.random( alpha01*255, 255 ) )
         love.graphics.draw( Candy.vec_images[ c.type ],
                             c.pos_x, c.pos_y - c.pos_z, --.z because Z goes up, Y goes down
                             0,
                             1, 1,
                             Candy.hs_x, Candy.hs_y )
      end

      -- Clear color and draw Bomb
      love.graphics.setColor(255,255,255,255)
      for i,b in ipairs(Bomb.table) do
         local alpha01 = math.max( b.lifetime / Bomb.cLifetime, 0 ) --blink faster as lifetime reduces
         love.graphics.setColor( 255,
                                 255,
                                 255,
                                 love.math.random( alpha01*255, 255 ) )
         love.graphics.draw( Bomb.vec_images[ b.type ],
                             b.pos_x, b.pos_y - b.pos_z, --.z because Z goes up, Y goes down
                             0,
                             1, 1,
                             Bomb.hs_x, Bomb.hs_y )
      end

      -- Clear color and draw Explosion
      love.graphics.setColor(255,255,255,255)
      for i,e in ipairs(Explosion.table) do
         local lambda01 = math.max( e.lifetime / Explosion.cLifetime, 0 ) --blink faster as lifetime reduces
         love.graphics.setColor( 255,
                                 (1-lambda01) * 255,
                                 (1-lambda01) * 255,
                                 love.math.random( lambda01*255, 255 ) )
         local radius = (1-lambda01)*Explosion.cRadius;
         love.graphics.circle( "fill",
                               e.pos_x + 10*(1-lambda01) * love.math.random_float(-1,1),
                               e.pos_y + 10*(1-lambda01) * love.math.random_float(-1,1),
                               radius,
                               32 )
      end

      --[[ Debug
      love.graphics.setColor(0,0,255,255)
      love.graphics.circle( "fill", OldMan.pos_x, OldMan.pos_y, 5, 32 )
      love.graphics.setColor(255,0,0,255)
      love.graphics.circle( "fill", King.pos_x, King.pos_y, 5, 32 )
      --]]

      -- HUD
      love.graphics.setFont( hud_font )
      love.graphics.setColor(255,255,255,255)
      love.graphics.print( "Candy: "..OldMan.candy_count,
                           0, 0,
                           0,
                           1, 1 )
      -- Messages
      love.graphics.setFont( message_font )
      for i,m in ipairs(Messages) do
         love.graphics.setColor( love.math.random(128,255),
                                 love.math.random(128,255),
                                 love.math.random(128,255),
                                 255 )
         local length = m.scale*message_font:getWidth( m.text )
         local height = m.scale*message_font:getHeight()
         local dx = love.math.random_float(-length/10,length/10)
         local dy = love.math.random_float(-height/10,height/10)
         love.graphics.print( m.text,
                              (Map.width - length)/2 + dx,
                              (Map.height)/2 - height + dy,
                              --(Map.height - height)/2 + dy,
                              0,
                              m.scale, m.scale )
      end
      -- Fade to red if dead
      if Game.state == "Death" then
         local lambda01 = math.min( OldMan.death_time / OldMan.cDeathDuration, 1 )
         love.graphics.setColor(255,0,0,lambda01*255)
         love.graphics.rectangle( "fill", 0, 0, Map.width, Map.height )
         --[[
         love.graphics.print( Game.state,
                              (Map.width - message_font:getWidth( Game.state ))/2,
                              (Map.height - message_font:getHeight())/2 )
         --]]
      end
   elseif Game.state == "Game Over" then
      love.graphics.setColor(255,0,0,255)
      love.graphics.rectangle( "fill", 0, 0, Map.width, Map.height )
      love.graphics.setColor(0,0,0,255)
      love.graphics.print( Game.state,
                           (Map.width - message_font:getWidth( Game.state ))/2,
                           (Map.height - message_font:getHeight())/2 )
      score_text = "Candy x "..OldMan.candy_count
      love.graphics.setColor( love.math.random(128,255),
                              love.math.random(128,255),
                              love.math.random(128,255),
                              255 )
      love.graphics.print( score_text,
                           (Map.width - message_font:getWidth( score_text ))/2,
                           (Map.height)/2 + message_font:getHeight() )
   else -- Game.state == "Paused"
      love.graphics.print( Game.state,
                           (Map.width - message_font:getWidth( Game.state ))/2,
                           (Map.height - message_font:getHeight())/2 )
   end
end

function love.quit()
   print("So Long...")
end
