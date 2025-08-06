local BaseObject = require("Base/BaseObject")
local BaseActivity = class("BaseActivity", BaseObject)
BaseActivity.StateID = {
  ActivityState_Active = 1,
  ActivityState_BeforeActive = 2,
  ActivityState_EndActive = 3
}

function BaseActivity.getActivityType(_)
end

function BaseActivity.getSdpConfigProto(_)
end

function BaseActivity.getStatusProto(_)
end

function BaseActivity.getPanelClass(_)
end

function BaseActivity:ctor(stActivityData)
  self:initComponent()
  self:doEvent("OnCreate")
  self:setData(stActivityData)
end

function BaseActivity:initComponent()
  BaseActivity.super.initComponent(self)
  self:addComponent("GameEvent")
  self:addComponent("GameScheduler")
end

function BaseActivity:getDataCacheKey(key)
  return string.format("Activity_%d_%d_%s", self:getType(), self:getID(), key)
end

function BaseActivity:getPanelTemplateId()
  return self:getID() + 10000
end

function BaseActivity:showResourceUI()
end

function BaseActivity:getActivityState()
  return self.m_iActivityState
end

function BaseActivity:checkActivityState()
  if self:isInActivityTime() then
    self.m_iActivityState = self.StateID.ActivityState_Active
  else
    local iServerTime = TimeUtil:GetServerTimeS()
    if iServerTime < self.m_stActivityData.iBeginTime then
      self.m_iActivityState = self.StateID.ActivityState_BeforeActive
    else
      self.m_iActivityState = self.StateID.ActivityState_EndActive
    end
  end
end

function BaseActivity:setData(stActivityData)
  self.m_stActivityData = stActivityData
  self:resetData()
end

function BaseActivity:resetData()
  if self.m_stActivityData.sBriefDescImgLua ~= nil and self.m_stActivityData.sBriefDescImgLua ~= "" then
    local configData = table.unserialize(self.m_stActivityData.sBriefDescImgLua)
    if configData.desc_img_cfg ~= nil then
      local vDescImgCfg = configData.desc_img_cfg
      local vImgList = {}
      for i, v in ipairs(vDescImgCfg) do
        local vCountry = string.split(v.country, ";")
        table.map(vCountry, function(v, k)
          return tonumber(v)
        end)
        vImgList[i] = {
          image = v.brief_desc_img,
          country = v.country,
          vCountry = vCountry
        }
      end
      self.m_stActivityData.vBriefDescImgLua = vImgList
    end
  end
  if self.m_stActivityData.iMinLevel == 0 then
    self.m_stActivityData.iMinLevel = 1
  end
  if self.m_stActivityData.iMaxLevel == 0 then
    self.m_stActivityData.iMaxLevel = 999
  end
  self:resetSdpConfig()
  self:resetStatusData()
  self:resetTimer()
  self:doEvent("OnResetData", self.m_stActivityData)
  self:doEvent("OnPushPanel")
  self:checkActivityState()
  self:broadcastEvent("eGameEvent_Activity_ResetData")
end

function BaseActivity:resetTimer()
  local iServerTime = TimeUtil:GetServerTimeS()
  self:killTimer(self.m_iTimerHandlerShowTimeBegin)
  self.m_iTimerHandlerShowTimeBegin = nil
  local iRemainTime = checknumber(self.m_stActivityData.iShowTimeBegin) - iServerTime
  if 0 < iRemainTime then
    self.m_iTimerHandlerShowTimeBegin = self:setTimer(iRemainTime + 2, 1, function()
      self.m_iTimerHandlerShowTimeBegin = nil
      self:checkActivityState()
      self:broadcastEvent("eGameEvent_Activity_ShowTimeBegin", {
        activityID = self:getID()
      })
      self:broadcastEvent("eGameEvent_Activity_HallActivityChange")
    end)
  end
  self:killTimer(self.m_iTimerHandlerTimeBegin)
  self.m_iTimerHandlerTimeBegin = nil
  iRemainTime = checknumber(self.m_stActivityData.iBeginTime) - iServerTime
  if 0 < iRemainTime then
    self.m_iTimerHandlerTimeBegin = self:setTimer(iRemainTime + 2, 1, function()
      self.m_iTimerHandlerTimeBegin = nil
      self.m_iActivityState = self.StateID.ActivityState_Active
      self:broadcastEvent("eGameEvent_Activity_TimeBegin", {
        activityID = self:getID()
      })
      self:broadcastEvent("eGameEvent_Activity_HallActivityChange")
    end)
  end
  self:killTimer(self.m_iTimerHandlerTimeEnd)
  self.m_iTimerHandlerTimeEnd = nil
  iRemainTime = checknumber(self.m_stActivityData.iEndTime) - iServerTime
  if 0 < iRemainTime then
    self.m_iTimerHandlerTimeEnd = self:setTimer(iRemainTime + 2, 1, function()
      self.m_iTimerHandlerTimeEnd = nil
      self.m_iActivityState = self.StateID.ActivityState_EndActive
      self:broadcastEvent("eGameEvent_Activity_TimeEnd", {
        activityID = self:getID()
      })
      self:broadcastEvent("eGameEvent_Activity_HallActivityChange")
    end)
  end
  self:killTimer(self.m_iTimerHandlerShowTimeEnd)
  self.m_iTimerHandlerShowTimeEnd = nil
  iRemainTime = checknumber(self.m_stActivityData.iShowTimeEnd) - iServerTime
  if 0 < iRemainTime then
    self.m_iTimerHandlerShowTimeEnd = self:setTimer(iRemainTime + 2, 1, function()
      self.m_iTimerHandlerShowTimeEnd = nil
      self:broadcastEvent("eGameEvent_Activity_ShowTimeEnd", {
        activityID = self:getID()
      })
      self:broadcastEvent("eGameEvent_Activity_HallActivityChange")
    end)
  end
  self:doEvent("OnResetTimer")
