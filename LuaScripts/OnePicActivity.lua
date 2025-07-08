local BaseActivity = require("Base/BaseActivity")
local OnePicActivity = class("OnePicActivity", BaseActivity)

function OnePicActivity.getActivityType(_)
  return MTTD.ActivityType_OnePicAct
end

function OnePicActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgOnePicAct
end

function OnePicActivity.getStatusProto(_)
  return MTTDProto.CmdActOnePicAct_Status
end

function OnePicActivity:OnResetSdpConfig(m_stSdpConfig)
  self.mOnePicActCfg = {}
  if m_stSdpConfig and m_stSdpConfig.stClientCfg then
    self.mOnePicActCfg = m_stSdpConfig.stClientCfg
  end
end

function OnePicActivity:GetOnePicActCfg()
  return self.mOnePicActCfg
end

function OnePicActivity:checkCondition()
  if not OnePicActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  if not self:isInActivityShowTime() then
    return false
  end
  return true
end

function OnePicActivity:getSubPanelName()
  return ActivityManager.ActivitySubPanelName.ActivitySPName_OnePicActivity
end

return OnePicActivity
