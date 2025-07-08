local geometric = {}
local this = geometric

function geometric.world2UI(UICamera, wpos, uiParent)
  local uiScreenPosition = UICamera:WorldToScreenPoint(wpos)
  local tempv2 = Vector2.New(uiScreenPosition.x, uiScreenPosition.y)
  local inRect, anchpos = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(uiParent, tempv2, UICamera)
  return anchpos
end

function geometric.worldToUIPoint(camera, worldPos)
  local v_ui = camera:GetComponent("Camera"):ScreenToWorldPoint(worldPos)
  return v_ui
end

function geometric.getDistance(x1, y1, x2, y2)
  return math.roundfloor(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)), 6)
end

function geometric.getDistanceByPoint(point1, point2)
  if point1 == nil or point2 == nil or point1.x == nil or point1.y == nil or point2.x == nil or point2.y == nil then
    return 0
  end
  return math.roundfloor(math.sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y)), 6)
end

function geometric.getDistanceSquare(x1, y1, x2, y2)
  return math.roundfloor((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2), 6)
end

function geometric.getDistanceSquareByPoint(point1, point2)
  return math.roundfloor((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y), 6)
end

function geometric.getDistanceEasy(x1, y1, x2, y2)
  return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
end

function geometric.checkWithLimitData(additionalData, baseData, limitRate)
  local ntemp = math.abs(additionalData)
  local nLimit = baseData * limitRate
  if ntemp > nLimit then
    if additionalData < 0 then
      additionalData = -nLimit
    else
      additionalData = nLimit
    end
  end
  return additionalData
end

function geometric.getLineRadio(src_pt1, src_pt2)
  local radio = (src_pt2.y - src_pt1.y) / (src_pt2.x - src_pt1.x)
  return radio
end

local function getVerticalRadio(src_pt1, src_pt2)
  local radio = -(src_pt2.x - src_pt1.x) / (src_pt1.y - src_pt2.y)
  return radio
end

local function getRadio(src_pt1, src_pt2)
  local radio = (src_pt1.y - src_pt2.y) / (src_pt2.x - src_pt1.x)
  return radio
end

function geometric.getVecRectanglePt(vec_pt1, vec_pt2, recPt1, recPt2, recPt3, recPt4, exceptPt1, exceptPt2)
  local function checkPt(vPt1, vPt2, rPt1, rPt2)
    if exceptPt1 and exceptPt2 and rPt1.x == exceptPt1.x and rPt1.y == exceptPt1.y and rPt2.x == exceptPt2.x and rPt2.y == exceptPt2.y then
      return false
    end
    log.debug("-------------------------------------------------")
    log.debug("vec_pt1:" .. vec_pt1.x .. "  " .. vec_pt1.y)
    log.debug("vec_pt2:" .. vec_pt2.x .. "  " .. vec_pt2.y)
    log.debug("rPt1:" .. rPt1.x .. "  " .. rPt1.y)
    log.debug("rPt2:" .. rPt2.x .. "  " .. rPt2.y)
    local distanceR1 = this.getDistanceFromPointToLine(vPt1, vPt2, rPt1, true)
    local distanceR2 = this.getDistanceFromPointToLine(vPt1, vPt2, rPt2, true)
    log.debug("distanceR1:" .. distanceR1)
    log.debug("distanceR2:" .. distanceR2)
    if distanceR1 * distanceR2 <= 0 then
      local distanceV1 = this.getDistanceFromPointToLine(rPt1, rPt2, vPt1, true)
      local distanceV2 = this.getDistanceFromPointToLine(rPt1, rPt2, vPt2, true)
      log.debug("distanceV1:" .. distanceV1)
      log.debug("distanceV2:" .. distanceV2)
      if distanceV1 * distanceV2 < 0 or math.abs(distanceV2) < math.abs(distanceV1) then
        return true, distanceV1, distanceV2
      end
    end
    return false
  end
  
  local find = false
  local dis1 = 0
  local dis2 = 0
  local findrPt1 = recPt1
  local findrPt2 = recPt2
  find, dis1, dis2 = checkPt(vec_pt1, vec_pt2, findrPt1, findrPt2)
  if find == false then
    findrPt1 = recPt2
    findrPt2 = recPt3
    find, dis1, dis2 = checkPt(vec_pt1, vec_pt2, findrPt1, findrPt2)
  end
  if find == false then
    findrPt1 = recPt3
    findrPt2 = recPt4
    find, dis1, dis2 = checkPt(vec_pt1, vec_pt2, findrPt1, findrPt2)
  end
  if find == false then
    findrPt1 = recPt4
    findrPt2 = recPt1
    find, dis1, dis2 = checkPt(vec_pt1, vec_pt2, findrPt1, findrPt2)
  end
  if find == true then
    local targetPt = Vector2.New(0, 0)
    if 0 < dis2 * dis1 then
      local rate = 1 - math.abs(dis2) / math.abs(dis1)
      targetPt.x = vec_pt1.x + (vec_pt2.x - vec_pt1.x) / rate
      targetPt.y = vec_pt1.y + (vec_pt2.y - vec_pt1.y) / rate
    else
      local rate = math.abs(dis1) / (math.abs(dis1) + math.abs(dis2))
      targetPt.x = vec_pt1.x + (vec_pt2.x - vec_pt1.x) * rate
      targetPt.y = vec_pt1.y + (vec_pt2.y - vec_pt1.y) * rate
    end
    return targetPt, findrPt1, findrPt2
  end
  return nil
