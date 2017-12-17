-- Drive this whole thing.  I'm using polling for mana/energy, so it
-- updates in real time like the default frames. Using event-handling
-- for everything else.

-- size of most recent damaging blow, as a percent of total health
local latest_blow = 0

-- percentage of life remaining
local health = 0

-- for tracking power changes
local old_power = nil

-- gained a buff that's worth grinning about
local powerup = false

local interval = 1/Doom.TICRATE
local totalElapsed = 0
function Doom:OnUpdate(elapsed)
   totalElapsed = totalElapsed + elapsed
   if totalElapsed >= interval then
      totalElapsed = 0

      if DoomDB.showbg then
         local power = UnitPower('player')
         if power ~= old_power then
            Doom.setPower(math.floor(power / UnitPowerMax('player') * 100))
            old_power = power
         end
      end

      Doom.updateFaceWidget(latest_blow, health, powerup)

      latest_blow = 0
      powerup = false
   end
end

function Doom.UNIT_HEALTH(unit)
   if unit == 'player' then
      health = math.floor((UnitHealth('player')) / UnitHealthMax('player') * 100)
      if DoomDB.showbg then
         Doom.setHealth(health)
      end
   end
end

function Doom.UNIT_COMBAT(unit, action, avoid, damage)
   if unit == 'player' and action == 'WOUND' then
      -- percentage of life lost
      latest_blow = math.floor(damage / UnitHealthMax('player') * 100)
   end
end

function Doom.COMBAT_TEXT_UPDATE(msgtype, buff)
   if msgtype == 'SPELL_AURA_START' and Doom.powerups[buff] then
      powerup = true
   end
end

function Doom.UNIT_DISPLAYPOWER(unit)
   if unit == 'player' and DoomDB.showbg then
      Doom.setPowerType(UnitPowerType(unit))
   end
end
