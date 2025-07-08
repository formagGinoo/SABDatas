local sqrt = math.sqrt
local setmetatable = _ENV.setmetatable
local rawset = _ENV.rawset
local rawget = _ENV.rawget
local acos = math.acos
Vector2 = {}
setmetatable(Vector2, Vector2)
local fields = {}

function Vector2.__index(t, k)
  local var = rawget(Vector2, k)
  if var == nil then
    var = rawget(fields, k)
    if var ~= nil then
      return var(t)
    end
  end
  return var
end

function Vector2.New(x, y)
  local v = {
    x = x or 0,
    y = y or 0
  }
  setmetatable(v, Vector2)
  return v
end

function Vector2:Set(x, y)
  self.x = x or 0
  self.y = y or 0
end

function Vector2:Get()
  return self.x, self.y
end

function Vector2:SqrMagnitude()
  return self.x * self.x + self.y * self.y
end

function Vector2:Clone()
  return Vector2.New(self.x, self.y)
end

function Vector2:Normalize()
  local v = self:Clone()
  return v:SetNormalize()
end

function Vector2:SetNormalize()
  local num = self:Magnitude()
  if num == 1 then
    return self
  elseif 1.0E-5 < num then
    self:Div(num)
  else
    self:Set(0, 0)
  end
  return self
end

function Vector2.Cross(lhs, rhs)
  return lhs.x * rhs.y - lhs.y * rhs.x
end

function Vector2.Dot(lhs, rhs)
  return lhs.x * rhs.x + lhs.y * rhs.y
end

function Vector2.Angle(from, to)
  local x1, y1 = from.x, from.y
  local d = sqrt(x1 * x1 + y1 * y1)
  if 1.0E-5 < d then
    x1 = x1 / d
    y1 = y1 / d
  else
    x1, y1 = 0, 0
  end
  local x2, y2 = to.x, to.y
  d = sqrt(x2 * x2 + y2 * y2)
  if 1.0E-5 < d then
    x2 = x2 / d
    y2 = y2 / d
  else
    x2, y2 = 0, 0
  end
  d = x1 * x2 + y1 * y2
  if d < -1 then
    d = -1
  elseif 1 < d then
    d = 1
  end
  return acos(d) * 57.29578
end

function Vector2.Magnitude(v2)
  return sqrt(v2.x * v2.x + v2.y * v2.y)
end

function Vector2:Div(d)
  self.x = self.x / d
  self.y = self.y / d
  return self
end

function Vector2:Mul(d)
  self.x = self.x * d
  self.y = self.y * d
  return self
end

function Vector2:Add(b)
  self.x = self.x + b.x
  self.y = self.y + b.y
  return self
end

function Vector2:Sub(b)
  self.x = self.x - b.x
  self.y = self.y - b.y
  return self
end

function Vector2:__tostring()
  return string.format("[%f,%f]", self.x, self.y)
end

function Vector2.__div(va, d)
  return Vector2.New(va.x / d, va.y / d)
end

function Vector2.__mul(va, d)
  return Vector2.New(va.x * d, va.y * d)
end

function Vector2.__add(va, vb)
  return Vector2.New(va.x + vb.x, va.y + vb.y)
end

function Vector2.__sub(va, vb)
  return Vector2.New(va.x - vb.x, va.y - vb.y)
end

function Vector2.__unm(va)
  return Vector2.New(-va.x, -va.y)
end

function Vector2.__eq(va, vb)
  return va.x == vb.x and va.y == vb.y
end

function fields.up()
  return Vector2.New(0, 1)
end

function fields.right()
  return Vector2.New(1, 0)
end

function fields.zero()
  return Vector2.New(0, 0)
end

function fields.one()
  return Vector2.New(1, 1)
end

fields.magnitude = Vector2.Magnitude
fields.normalized = Vector2.Normalize
fields.sqrMagnitude = Vector2.SqrMagnitude