end

function geometric.getMirrorPtFromRadio(src_pt1, src_pt2, src_pt3)
  local distance = this.getDistanceFromPointToLine(src_pt1, src_pt2, src_pt3, true)
  local vRadio = getVerticalRadio(src_pt1, src_pt2)
  local tPt1 = this.getPointFromRatio(src_pt3, vRadio, math.abs(distance) * 2, false)
  local tPt2 = this.getPointFromRatio(src_pt3, vRadio, math.abs(distance) * 2, true)
  local distance1 = this.getDistanceFromPointToLine(src_pt1, src_pt2, tPt1, true)
  local distance2 = this.getDistanceFromPointToLine(src_pt1, src_pt2, tPt2, true)
  if distance1 * distance <= 0 then
    return tPt1
  else
    return tPt2
  end
end

function geometric.getMirrorPtFromVerticalRadio(src_pt1, src_pt2, src_pt3, src_pt4)
  local tempPt = this.getVerticalPtFromPointToLine(src_pt1, src_pt2, src_pt3)
  local distance = this.getDistanceFromPointToLine(src_pt3, tempPt, src_pt4, true)
  local radio = getRadio(src_pt1, src_pt2)
  local tPt1 = this.getPointFromRatio(src_pt3, radio, math.abs(distance) * 2, false)
  local tPt2 = this.getPointFromRatio(src_pt3, radio, math.abs(distance) * 2, true)
  local distance1 = this.getDistanceFromPointToLine(src_pt3, tempPt, tPt1, true)
  local distance2 = this.getDistanceFromPointToLine(src_pt3, tempPt, tPt2, true)
  if 0 <= distance1 * distance then
    return tPt1
  else
    return tPt2
  end
end

function geometric.getVerticalPtFromPointToLine(src_pt1, src_pt2, src_pt3)
  local distance = this.getDistanceFromPointToLine(src_pt1, src_pt2, src_pt3, true)
  local vRadio = getVerticalRadio(src_pt1, src_pt2)
  local tPt1 = this.getPointFromRatio(src_pt3, vRadio, math.abs(distance), false)
  local tPt2 = this.getPointFromRatio(src_pt3, vRadio, math.abs(distance), true)
  local distance1 = this.getDistanceFromPointToLine(src_pt1, src_pt2, tPt1, true)
  local distance2 = this.getDistanceFromPointToLine(src_pt1, src_pt2, tPt2, true)
  if math.abs(distance1) < math.abs(distance2) then
    return tPt1
  else
    return tPt2
  end
end

function geometric.getDistanceFromPointToLine(src_pt1, src_pt2, src_pt3, notNeedFloor)
  local pt1 = Vector2.New(math.floor(src_pt1.x), math.floor(src_pt1.y))
  local pt2 = Vector2.New(math.floor(src_pt2.x), math.floor(src_pt2.y))
  local pt3 = Vector2.New(math.floor(src_pt3.x), math.floor(src_pt3.y))
  if notNeedFloor == true then
    pt1 = Vector2.New(src_pt1.x, src_pt1.y)
    pt2 = Vector2.New(src_pt2.x, src_pt2.y)
    pt3 = Vector2.New(src_pt3.x, src_pt3.y)
  end
  local d = ((pt2.y - pt1.y) * pt3.x + (pt1.x - pt2.x) * pt3.y + (pt2.x * pt1.y - pt1.x * pt2.y)) / math.sqrt((pt2.y - pt1.y) * (pt2.y - pt1.y) + (pt1.x - pt2.x) * (pt1.x - pt2.x))
  return d
end

function geometric.getPointFromLineIn2D(pt1, pt2, distanceToPt2)
  local length = this.getDistance(pt1.x, pt1.z, pt2.x, pt2.z)
  if distanceToPt2 >= length then
    return pt2
  elseif math.abs(length - distanceToPt2) < 1.0E-4 then
    return pt2
  end
  if math.isnumequal(length, 0) then
    return pt2
  end
  local percent = (length - distanceToPt2) / length
  local pt3 = Vector3.New(0, 0, 0)
  pt3.x = pt1.x + (pt2.x - pt1.x) * percent
  pt3.y = 0
  pt3.z = pt1.z + (pt2.z - pt1.z) * percent
  return pt3
