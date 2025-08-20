local BaseActivity = require("Base/BaseActivity")
local UpTimeManagerActivity = class("UpTimeManagerActivity", BaseActivity)

function UpTimeManagerActivity.getActivityType(_)
  return MTTD.ActivityType_UpTimeManager
end

function UpTimeManagerActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgUpTimeManager
end

function UpTimeManagerActivity.getStatusProto(_)
  return MTTDProto.CmdActUpTimeManager_Status
end

function UpTimeManagerActivity:OnResetSdpConfig(m_stSdpConfig)
  self.m_stClientCfg = m_stSdpConfig.stClientCfg
end

function UpTimeManagerActivity:OnResetStatusData()
end

function UpTimeManagerActivity:checkCondition()
  return true
end

function UpTimeManagerActivity:CheckActivityIsOpen()
  return true
end

function UpTimeManagerActivity:GetHeroHideStatusByID(conditionID)
  if not conditionID then
    return
  end
  if not self.m_stClientCfg then
    return
  end
  local statusMap = self.m_stClientCfg.mHero
  if not statusMap then
    return
  end
  local tempData = statusMap[conditionID]
  if not tempData then
    return
  end
  local curTimer = TimeUtil:GetServerTimeS()
  local conditionTimer = tempData.iUnlockTime
  if curTimer >= conditionTimer then
    return true, tempData.iShield
  end
  return false
end

function UpTimeManagerActivity:GetBackgroundHideStatusByID(conditionID)
  if not conditionID then
    return
  end
  if not self.m_stClientCfg then
    return
  end
  local statusMap = self.m_stClientCfg.mBackground
  if not statusMap then
    return
  end
  local tempData = statusMap[conditionID]
  if not tempData then
    return
  end
  local curTimer = TimeUtil:GetServerTimeS()
  local conditionTimer = tempData.iUnlockTime
  if curTimer >= conditionTimer then
    return true, tempData.iShield
  end
  return false
end

function UpTimeManagerActivity:GetPlayerHeadHideStatusByID(conditionID)
  if not conditionID then
    return
  end
  if not self.m_stClientCfg then
    return
  end
  local statusMap = self.m_stClientCfg.mPlayerHead
  if not statusMap then
    return
  end
  local tempData = statusMap[conditionID]
  if not tempData then
    return
  end
  local curTimer = TimeUtil:GetServerTimeS()
  local conditionTimer = tempData.iUnlockTime
  if curTimer >= conditionTimer then
    return true, tempData.iShield
  end
  return false
end

function UpTimeManagerActivity:GetHeadFrameStatusByID(conditionID)
  if not conditionID then
    return
  end
  if not self.m_stClientCfg then
    return
  end
  local statusMap = self.m_stClientCfg.mHeadFrame
  if not statusMap then
    return
  end
  local tempData = statusMap[conditionID]
  if not tempData then
    return
  end
  local curTimer = TimeUtil:GetServerTimeS()
  local conditionTimer = tempData.iUnlockTime
  if curTimer >= conditionTimer then
    return true, tempData.iShield
  end
  return false
end

function UpTimeManagerActivity:GetPlayerBgStatusByID(conditionID)
  if not conditionID then
    return
  end
  if not self.m_stClientCfg then
    return
  end
  local statusMap = self.m_stClientCfg.mHeadFrame
  if not statusMap then
    return
  end
  local tempData = statusMap[conditionID]
  if not tempData then
    return
  end
  local curTimer = TimeUtil:GetServerTimeS()
  local conditionTimer = tempData.iUnlockTime
  if curTimer >= conditionTimer then
    return true, tempData.iShield
  end
  return false
end

function UpTimeManagerActivity:GetFashionStatusByID(conditionID)
  if not conditionID then
    return
  end
  if not self.m_stClientCfg then
    return
  end
  local statusMap = self.m_stClientCfg.mFashion
  if not statusMap then
    return
  end
  local tempData = statusMap[conditionID]
  if not tempData then
    return
  end
  local curTimer = TimeUtil:GetServerTimeS()
  local conditionTimer = tempData.iUnlockTime
  if curTimer >= conditionTimer then
    return true, tempData.iShield
  end
  return false
end

function UpTimeManagerActivity:GetRogueExclusiveStatusByID(conditionID)
  if not conditionID then
    return
  end
  if not self.m_stClientCfg then
    return
  end
  local statusMap = self.m_stClientCfg.mRogueItem
  if not statusMap then
    return
  end
  local tempData = statusMap[conditionID]
  if not tempData then
    return
  end
  local curTimer = TimeUtil:GetServerTimeS()
  local conditionTimer = tempData.iUnlockTime
  if curTimer >= conditionTimer then
    return true, tempData.iShield
  end
  return false
end

return UpTimeManagerActivity
