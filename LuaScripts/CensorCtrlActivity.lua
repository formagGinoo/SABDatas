local BaseActivity = require("Base/BaseActivity")
local CensorCtrlActivity = class("CensorCtrlActivity", BaseActivity)

function CensorCtrlActivity.getActivityType(_)
  return MTTD.ActivityType_Censor
end

function CensorCtrlActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgCensor
end

function CensorCtrlActivity.getStatusProto(_)
  return MTTDProto.CmdActCensor_Status
end

function CensorCtrlActivity:OnResetSdpConfig(m_stSdpConfig)
  self.m_stClientCfg = m_stSdpConfig.stCommonCfg
  if self:IsInCensor() then
    CS.MUF.ActionEditor.VideoPlayPlayer.DisableVideoByActivity = true
  end
end

function CensorCtrlActivity:OnResetStatusData()
end

function CensorCtrlActivity:checkCondition()
  return true
end

function CensorCtrlActivity:CheckActivityIsOpen()
  return true
end

function CensorCtrlActivity:IsInCensor()
  if not self.m_stClientCfg then
    return false
  end
  local isCensor = self.m_stClientCfg.bCensor or 0
  return 0 < isCensor
end

function CensorCtrlActivity:dispose()
  self.super.dispose(self)
  CS.MUF.ActionEditor.VideoPlayPlayer.DisableVideoByActivity = false
end

return CensorCtrlActivity
