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

function ModuleControlActivity:HasGlobalResConfig()
  if self.m_stSdpConfig.stClientCfg and (self.m_stSdpConfig.stClientCfg.bCloseComplianceResourceSwitch ~= nil or self.m_stSdpConfig.stClientCfg.vCloseComplianceResourceGroupID ~= nil) then
    return true
  end
  return false
end

function ModuleControlActivity:CloseGlobalRes()
  if self.m_stSdpConfig.stClientCfg and self.m_stSdpConfig.stClientCfg.bCloseComplianceResourceSwitch then
    return self.m_stSdpConfig.stClientCfg.bCloseComplianceResourceSwitch
  end
  return false
end

function ModuleControlActivity:SetCloseGlobalResGroupID()
  if self.m_stSdpConfig.stClientCfg then
    if self.m_stSdpConfig.stClientCfg.vCloseComplianceResourceGroupID and #self.m_stSdpConfig.stClientCfg.vCloseComplianceResourceGroupID > 0 then
      local groudIdList = CS.System.Collections.Generic.List(CS.System.String)()
      for k, v in ipairs(self.m_stSdpConfig.stClientCfg.vCloseComplianceResourceGroupID) do
        groudIdList:Add(tostring(v))
      end
      CS.MUF.Resource.ResourceManager.SetGlobalResGroup(groudIdList)
      CS.UnityEngine.PlayerPrefs.SetString("CloseComplianceResourceGroupID", table.concat(self.m_stSdpConfig.stClientCfg.vCloseComplianceResourceGroupID, ";"))
    else
      CS.UnityEngine.PlayerPrefs.SetString("CloseComplianceResourceGroupID", "")
    end
  end
end

return ModuleControlActivity
