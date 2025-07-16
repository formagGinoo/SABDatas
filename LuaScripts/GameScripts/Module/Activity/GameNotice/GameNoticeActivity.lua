local BaseActivity = require("Base/BaseActivity")
local GameNoticeActivity = class("GameNoticeActivity", BaseActivity)

function GameNoticeActivity.getActivityType(_)
  return MTTD.ActivityType_GameNotice
end

function GameNoticeActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgGameNotice
end

function GameNoticeActivity.getStatusProto(_)
  return MTTDProto.CmdActGameNotice_Status
end

function GameNoticeActivity:OnResetSdpConfig()
  self.m_vNoticeList = {}
  if self.m_stSdpConfig then
    for iIndex, stInfo in pairs(self.m_stSdpConfig.stClientCfg) do
    end
  end
end

function GameNoticeActivity:GetActiveAnnouncementList()
  return self.m_activityAnnouncement
end

function GameNoticeActivity:GetSystemAnnouncementList()
  return self.m_systemAnnouncement
end

function GameNoticeActivity:checkCondition()
  if not self.m_stActivityData then
    return false
  end
  if not GameNoticeActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  if not self:isInActivityShowTime() then
    return false
  end
  if self.m_stSdpConfig.stClientCfg.iNeedChargeMoney and self.m_stSdpConfig.stClientCfg.iNeedChargeMoney > RoleManager:GetTotalRecharge() then
    return false
  end
  if not self:IsShowSurveyAnnounce() then
    return false
  end
  return true
end

function GameNoticeActivity:OnResetStatusData()
end

function GameNoticeActivity:checkShowRed()
end

function GameNoticeActivity:IsShowSurveyAnnounce()
  local paramArray = string.split(self.m_stSdpConfig.stClientCfg.sJumpParamLast, "|")
  if paramArray[1] and paramArray[2] then
    local activity = ActivityManager:GetActivityByID(tonumber(paramArray[2]))
    if activity then
      local activityType = activity:getType()
      if activityType == MTTD.ActivityType_SurveyReward and paramArray[3] and tonumber(paramArray[3]) == 0 and activity:IsSubmitSurvey() then
        return false
      end
    end
  end
  return true
end

return GameNoticeActivity