end

function geometric.getPointFromRay(pt1, pt2, distanceToPt2)
  local length = this.getDistance(pt1.x, pt1.y, pt2.x, pt2.y)
  if length < 1.0E-4 then
    return pt1
  elseif 1.0E-4 > math.abs(length - distanceToPt2) then
    return pt2
  end
  if math.isnumequal(length, 0) then
    return pt2
  end
  local percent = distanceToPt2 / length
  local pt3 = Vector2.New(0, 0)
  pt3.x = pt1.x + (pt2.x - pt1.x) * percent
  pt3.y = pt1.y + (pt2.y - pt1.y) * percent
  return pt3
end

function geometric.getPointFromRay2(pt1, pt2, distanceToPt2)
  if -1.0E-4 <= distanceToPt2 and distanceToPt2 <= 1.0E-4 then
    return pt2
  end
  local length = this.getDistance(pt1.x, pt1.y, pt2.x, pt2.y)
  if math.isnumequal(length, 0) then
    return pt2
  end
  local percent = distanceToPt2 / length
  local pt3 = Vector2.New(0, 0)
  pt3.x = pt2.x + (pt2.x - pt1.x) * percent
  pt3.y = pt2.y + (pt2.y - pt1.y) * percent
  return pt3
end

function geometric.getPointFromRatio(startPoint, ratio, destlen, revert)
  local newpos = Vector2.New(0, 0)
  newpos.x = math.sqrt(destlen * destlen / (1 + ratio * ratio))
  if revert == true then
    newpos.x = -newpos.x
  end
  newpos.y = ratio * newpos.x
  newpos.x = newpos.x + startPoint.x
  newpos.y = startPoint.y - newpos.y
  return newpos
end

function geometric.clacDirection(orginalPoint, targetPoint)
  local degAngle = math.atan(-(targetPoint.y - orginalPoint.y), targetPoint.x - orginalPoint.x) * 180 / math.pi
  if degAngle < 0 then
    degAngle = degAngle + 360
  end
  return degAngle
end

function geometric.isDirectionFaceDown(direction)
  if 0 < direction and direction < 180 then
    return false
  end
  return true
end

function geometric.isDirectionFaceLeft(direction)
  if not direction then
    return false
  end
  if 90 <= direction and direction <= 270 then
    return true
  end
  return false
end

function geometric.clacEllipse(pos1, pos2, aRadius, bRadius)
  local x1 = pos1.x
  local y1 = pos1.y
  local x2 = pos2.x
  local y2 = pos2.y
  local a = aRadius
  local b = bRadius
  if math.abs(x1 - x2) > a + a then
    return nil
  end
  if math.abs(y1 - y2) > b + b then
    return nil
  end
  local r1 = (x1 - x2) / (2 * a)
  local r2 = (y2 - y1) / (2 * b)
  local ntotal = math.sqrt(r1 * r1 + r2 * r2)
  if ntotal < 0 or 1 < ntotal then
    return nil
  end
  local a2 = math.asin(ntotal)
  local a1 = math.atan(r1 / r2)
  local t1 = a1 + a2
  local x0, y0
  if y1 <= y2 then
    x0 = x1 + a * math.cos(t1)
    y0 = y1 + b * math.sin(t1)
  else
    x0 = x1 - a * math.cos(t1)
    y0 = y1 - b * math.sin(t1)
  end
  return Vector2.New(x0, y0)
end

function geometric.bezierAt(a, b, c, d, t)
  return Mathf.pow(1 - t, 3) * a + 3 * t * Mathf.pow(1 - t, 2) * b + 3 * Mathf.pow(t, 2) * (1 - t) * c + Mathf.pow(t, 3) * d
end

function geometric.getAngleDegree(vecDest, vecSrc)
  vecDest = vecDest:Normalize()
  vecSrc = vecSrc:Normalize()
  local fDot = Vector3.Dot(vecDest, vecSrc)
  local fDegree = math.acos(fDot)
  return 180.0 * fDegree / math.pi
end

function geometric.pointinTriangle(P, A, B, C)
  local v0 = C - A
  local v1 = B - A
  local v2 = P - A
  local dot00 = Vector2.Dot(v0, v0)
  local dot01 = Vector2.Dot(v0, v1)
  local dot02 = Vector2.Dot(v0, v2)
  local dot11 = Vector2.Dot(v1, v1)
  local dot12 = Vector2.Dot(v1, v2)
  local inverDeno = 1 / (dot00 * dot11 - dot01 * dot01)
  local u = (dot11 * dot02 - dot01 * dot12) * inverDeno
  if u < 0 or 1 < u then
    return false
  end
  local v = (dot00 * dot12 - dot01 * dot02) * inverDeno
  if v < 0 or 1 < v then
    return false
  end
  return u + v <= 1
