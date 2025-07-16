local BaseActivity = require("Base/BaseActivity")
local RechargeBackActivity = class("RechargeBackActivity", BaseActivity)

function RechargeBackActivity.getActivityType(_)
  return MTTD.ActivityType_RechargeBack
end

function RechargeBackActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgRechargeBack
end

function RechargeBackActivity.getStatusProto(_)
  return MTTDProto.CmdActRechargeBack_Status
end

function RechargeBackActivity:OnResetSdpConfig()
  self.m_vNoticeList = {}
  if self.m_stSdpConfig then
    for iIndex, stInfo in pairs(self.m_stSdpConfig.stClientCfg) do
    end
  end
end

function RechargeBackActivity:OnResetStatusData()
end

function RechargeBackActivity:getSubPanelName()
  return ActivityManager.ActivitySubPanelName.ActivitySPName_RechargeBack
end

return RechargeBackActivity
