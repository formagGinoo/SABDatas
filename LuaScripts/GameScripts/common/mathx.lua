local utils = require("common/utils")
local math = _ENV.math
local assert_arg = utils.assert_arg
local Mathf = CS.UnityEngine.Mathf

local function assert_number(n, s)
  assert_arg(n, s, "number")
end

function math.checknumber(value, base)
  return tonumber(value, base) or 0
end

function math.checkint(value)
  return math.round(math.checknumber(value))
end

function math.round(value)
  assert_number(1, value)
  return math.floor(value + 0.5)
end

function math.newrandomseed()
  local ok, socket = pcall(function()
    return require("socket")
  end)
  if ok then
    math.randomseed(socket.gettime() * 1000)
  else
    math.randomseed(os.time())
  end
  math.random()
  math.random()
  math.random()
  math.random()
end

math.defaultseed = 2147483647
math.commonSeedCallback = nil

function math.setcommonseed(value)
  if math.defaultseed ~= value then
    math.setq()
    math.setr()
  end
  math.defaultseed = value
end

function math.commonseedreset()
  math.commonseed(math.defaultseed)
end

function math.commonrandom(min, max, sign)
  if math.nextSeed == nil then
    math.commonseedreset()
  end
  local result
  if min == nil and max == nil then
    result = math.commonrandomint()
  else
    local range = max - min
    if range == 0 then
      result = min
    else
      result = min + math.commonrandomint() % range
    end
  end
  return result
end

function math.commonrandomneg1to1()
  return 2 * (math.commonrandomint() / math.defaultseed) - 1
end

function math.commonrandom0to1()
  return math.commonrandomint() / math.defaultseed
end

function math.commonseed(seed)
  if seed < 0 then
    seed = seed + math.defaultseed
  end
  math.nextSeed = seed
  if math.nextSeed == 0 then
    math.nextSeed = 1
  end
  if nil ~= math.commonSeedCallback then
    math.commonSeedCallback(seed)
  end
end

local q, r

function math.setq()
  q = math.floor(math.defaultseed / 48271)
end

function math.setr()
  r = math.defaultseed % 48271
end

local function getq()
  if q == nil then
    math.setq()
  end
  return q
end

local function getr()
  if r == nil then
    math.setr()
  end
  return r
end

function math.commonrandomint()
  if math.nextSeed == nil then
    math.commonseedreset()
  end
  local tmpState = math.floor(48271 * (math.nextSeed % getq()) - getr() * (math.nextSeed / getq()))
  if 0 < tmpState then
    math.nextSeed = tmpState
  else
    math.nextSeed = tmpState + math.defaultseed
  end
  return math.nextSeed
end

function math.roundfloor(value, num)
  if num == nil then
    num = 0
  end
  local pow = Mathf.Pow(10, num)
  return math.floor(value * pow + 0.5) / pow
end

function math.angle2radian(angle)
  return angle * math.pi / 180
end

function math.radian2angle(radian)
  return radian / math.pi * 180
end

function math.getintpart(x)
  if 0 <= x then
    return math.floor(x)
  else
    return math.ceil(x)
  end
end

function math.getfloatpart(x)
  if x > math.floor(x) then
    x = x * 10
    x = math.ceil(x)
    x = x / 10
    return tonumber(string.format("%0.1f", x))
  else
    return x
  end
end

function math.getfloatpart4(x)
  if x > math.floor(x) then
    return tonumber(string.format("%0.4f", x))
  else
    return x
  end
end

function math.isnumequal(x, y)
  if math.abs(x - y) < 1.0E-4 then
    return true
  end
  return false
end

function math.clamp(v, min, max)
  return math.min(math.max(v, min), max)
end

function math.ispointequal(pt1, pt2)
  if pt1 == nil or pt2 == nil then
    return false
  end
  if math.isnumequal(pt1.x, pt2.x) and math.isnumequal(pt1.y, pt2.y) then
    return true
  end
  return false
end

local sqrt2 = math.sqrt(2) / 2
local dir8 = {
  [0] = {x = 0, y = 1},
  [45] = {x = sqrt2, y = sqrt2},
  [90] = {x = 1, y = 0},
  [135] = {
    x = sqrt2,
    y = -sqrt2
  },
  [180] = {x = 0, y = -1},
  [225] = {
    x = -sqrt2,
    y = -sqrt2
  },
  [270] = {x = -1, y = 0},
  [315] = {
    x = -sqrt2,
    y = sqrt2
  }
}

function math.GetQuadrant(dx, dy)
  if 0 < dx and 0 < dy then
    return 1
  elseif dx < 0 and 0 < dy then
    return 2
  elseif dx < 0 and dy < 0 then
    return 3
  elseif 0 < dx and dy < 0 then
    return 4
  elseif dx == 0 and dy == 0 then
    return 0
  else
    return nil
  end
end

function math.GetProjOnAngle(A, B, thetaDeg)
  local dx = B.x - A.x
  local dy = B.y - A.y
  local d = dir8[thetaDeg]
  local ux, uy
  if d then
    ux, uy = d.x, d.y
  else
    local thetaRad = thetaDeg * math.pi / 180
    ux = math.cos(thetaRad)
    uy = math.sin(thetaRad)
  end
  local proj_signed = dx * ux + dy * uy
  local proj_abs = math.abs(proj_signed)
  local proj_vec_x = proj_signed * ux
  local proj_vec_y = proj_signed * uy
  local quadrant = math.GetQuadrant(dx, dy)
  return proj_signed, proj_abs, {x = proj_vec_x, y = proj_vec_y}, quadrant
end