end

function geometric.lineIntersectsWithCircle(p1, p2, p3, r)
  local A = (p2.x - p1.x) * (p2.x - p1.x) + (p2.z - p1.z) * (p2.z - p1.z)
  local B = 2 * ((p2.x - p1.x) * (p1.x - p3.x) + (p2.z - p1.z) * (p1.z - p3.z))
  local C = p3.x * p3.x + p3.z * p3.z + p1.x * p1.x + p1.z * p1.z - 2 * (p3.x * p1.x + p3.z * p1.z) - r * r
  local D = B * B - 4 * A * C
  if D < 0 then
    return nil
  end
  local d = math.sqrt(D)
  local u1 = (-B + d) / (2 * A)
  local u2 = (-B - d) / (2 * A)
  local point1
  if 0 <= u1 and u1 <= 1 then
    point1 = Vector3.New(0, 0, 0)
    point1.x = p1.x + u1 * (p2.x - p1.x)
    point1.z = p1.z + u1 * (p2.z - p1.z)
  end
  local point2
  if 0 <= u2 and u2 <= 1 and u2 ~= u1 then
    point2 = Vector3.New(0, 0, 0)
    point2.x = p1.x + u2 * (p2.x - p1.x)
    point2.z = p1.z + u2 * (p2.z - p1.z)
  end
  return point1, point2
end

function geometric.dblcmp(a, b)
  if math.isnumequal(a, b) then
    return 0
  end
  if b < a then
    return 1
  else
    return -1
  end
end

function geometric.dot(x1, z1, x2, z2)
  return x1 * x2 + z1 * z2
end

function geometric.point_on_line(a, b, c)
  return this.dblcmp(this.dot(b.x - a.x, b.z - a.z, c.x - a.x, c.z - a.z), 0)
end

function geometric.cross(x1, z1, x2, z2)
  return x1 * z2 - x2 * z1
end

function geometric.ab_cross_ac(a, b, c)
  return this.cross(b.x - a.x, b.z - a.z, c.x - a.x, c.z - a.z)
end

function geometric.lineIntersectsWithLine(a, b, c, d)
  local s1 = this.ab_cross_ac(a, b, c)
  local s2 = this.ab_cross_ac(a, b, d)
  local s3 = this.ab_cross_ac(c, d, a)
  local s4 = this.ab_cross_ac(c, d, b)
  local d1 = this.dblcmp(s1, 0)
  local d2 = this.dblcmp(s2, 0)
  local d3 = this.dblcmp(s3, 0)
  local d4 = this.dblcmp(s4, 0)
  if (d1 == 1 and d2 == -1 or d1 == -1 and d2 == 1) and (d3 == 1 and d4 == -1 or d3 == -1 and d4 == 1) then
    local p = Vector3.New(0, 0, 0)
    p.x = (c.x * s2 - d.x * s1) / (s2 - s1)
    p.z = (c.z * s2 - d.z * s1) / (s2 - s1)
    return p
  end
  if d1 == 0 and 0 >= this.point_on_line(c, a, b) then
    local p = c:Clone()
    return p
  end
  if d2 == 0 and 0 >= this.point_on_line(d, a, b) then
    local p = d:Clone()
    return p
  end
  if d3 == 0 and 0 >= this.point_on_line(a, c, d) then
    local p = a:Clone()
    return p
  end
  if d4 == 0 and 0 >= this.point_on_line(b, c, d) then
    local p = b:Clone()
    return p
  end
  return nil
end

local v3 = Vector3.New(0, 0, 0)

function geometric.getTempVector3(x, y, z)
  v3:Set(x, y, z)
  return v3
end

local v2 = Vector2.New(0, 0)

function geometric.getTempVector2(x, y)
  v2:Set(x, y)
  return v2
end

local v4 = Vector3.New(0, 0, 0)

function geometric.setPositionXYZ(trans, x, y, z)
  v4:Set(x, y, z)
  trans.position = v4
end

function geometric.setLocalPositionXYZ(trans, x, y, z)
  v4:Set(x, y, z)
  trans.localPosition = v4
end

function geometric.setScaleXYZ(trans, x, y, z)
  v4:Set(x, y, z)
  trans.scale = v4
end

function geometric.setLocalScaleXYZ(trans, x, y, z)
  v4:Set(x, y, z)
  trans.localScale = v4
end

return geometric