end

function BaseActivity:resetSdpConfig()
  local proto = self:getSdpConfigProto()
  if proto then
    self.m_stSdpConfig = sdp.unpack(self.m_stActivityData.sSdpConfig, proto)
    self:doEvent("OnResetSdpConfig", self.m_stSdpConfig)
  else
    self.m_stSdpConfig = {}
  end
end

function BaseActivity:resetStatusData()
  local proto = self:getStatusProto()
  if proto then
    self.m_stStatusData = sdp.unpack(self.m_stActivityData.sStatusDataSdp, proto)
    self:doEvent("OnResetStatusData", self.m_stStatusData)
  else
    self.m_stStatusData = {}
  end
end

function BaseActivity:dispose()
  if not self._disposed then
    self._dispose = true
    local iServerTime = TimeUtil:GetServerTimeS()
    local iRemainTime = checknumber(self.m_stActivityData.iEndTime) - iServerTime
    if self.m_iTimerHandlerTimeEnd and iRemainTime <= 0 then
      self.m_iActivityState = self.StateID.ActivityState_EndActive
      self:broadcastEvent("eGameEvent_Activity_TimeEnd", {
        activityID = self:getID()
      })
      self:broadcastEvent("eGameEvent_Activity_HallActivityChange")
    end
    local iRemainShowTime = checknumber(self.m_stActivityData.iShowTimeEnd) - iServerTime
    if self.m_iTimerHandlerShowTimeEnd and iRemainShowTime <= 0 then
      self:broadcastEvent("eGameEvent_Activity_ShowTimeEnd", {
        activityID = self:getID()
      })
      self:broadcastEvent("eGameEvent_Activity_HallActivityChange")
    end
    self:removeAllComponent()
    self:doEvent("OnDispose")
  end
end

function BaseActivity:getID()
  return self.m_stActivityData.iActivityId
end

function BaseActivity:getType()
  return self.m_stActivityData.iActivityType
end

function BaseActivity:getData()
  return self.m_stActivityData
end

function BaseActivity:getTitle()
  return self.m_stActivityData.sTitle
end

function BaseActivity:getDetailDesc()
  return self.m_stActivityData.sDetailDesc
end

function BaseActivity:getBriefDesc()
  return self.m_stActivityData.sBriefDesc
end

function BaseActivity:getConfigParamValue(key)
  if self.m_stActivityData == nil or self.m_stSdpConfig == nil then
    return nil
  end
  return self.m_stSdpConfig[key]
end

function BaseActivity:getConfigParamStrValue(key)
  return self:getConfigParamValue(key) or ""
end

function BaseActivity:getConfigParamIntValue(key)
  return self:getConfigParamValue(key) or 0
end

function BaseActivity:getStatusData()
  return self.m_stStatusData
end

function BaseActivity:getActivityBeginTime()
  return self.m_stActivityData.iBeginTime or 0
end

function BaseActivity:getActivityEndTime()
  return self.m_stActivityData.iEndTime or 0
end

function BaseActivity:getActivityShowBeginTime()
  return self.m_stActivityData.iShowTimeBegin or 0
end

function BaseActivity:getActivityShowEndTime()
  return self.m_stActivityData.iShowTimeEnd or 0
end

function BaseActivity:isInActivityTime()
  return TimeUtil:IsInTime(self.m_stActivityData.iBeginTime, self.m_stActivityData.iEndTime)
end

function BaseActivity:isOnlyInShowTime()
  return not TimeUtil:IsInTime(self.m_stActivityData.iBeginTime, self.m_stActivityData.iEndTime) and TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

function BaseActivity:isInActivityShowTime()
  return TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

function BaseActivity:isInAdvertiseTime()
  if self.m_stActivityData.iBeginTime == nil or self.m_stActivityData.iShowTimeBegin == nil then
    return false
  end
  local iServerTime = TimeUtil:GetServerTimeS()
  local iRemainTime = self.m_stActivityData.iBeginTime - self.m_stActivityData.iShowTimeBegin
  if iRemainTime <= 0 then
    return false
  end
  if iServerTime > self.m_stActivityData.iShowTimeBegin and iServerTime < self.m_stActivityData.iBeginTime then
    return true
  else
    return false
  end
end

