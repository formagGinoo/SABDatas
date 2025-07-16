local BaseActivity = require("Base/BaseActivity")
local CommunityEntranceActivity = class("CommunityEntranceActivity", BaseActivity)

function CommunityEntranceActivity.getActivityType(_)
  return MTTD.ActivityType_CommunityEntrance
end

function CommunityEntranceActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgCommunityEntrance
end

function CommunityEntranceActivity.getStatusProto(_)
  return MTTDProto.CmdActCommunityEntrance_Status
end

function CommunityEntranceActivity:OnResetSdpConfig()
end

function CommunityEntranceActivity:checkCondition()
  if not CommunityEntranceActivity.super.checkCondition(self) then
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

function CommunityEntranceActivity.getStatusProto(_)
  return MTTDProto.CmdActCommunityEntrance_Status
end

function CommunityEntranceActivity:GetCommunityCfg()
  return self.m_stSdpConfig.stClientCfg.vCommunityCfg
end

function CommunityEntranceActivity:getSubPanelName()
  return ActivityManager.ActivitySubPanelName.ActivitySPName_CommunityEntrance
end

return CommunityEntranceActivity
