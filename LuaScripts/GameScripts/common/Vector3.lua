local acos = math.acos
local sqrt = math.sqrt
local max = math.max
local min = math.min
local cos = math.cos
local sin = math.sin
local abs = math.abs
local setmetatable = _ENV.setmetatable
local rawset = _ENV.rawset
local rawget = _ENV.rawget
local rad2Deg = 180 / math.pi
local deg2Rad = math.pi / 180
Vector3 = {class = "Vector3"}
local fields = {}
setmetatable(Vector3, Vector3)

function Vector3.__index(t, k)
  local var = rawget(Vector3, k)
  if var == nil then
    var = rawget(fields, k)
    if var ~= nil then
      return var(t)
    end
  end
  return var
end

function Vector3.__call(t, x, y, z)
  return Vector3.New(x, y, z)
end

function Vector3.New(x, y, z)
  local v = {
    x = x or 0,
    y = y or 0,
    z = z or 0
  }
  setmetatable(v, Vector3)
  return v
end

function Vector3:Set(x, y, z)
  self.x = x or 0
  self.y = y or 0
  self.z = z or 0
end

function Vector3:Get()
  return self.x, self.y, self.z
end

function Vector3:Clone()
  return Vector3.New(self.x, self.y, self.z)
end

function Vector3.Distance(va, vb)
  return sqrt((va.x - vb.x) ^ 2 + (va.y - vb.y) ^ 2 + (va.z - vb.z) ^ 2)
end

function Vector3.Dot(lhs, rhs)
  return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
end

function Vector3.DotXYZ(lx, ly, lz, rx, ry, rz)
  return lx * rx + ly * ry + lz * rz
end

function Vector3.Lerp(from, to, t)
  t = math.clamp(t, 0, 1)
  return Vector3.New(from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t, from.z + (to.z - from.z) * t)
end

function Vector3.LerpXYZ(from, to, t)
  t = math.clamp(t, 0, 1)
  return from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t, from.z + (to.z - from.z) * t
end

function Vector3:Magnitude()
  return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function Vector3.Max(lhs, rhs)
  return Vector3.New(max(lhs.x, rhs.x), max(lhs.y, rhs.y), max(lhs.z, rhs.z))
end

function Vector3.Min(lhs, rhs)
  return Vector3.New(min(lhs.x, rhs.x), min(lhs.y, rhs.y), min(lhs.z, rhs.z))
end

function Vector3:Normalize()
  local v = self:Clone()
  return v:SetNormalize()
end

function Vector3.NormalizeXYZ(x, y, z)
  local num = sqrt(x * x + y * y + z * z)
  if num == 1 then
    return x, y, z
  elseif 1.0E-5 < num then
    x = x / num
    y = y / num
    z = z / num
  else
    x = 0
    y = 0
    z = 0
  end
  return x, y, z
end

function Vector3:SetNormalize()
  local num = self:Magnitude()
  if num == 1 then
    return self
  elseif 1.0E-5 < num then
    self:Div(num)
  else
    self:Set(0, 0, 0)
  end
  return self
end

function Vector3:SqrMagnitude()
  return self.x * self.x + self.y * self.y + self.z * self.z
end

local dot = Vector3.Dot

function Vector3.Angle(from, to)
  return acos(math.clamp(dot(from:Normalize(), to:Normalize()), -1, 1)) * rad2Deg
end

local NormalizeXYZ = Vector3.NormalizeXYZ
local DotXYZ = Vector3.DotXYZ

function Vector3.AngleXYZ(lx, ly, lz, rx, ry, rz)
  lx, ly, lz = NormalizeXYZ(lx, ly, lz)
  rx, ry, rz = NormalizeXYZ(rx, ry, rz)
  local n = DotXYZ(lx, ly, lz, rx, ry, rz)
  return acos(math.clamp(n, -1, 1)) * rad2Deg
end

function Vector3:ClampMagnitude(maxLength)
  if self:SqrMagnitude() > maxLength * maxLength then
    self:SetNormalize()
    self:Mul(maxLength)
  end
  return self
end

