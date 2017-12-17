-- The face update state machine / timing is adapted from the original Doom
-- source (© 1993-1996 id Software, Inc.) We're going for maximum authenticity
-- here. :) In fact, most of the variables names are unchanged, because I just
-- pasted the C code and started translating.
--
-- Changes from the original update algorithm:
--
-- * Doom turns the pain face in the direction the attacker. The WoW API
-- doesn't give us access to enemy position info, so we'll just sync up the
-- direction of the pain face with the direction of the idle glances.
--
-- * Doom shows glowing eyes when in god mode. WoW doesn't have god mode, so
-- I'm using the glowing eyes for when we're a ghost.
--
-- * Doom shows the pain face when the player is "rampaging" (i.e. holding down
-- the trigger for a long time). Meaningfully mapping that to something in WoW
-- would be cool, but more trouble than I care to take. Dropped.
--
-- * Doom shows the evil grin face when you pick up a new weapon. Against my
-- better instincts (because it's a maintenance hastle), I'm going to have
-- a ist "evil buffs" which will trigger the evil grin.
--
-- EricTetz@gmail.com


--- State updates, number of tics / second.
Doom.TICRATE = 8 -- (mud) changed from Doom's 35

-- Number of status faces.
local ST_NUMPAINFACES = 5
local ST_NUMSTRAIGHTFACES = 3
local ST_NUMTURNFACES = 2
local ST_NUMSPECIALFACES = 3

local ST_FACESTRIDE = ST_NUMSTRAIGHTFACES+ST_NUMTURNFACES+ST_NUMSPECIALFACES

local ST_NUMEXTRAFACES = 2

local ST_NUMFACES = ST_FACESTRIDE*ST_NUMPAINFACES+ST_NUMEXTRAFACES

local ST_TURNOFFSET = ST_NUMSTRAIGHTFACES
local ST_OUCHOFFSET = ST_TURNOFFSET + ST_NUMTURNFACES
local ST_EVILGRINOFFSET = ST_OUCHOFFSET + 1
local ST_RAMPAGEOFFSET = ST_EVILGRINOFFSET + 1
local ST_GODFACE = ST_NUMPAINFACES*ST_FACESTRIDE
local ST_DEADFACE = ST_GODFACE+1

local ST_EVILGRINCOUNT = 2*Doom.TICRATE
local ST_STRAIGHTFACECOUNT = Doom.TICRATE/2
local ST_PAINCOUNT = 1*Doom.TICRATE

local ST_MUCHPAIN = 20

-- (mud) used to show evil grin
local st_oldbuffs = 0

-- count until face changes
local st_facecount = 0

local function ST_calcPainOffset(health)
   return ST_FACESTRIDE * math.floor(((100 - health) * ST_NUMPAINFACES) / 101)
end

local facing = 0
local priority = 0
function Doom.updateFaceWidget(damage, health, powerup)

   if priority < 11 then
      if health == 0 then
         priority = 9
         st_facecount = 1
         if UnitIsGhost('player') then
            st_faceindex = ST_GODFACE
         else
            st_faceindex = ST_DEADFACE
         end
      end
   end
   
   if priority < 9 then
      if powerup then
         priority = 8
         st_facecount = ST_EVILGRINCOUNT
         st_faceindex = ST_calcPainOffset(health) + ST_EVILGRINOFFSET
      end
   end
   
   if priority < 8 then
      if damage > 0 then
         priority = 7
         st_facecount = ST_PAINCOUNT
         st_faceindex = ST_calcPainOffset(health)

         if damage > ST_MUCHPAIN then
            st_faceindex = st_faceindex + ST_OUCHOFFSET
         elseif facing == 1 or not UnitAffectingCombat('player') then
            st_faceindex = st_faceindex + ST_RAMPAGEOFFSET -- straight ahead
         elseif facing == 0 then
            st_faceindex = st_faceindex + ST_TURNOFFSET -- look right
         else
            st_faceindex = st_faceindex + ST_TURNOFFSET+1 -- look left
         end
      end
   end
   
   if st_facecount == 0 then
      facing = math.random(0,2)
      st_faceindex = ST_calcPainOffset(health) + facing
      st_facecount = ST_STRAIGHTFACECOUNT
      priority = 0
   end
   
   st_facecount = st_facecount - 1
   
   Doom.setFace(st_faceindex)
end