function BaseActivity:isInActivityStage()
  local minMainLevelID = self.m_stActivityData.iStageMin or 0
  local maxMainLevelID = self.m_stActivityData.iStageMax or 0
  if minMainLevelID ~= 0 and LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, minMainLevelID) ~= true then
    return false
  end
  if maxMainLevelID ~= 0 and LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, maxMainLevelID) == true then
    return false
  end
  return true
end

function BaseActivity:isInLevel(beginLevel, endLevel)
  if beginLevel == 0 and endLevel == 0 then
    return true
  end
  local curLevel = RoleManager:GetLevel()
  if beginLevel ~= 0 then
    if beginLevel <= curLevel then
      if endLevel == 0 then
        return true
      elseif endLevel >= curLevel then
        return true
      else
        return false
      end
    else
      return false
    end
  else
    return true
  end
end

function BaseActivity:isInActivityLevel()
  return self:isInLevel(self.m_stActivityData.iMinLevel, self.m_stActivityData.iMaxLevel)
end

function BaseActivity:checkCondition()
  if not self:isInActivityLevel() then
    return false
  end
  if not self:isInActivityStage() then
    return false
  end
  return true
end

function BaseActivity:checkShowRed()
  return false
end

function BaseActivity:onActivityStatus(stStatusData, bUpdateView)
  self.m_stActivityData.sStatusDataSdp = stStatusData
  self:resetData()
  if bUpdateView then
    self:broadcastEvent("eGameEvent_Activity_StatusChanged", {
      activityID = self:getID()
    })
    self:broadcastEvent("eGameEvent_Activity_HallActivityChange")
  end
end

function BaseActivity:onActivityChange()
  self:resetData()
  self:broadcastEvent("eGameEvent_Activity_Changed", {
    activityID = self:getID()
  })
  self:broadcastEvent("eGameEvent_Activity_HallActivityChange")
end

function BaseActivity:isNewActivity()
  if self.m_stActivityData.iCornerMarkType == MTTDProto.CmdCornerMarkType_Wait then
    return false
  end
  if self.m_stActivityData ~= nil and self.m_stActivityData.bShowInList ~= nil and not self.m_stActivityData.bShowInList then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  if self:getActivityState() == self.StateID.ActivityState_EndActive then
    return false
  end
  local localValue = LocalDataManager:GetIntSimple("Activity_ID_" .. self:getID(), 0)
  if self:getID() ~= localValue then
    return true
  else
    return false
  end
end

function BaseActivity:getLangText(str)
  if self.m_stActivityData.mMultiLanguage and self.m_stActivityData.mMultiLanguage[str] then
    return self.m_stActivityData.mMultiLanguage[str] or str
  else
    return str
  end
end

function BaseActivity:getAdvertiseRemainTime()
  local activityData = self:getData()
  if activityData.iBeginTime == nil or activityData.iShowTimeBegin == nil then
    return 0
  end
  local iServerTime = TimeUtil:GetServerTimeS()
  local iRemainTime = activityData.iBeginTime - activityData.iShowTimeBegin
  if iRemainTime <= 0 then
    return 0
  end
  if iServerTime > activityData.iShowTimeBegin and iServerTime < activityData.iBeginTime then
    iRemainTime = activityData.iBeginTime - iServerTime
    if iRemainTime <= 0 then
      iRemainTime = 0
    end
    return iRemainTime
  end
  return 0
end

function BaseActivity:getActivityRemainTime()
  if self.m_stActivityData.iBeginTime == nil or self.m_stActivityData.iEndTime == nil then
    return 0
  end
  local iServerTime = TimeUtil:GetServerTimeS()
  local iRemainTime = self.m_stActivityData.iEndTime - iServerTime
  if iRemainTime < 0 then
    iRemainTime = 0
  end
  return math.floor(iRemainTime)
end

function BaseActivity:getShowRemainTime()
  if self.m_stActivityData.iShowTimeBegin == nil or self.m_stActivityData.iShowTimeEnd == nil then
    return 0
  end
  local iServerTime = TimeUtil:GetServerTimeS()
  local iRemainTime = self.m_stActivityData.iShowTimeEnd - iServerTime
  if iRemainTime < 0 then
    iRemainTime = 0
  end
  return iRemainTime
end

function BaseActivity:getValidProductIds()
  local res = {}
  return res
end

function BaseActivity:isProductIDValidate(productID)
  return false
end

function BaseActivity:getRuleText()
  return ""
end

function BaseActivity:isStageRequiredPassed()
  if nil ~= self.m_mClientParamLua and nil ~= self.m_mClientParamLua.require_stage then
    return LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, self.m_mClientParamLua.require_stage)
  end
  return true
end

function BaseActivity:isTotalVipLvlPassed()
  if self:getType() == MTTD.ActivityType_IAPBuy then
    return true
  end
  return false
end

function BaseActivity:getBriefDescImgByCountry()
  local iLangId = CS.MultiLanguageManager.g_iLanguageID
  if self.m_stActivityData.vBriefDescImgLua then
    for i, v in ipairs(self.m_stActivityData.vBriefDescImgLua) do
      if table.indexof(v.vCountry, iLangId) ~= false then
        return v.image
      end
    end
  end
  return nil
end

return BaseActivity