function Vector3.OrthoNormalize(va, vb, vc)
  va:SetNormalize()
  vb:Sub(vb:Project(va))
  vb:SetNormalize()
  if vc == nil then
    return va, vb
  end
  vc:Sub(vc:Project(va))
  vc:Sub(vc:Project(vb))
  vc:SetNormalize()
  return va, vb, vc
end

function Vector3.RotateTowards2(from, to, maxRadiansDelta, maxMagnitudeDelta)
  local v2 = to:Clone()
  local v1 = from:Clone()
  local len2 = to:Magnitude()
  local len1 = from:Magnitude()
  v2:Div(len2)
  v1:Div(len1)
  local dota = dot(v1, v2)
  local angle = acos(dota)
  local theta = min(angle, maxRadiansDelta)
  local len = 0
  if len2 > len1 then
    len = min(len2, len1 + maxMagnitudeDelta)
  elseif len1 == len2 then
    len = len1
  else
    len = max(len2, len1 - maxMagnitudeDelta)
  end
  v2:Sub(v1 * dota)
  v2:SetNormalize()
  v2:Mul(sin(theta))
  v1:Mul(cos(theta))
  v2:Add(v1)
  v2:SetNormalize()
  v2:Mul(len)
  return v2
end

function Vector3.RotateTowards1(from, to, maxRadiansDelta, maxMagnitudeDelta)
  local omega, sinom, scale0, scale1, len, theta
  local v2 = to:Clone()
  local v1 = from:Clone()
  local len2 = to:Magnitude()
  local len1 = from:Magnitude()
  v2:Div(len2)
  v1:Div(len1)
  local cosom = dot(v1, v2)
  if len2 > len1 then
    len = min(len2, len1 + maxMagnitudeDelta)
  elseif len1 == len2 then
    len = len1
  else
    len = max(len2, len1 - maxMagnitudeDelta)
  end
  if 1 - cosom > 1.0E-6 then
    omega = acos(cosom)
    theta = min(omega, maxRadiansDelta)
    sinom = sin(omega)
    scale0 = sin(omega - theta) / sinom
    scale1 = sin(theta) / sinom
    v1:Mul(scale0)
    v2:Mul(scale1)
    v2:Add(v1)
    v2:Mul(len)
    return v2
  else
    v1:Mul(len)
    return v1
  end
end

function Vector3.MoveTowards(current, target, maxDistanceDelta)
  local delta = target - current
  local sqrDelta = delta:SqrMagnitude()
  local sqrDistance = maxDistanceDelta * maxDistanceDelta
  if sqrDelta > sqrDistance then
    local magnitude = sqrt(sqrDelta)
    if 1.0E-6 < magnitude then
      delta:Mul(maxDistanceDelta / magnitude)
      delta:Add(current)
      return delta
    else
      return current:Clone()
    end
  end
  return target:Clone()
end

function ClampedMove(lhs, rhs, clampedDelta)
  local delta = rhs - lhs
  if 0 < delta then
    return lhs + min(delta, clampedDelta)
  else
    return lhs - min(-delta, clampedDelta)
  end
end

local overSqrt2 = 0.7071067811865476

local function OrthoNormalVector(vec)
  local res = Vector3.New()
  if abs(vec.z) > overSqrt2 then
    local a = vec.y * vec.y + vec.z * vec.z
    local k = 1 / sqrt(a)
    res.x = 0
    res.y = -vec.z * k
    res.z = vec.y * k
  else
    local a = vec.x * vec.x + vec.y * vec.y
    local k = 1 / sqrt(a)
    res.x = -vec.y * k
    res.y = vec.x * k
    res.z = 0
  end
  return res
end

