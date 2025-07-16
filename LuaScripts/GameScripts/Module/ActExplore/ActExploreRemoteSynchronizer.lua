local base = require("Module/ActExplore/ActExploreSynchronizer")
local ActExploreRemoteSynchronizer = class("ActExploreRemoteSynchronizer", base)

function ActExploreRemoteSynchronizer:ctor(iActId)
  self.iActId = iActId
  self.objectData = {}
  self.isModified = false
end

function ActExploreRemoteSynchronizer:SetServerData(vExplore)
  for _, v in ipairs(vExplore) do
    local object = {
      state = v.iState,
      position = CS.UnityEngine.Vector3(v.fPosX, v.fPosY, v.fPosZ),
      rotation = CS.UnityEngine.Quaternion.Euler(0, v.fRotation, 0),
      counters = v.mCounters or {},
      cfgID = v.iCfgID
    }
    self.objectData[v.iID] = object
  end
end

function ActExploreRemoteSynchronizer:IsObjectDelete(uid)
  local data = self.objectData[uid]
  if data then
    return data.state == -1
  end
  return 0
end

function ActExploreRemoteSynchronizer:GetData(uid)
  return self.objectData[uid]
end

function ActExploreRemoteSynchronizer:GetObjectTransform(uid)
  local data = self.objectData[uid]
  if data then
    return data.position, data.rotation
  end
  return CS.UnityEngine.Vector3.zero, CS.UnityEngine.Quaternion.identity
end

function ActExploreRemoteSynchronizer:GetObjectCounter(uid)
  local data = self.objectData[uid]
  if data then
    return data.counters
  end
  return nil
end

function ActExploreRemoteSynchronizer:OnCounterChange(uid, key, value)
  local data = self.objectData[uid]
  if data ~= nil then
    if data.counters[key] == value then
      return
    end
    data.counters[key] = value
    self.isModified = true
  end
end

function ActExploreRemoteSynchronizer:OnObjectCreate(uid, cfgID)
  local data = self.objectData[uid]
  if data == nil then
    data = {
      position = CS.UnityEngine.Vector3.zero,
      rotation = CS.UnityEngine.Quaternion.identity,
      state = 1,
      cfgID = cfgID,
      counters = {}
    }
    self.objectData[uid] = data
    self.isModified = true
  elseif data.state == 0 then
    data.state = 1
    self.isModified = true
  end
end

function ActExploreRemoteSynchronizer:SetObjectTransform(uid, position, rotation)
  local data = self.objectData[uid]
  if data then
    data.position = position
    data.rotation = rotation
    self.isModified = true
  end
end

function ActExploreRemoteSynchronizer:TakeReward(element)
  HeroActivityManager:ReqHeroActMiniGameFinishCS_UI(self.iActId, element.m_ActivitySubID, element.m_ID)
end

function ActExploreRemoteSynchronizer:OnObjectDestroy(uid)
  local data = self.objectData[uid]
  if data then
    data.state = -1
    self.isModified = true
  end
end

function ActExploreRemoteSynchronizer:SyncToServer()
  local vExplore = {}
  for k, v in pairs(self.objectData) do
    local data = {
      iID = k,
      iState = v.state,
      fPosX = v.position.x,
      fPosY = v.position.y,
      fPosZ = v.position.z,
      fRotation = v.rotation.eulerAngles.y,
      mCounters = v.counters or {},
      iCfgID = v.cfgID or 0
    }
    table.insert(vExplore, data)
  end
  table.sort(vExplore, function(a, b)
    return a.iID < b.iID
  end)
  HeroActivityManager:SetExploreData(self.iActId, vExplore)
  self.isModified = false
end

return ActExploreRemoteSynchronizer
