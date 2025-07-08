local BaseActivity = require("Base/BaseActivity")
local SystemUnlockActivity = class("SystemUnlockActivity", BaseActivity)

function SystemUnlockActivity.getActivityType(_)
  return MTTD.ActivityType_SystemSwitch
end

function SystemUnlockActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgSystemSwitch
end

function SystemUnlockActivity.getStatusProto(_)
  return MTTDProto.CmdActSystemSwitch_Status
end

function SystemUnlockActivity:OnResetSdpConfig(m_stSdpConfig)
  self.mSystemCfg = m_stSdpConfig.stCommonCfg.mSystemCfg
end

function SystemUnlockActivity:GetSystemUnlockInfoBySystemID(iSystemID)
  return self.mSystemCfg[iSystemID]
end

function SystemUnlockActivity:IsSystemUnlockBySystemID(iSystemID)
  local info = self:GetSystemUnlockInfoBySystemID(iSystemID)
  if not info then
    return false, false
  end
  local conditionTypeArray = info.vConditionType
  local conditionDataArray = info.vConditionData
  local open_flag, tips_id, unlockType = true, -1, 0
  for index, conditionData in ipairs(conditionDataArray or {}) do
    local conditionType = conditionTypeArray[index]
    if conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.LOCK then
      open_flag = false
    elseif conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.UNLOCK then
      open_flag = true
    elseif conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.LEVEL then
      open_flag = conditionData <= RoleManager:GetLevel()
    elseif conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.CHAPTER then
      open_flag = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, conditionData)
    elseif conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.GUIDE then
      open_flag = GuideManager:CheckSubStepGuideCmp(conditionData)
    elseif conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.STAGE then
      open_flag = ConditionManager:IsConditionUnlock(ConditionType.MainChapter, conditionData)
    elseif conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.GUILD_LEVEL then
      local _, iAllianceLevel = RoleManager:GetRoleAllianceInfo()
      if iAllianceLevel then
        open_flag = conditionData < iAllianceLevel
      else
        open_flag = false
      end
    else
      log.warn("open_conditionType not found : " .. tostring(conditionType))
    end
    if open_flag == false then
      if index <= #info.vClientMessage then
        tips_id = info.vClientMessage[index]
      else
        tips_id = "???"
      end
      return true, open_flag, tips_id
    end
  end
  if info.iForceClose == 1 then
    return true, false, 43001
  end
  return true, open_flag, tips_id
end

function SystemUnlockActivity:OnResetStatusData()
  local str = ""
end

function SystemUnlockActivity:checkCondition()
  return true
end

function SystemUnlockActivity:CheckActivityIsOpen()
  return true
end

return SystemUnlockActivity