function Vector3.RotateTowards(current, target, maxRadiansDelta, maxMagnitudeDelta)
  local len1 = current:Magnitude()
  local len2 = target:Magnitude()
  if 1.0E-6 < len1 and 1.0E-6 < len2 then
    local from = current / len1
    local to = target / len2
    local cosom = dot(from, to)
    if 0.999999 < cosom then
      return Vector3.MoveTowards(current, target, maxMagnitudeDelta)
    elseif cosom < -0.999999 then
      local axis = OrthoNormalVector(from)
      local q = Quaternion.AngleAxis(maxRadiansDelta * rad2Deg, axis)
      local rotated = q:MulVec3(from)
      local delta = ClampedMove(len1, len2, maxMagnitudeDelta)
      rotated:Mul(delta)
      return rotated
    else
      local angle = acos(cosom)
      local axis = Vector3.Cross(from, to)
      axis:SetNormalize()
      local q = Quaternion.AngleAxis(min(maxRadiansDelta, angle) * rad2Deg, axis)
      local rotated = q:MulVec3(from)
      local delta = ClampedMove(len1, len2, maxMagnitudeDelta)
      rotated:Mul(delta)
      return rotated
    end
  end
  return Vector3.MoveTowards(current, target, maxMagnitudeDelta)
end

function Vector3.SmoothDamp(current, target, currentVelocity, smoothTime)
  local maxSpeed = math.huge
  local deltaTime = Time.deltaTime
  smoothTime = max(1.0E-4, smoothTime)
  local num = 2 / smoothTime
  local num2 = num * deltaTime
  local num3 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
  local vector2 = target:Clone()
  local maxLength = maxSpeed * smoothTime
  local vector = current - target
  vector:ClampMagnitude(maxLength)
  target = current - vector
  local vec3 = (currentVelocity + vector * num) * deltaTime
  currentVelocity = (currentVelocity - vec3 * num) * num3
  local vector4 = target + (vector + vec3) * num3
  if Vector3.Dot(vector2 - current, vector4 - vector2) > 0 then
    vector4 = vector2
    currentVelocity:Set(0, 0, 0)
  end
  return vector4, currentVelocity
end

function Vector3.Scale(a, b)
  local v = a:Clone()
  return v:SetScale(b)
end

function Vector3:SetScale(b)
  self.x = self.x * b.x
  self.y = self.y * b.y
  self.z = self.z * b.z
  return self
end

function Vector3.Cross(lhs, rhs)
  local x = lhs.y * rhs.z - lhs.z * rhs.y
  local y = lhs.z * rhs.x - lhs.x * rhs.z
  local z = lhs.x * rhs.y - lhs.y * rhs.x
  return Vector3.New(x, y, z)
end

function Vector3.CrossXYZ(lx, ly, lz, rx, ry, rz)
  local x = ly * rz - lz * ry
  local y = lz * rx - lx * rz
  local z = lx * ry - ly * rx
  return x, y, z
end

function Vector3:Equals(other)
  return self.x == other.x and self.y == other.y and self.z == other.z
end

function Vector3.Reflect(inDirection, inNormal)
  local num = -2 * dot(inNormal, inDirection)
  inNormal = inNormal * num
  inNormal:Add(inDirection)
  return inNormal
end

function Vector3.Project(vector, onNormal)
  local num = onNormal:SqrMagnitude()
  if num < 1.175494E-38 then
    return Vector3.New(0, 0, 0)
  end
  local num2 = dot(vector, onNormal)
  local v3 = onNormal:Clone()
  v3:Mul(num2 / num)
  return v3
end

function Vector3.ProjectOnPlane(vector, planeNormal)
  local v3 = Vector3.Project(vector, planeNormal)
  v3:Mul(-1)
  v3:Add(vector)
  return v3
end

function Vector3.Slerp2(from, to, t)
  if t <= 0 then
    return from:Clone()
  elseif 1 <= t then
    return to:Clone()
  end
  local v2 = to:Clone()
  local v1 = from:Clone()
  local len2 = to:Magnitude()
  local len1 = from:Magnitude()
  v2:Div(len2)
  v1:Div(len1)
  local omega = dot(v1, v2)
  local len = (len2 - len1) * t + len1
  local theta = acos(omega) * t
  v2:Sub(v1 * omega)
  v2:SetNormalize()
  v2:Mul(sin(theta))
  v1:Mul(cos(theta))
  v2:Add(v1)
  v2:SetNormalize()
  v2:Mul(len)
  return v2
end

