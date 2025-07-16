local BaseActivity = require("Base/BaseActivity")
local ModuleControlActivity = class("ModuleControlActivity", BaseActivity)

function ModuleControlActivity.getActivityType(_)
  return MTTD.ActivityType_ModuleControl
end

function ModuleControlActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgModuleControl
end

function ModuleControlActivity.getStatusProto(_)
  return MTTDProto.CmdActModuleControl_Status
end

function ModuleControlActivity:OnResetSdpConfig()
  self.m_mCommParam = self.m_stSdpConfig.mCommParam
end

function ModuleControlActivity:GetCommonParam()
  return self.m_mCommParam
end

function ModuleControlActivity:GetReportpercentListData()
  if self.m_stSdpConfig.stClientCfg and self.m_stSdpConfig.stClientCfg.vLogReportPercent then
    return self.m_stSdpConfig.stClientCfg.vLogReportPercent
  end
  return nil
end

function ModuleControlActivity:GetFlogControlData()
  if self.m_stSdpConfig.stClientCfg and self.m_stSdpConfig.stClientCfg.stFlogReport then
    return self.m_stSdpConfig.stClientCfg.stFlogReport
  end
  return nil
end

function ModuleControlActivity:CheckShowWaterMark(index)
  if self.m_stSdpConfig.stClientCfg and self.m_stSdpConfig.stClientCfg.mWatermark then
    for _, data in ipairs(self.m_stSdpConfig.stClientCfg.mWatermark) do
      if data.iType == index then
        return data
      end
    end
  end
  return false
end

function ModuleControlActivity:GetCommonParamByKey(sKey)
  return self.m_mCommParam[sKey]
end

return ModuleControlActivity
