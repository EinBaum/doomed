-- Create main UI
--
-- Export:
--   Doom.setHealth(health_percentage)
--   Doom.setPower(power_percentage)
--   Doom.setPowerType(powertype)
--   Doom.setFace(index): the index of the face sprite to use (in the
--                        order they were in the original Doom code)
--   Doom.MakeDraggable(f) makes a frame draggable

local SPRITES = 'Interface\\Addons\\Doomed\\sprites.tga'
local SPRITES_SIZE = 256
local PowerColor = {
   [0] = { 0.1, 0.3 , 1 }, -- mana
   [1] = { 1  , 0   , 0 }, -- rage
   [3] = { 0.9, 0.9 , 0 }, -- energy
}

--------------------------------------------------------------------------------
-- Main frame / backdrop
--------------------------------------------------------------------------------

Doom = CreateFrame('Frame', 'Doom', UIParent)
Doom:SetPoint('Top', UIParent, 'Top', 0, 0)
Doom:SetHeight(32)
Doom:SetWidth(150)

function Doom.MakeDraggable(f)
   f:EnableMouse(true)
   f:SetMovable(true)
   f:RegisterForDrag('LeftButton')
   f:SetScript('OnDragStart', f.StartMoving)
   f:SetScript('OnDragStop', f.StopMovingOrSizing)
end
Doom.MakeDraggable(Doom)

Doom.bar = Doom:CreateTexture(nil, 'BACKGROUND')
Doom.bar:SetAllPoints(Doom)
Doom.bar:SetTexture(SPRITES)
Doom.bar:SetTexCoord(106/SPRITES_SIZE, 1, 224/SPRITES_SIZE, 1)

-- add texture to main frame
local function texture(x, y, width, height)
   local t = Doom:CreateTexture(nil, 'ARTWORK')
   t:SetPoint('TopLeft', Doom, 'TopLeft', x, y)
   t:SetWidth(width)
   t:SetHeight(height)
   t:SetTexture(SPRITES)
   t:SetTexCoord(0,0,0,0)
   return t
end

--------------------------------------------------------------------------------
-- Face widget
--------------------------------------------------------------------------------

Doom.face = texture(59, -1, 32, 32)

local F_TILES = 8-- sizeof sprites texture / sizeof face sprite
function Doom.setFace(index)
   local y = math.floor(index / F_TILES)
   local x = math.floor(index - y*F_TILES) / F_TILES
   y = y / F_TILES
   Doom.face:SetTexCoord(x, x+1/F_TILES, y, y+1/F_TILES)
end

--------------------------------------------------------------------------------
-- Label for power (energy/rage/mana)
--------------------------------------------------------------------------------

local pl_width = 43
local pl_height = 6
Doom.powerlabel = texture(100, -23, pl_width, pl_height)

function setPowerLabel(powertype)
   local y = 246                          -- "power"
   if     powertype == 0 then y = 232     -- "mana"
   elseif powertype == 1 then y = 239     -- "rage"
   elseif powertype == 3 then y = 225 end -- "energy"
   local x, y, size = 62/SPRITES_SIZE, y/SPRITES_SIZE
   Doom.powerlabel:SetTexCoord(x, x + pl_width/SPRITES_SIZE, y, y + pl_height/SPRITES_SIZE)
end

--------------------------------------------------------------------------------
-- Health and power text
--------------------------------------------------------------------------------

-- tiles for the health and energy text and shadow
local x, y, gap, tile = -2, -3, 14, 16

local function digit(x, y)
   local dig = texture(x, y, tile, tile)
   dig.shadow = texture(x, y, tile, tile)
   return dig
end

Doom.health = {
   digit(x,       y),
   digit(x+gap,   y),
   digit(x+gap*2, y),
   digit(x+gap*3, y),
}

x = 90 -- offset of power digits relative to health digits
Doom.power = {
   digit(x,       y),
   digit(x+gap,   y),
   digit(x+gap*2, y),
   digit(x+gap*3, y),
}

local function setTextColor(digits, color)
   local r,g,b = unpack(color)
   for i=1,4 do
      digits[i]:SetVertexColor(r, g, b)
   end
end

function Doom.setPowerType(powertype)
   setTextColor(Doom.power, PowerColor[powertype] or PowerColor[0])
   setPowerLabel(powertype)
end

local DIGIT_OFFSET, SHADOW_OFFSET = 194, 177  -- font y-offset
local D_TILES = 16 -- sizeof sprites texture / sizeof digit sprite
local DIGIT_SIZE = 1/D_TILES
local function setDigit(digit, num)
   local x = (math.floor(num) + 4) / D_TILES
   local y = DIGIT_OFFSET/SPRITES_SIZE
   digit:SetTexCoord(x, x+DIGIT_SIZE, y, y+DIGIT_SIZE)
   y = SHADOW_OFFSET/SPRITES_SIZE
   digit.shadow:SetTexCoord(x, x+DIGIT_SIZE, y, y+DIGIT_SIZE)
end

local function setDigits(digits, num)
   local blank = 11
   setDigit (digits[1], (num == 100) and 1 or blank)
   setDigit (digits[2], (num == 100 and 0) or (num >= 10 and num/10) or blank)
   setDigit (digits[3], math.mod(num, 10))
end

function Doom.setHealth(percent)
   setDigits(Doom.health, percent)
end

function Doom.setPower(percent)
   setDigits(Doom.power, percent)
end

-- intialize percent symbol and health color (these don't change)
setTextColor(Doom.health, PowerColor[1])
setDigit(Doom.power [4], 10)
setDigit(Doom.health[4], 10)