function Vector3.Slerp(from, to, t)
  local omega, sinom, scale0, scale1
  if t <= 0 then
    return from:Clone()
  elseif 1 <= t then
    return to:Clone()
  end
  local v2 = to:Clone()
  local v1 = from:Clone()
  local len2 = to:Magnitude()
  local len1 = from:Magnitude()
  v2:Div(len2)
  v1:Div(len1)
  local len = (len2 - len1) * t + len1
  local cosom = dot(v1, v2)
  if 1 - cosom > 1.0E-6 then
    omega = acos(cosom)
    sinom = sin(omega)
    scale0 = sin((1 - t) * omega) / sinom
    scale1 = sin(t * omega) / sinom
  else
    scale0 = 1 - t
    scale1 = t
  end
  v1:Mul(scale0)
  v2:Mul(scale1)
  v2:Add(v1)
  v2:Mul(len)
  return v2
end

function Vector3:Mul(q)
  if type(q) == "number" then
    self.x = self.x * q
    self.y = self.y * q
    self.z = self.z * q
  else
    self:MulQuat(q)
  end
  return self
end

function Vector3:Div(d)
  self.x = self.x / d
  self.y = self.y / d
  self.z = self.z / d
  return self
end

function Vector3:Add(vb)
  self.x = self.x + vb.x
  self.y = self.y + vb.y
  self.z = self.z + vb.z
  return self
end

function Vector3:Sub(vb)
  self.x = self.x - vb.x
  self.y = self.y - vb.y
  self.z = self.z - vb.z
  return self
end

function Vector3:MulQuat(quat)
  local num = quat.x * 2
  local num2 = quat.y * 2
  local num3 = quat.z * 2
  local num4 = quat.x * num
  local num5 = quat.y * num2
  local num6 = quat.z * num3
  local num7 = quat.x * num2
  local num8 = quat.x * num3
  local num9 = quat.y * num3
  local num10 = quat.w * num
  local num11 = quat.w * num2
  local num12 = quat.w * num3
  local x = (1 - (num5 + num6)) * self.x + (num7 - num12) * self.y + (num8 + num11) * self.z
  local y = (num7 + num12) * self.x + (1 - (num4 + num6)) * self.y + (num9 - num10) * self.z
  local z = (num8 - num11) * self.x + (num9 + num10) * self.y + (1 - (num4 + num5)) * self.z
  self:Set(x, y, z)
  return self
end

function Vector3.AngleAroundAxis(from, to, axis)
  from = from - Vector3.Project(from, axis)
  to = to - Vector3.Project(to, axis)
  local angle = Vector3.Angle(from, to)
  return angle * (Vector3.Dot(axis, Vector3.Cross(from, to)) < 0 and -1 or 1)
end

function Vector3:__tostring()
  return "[" .. self.x .. "," .. self.y .. "," .. self.z .. "]"
end

function Vector3.__div(va, d)
  return Vector3.New(va.x / d, va.y / d, va.z / d)
end

function Vector3.__mul(va, d)
  if type(d) == "number" then
    return Vector3.New(va.x * d, va.y * d, va.z * d)
  else
    local vec = va:Clone()
    vec:MulQuat(d)
    return vec
  end
end

function Vector3.__add(va, vb)
  return Vector3.New(va.x + vb.x, va.y + vb.y, va.z + vb.z)
end

function Vector3.__sub(va, vb)
  return Vector3.New(va.x - vb.x, va.y - vb.y, va.z - vb.z)
end

function Vector3.__unm(va)
  return Vector3.New(-va.x, -va.y, -va.z)
end

function Vector3.__eq(a, b)
  local v = a - b
  local delta = v:SqrMagnitude()
  return delta < 1.0E-10
end

function fields.up()
  return Vector3.New(0, 1, 0)
end

function fields.down()
  return Vector3.New(0, -1, 0)
end

function fields.right()
  return Vector3.New(1, 0, 0)
end

function fields.left()
  return Vector3.New(-1, 0, 0)
end

function fields.forward()
  return Vector3.New(0, 0, 1)
end

function fields.back()
  return Vector3.New(0, 0, -1)
end

function fields.zero()
  return Vector3.New(0, 0, 0)
end

function fields.one()
  return Vector3.New(1, 1, 1)
end

fields.magnitude = Vector3.Magnitude
fields.normalized = Vector3.Normalize
fields.sqrMagnitude = Vector3.SqrMagnitude
luaV3 = Vector3.New
