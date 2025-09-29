local Job_Startup_CheckGlobalRes_Impl = {}

function Job_Startup_CheckGlobalRes_Impl.OnCheckGlobalRes(jobNode)
  if ChannelManager:IsChinaChannel() then
    local vModuleControlActivityList = ActivityManager:GetActivityListByType(MTTD.ActivityType_ModuleControl)
    local globalResControlActivity
    for k, v in ipairs(vModuleControlActivityList) do
      if v:HasGlobalResConfig() then
        globalResControlActivity = v
        break
      end
    end
    local oldUseGlobal = CS.MUF.Resource.ResourceManager.GetUseGlobal()
    if globalResControlActivity and globalResControlActivity:CloseGlobalRes() then
      CS.MUF.Resource.ResourceManager.SetUseGlobal(false)
      CS.UnityEngine.PlayerPrefs.SetInt("CloseComplianceResourceSwitch", 1)
    else
      CS.MUF.Resource.ResourceManager.SetUseGlobal(CS.MUF.Resource.ResourceManager.GetUseGlobalLocal())
      CS.UnityEngine.PlayerPrefs.SetInt("CloseComplianceResourceSwitch", 0)
    end
    local savedUseGlobalLocal = CS.UnityEngine.PlayerPrefs.GetInt("UseGlobalLocal", -1)
    local useGlobalLocal = CS.MUF.Resource.ResourceManager.GetUseGlobalLocal() and 1 or 0
    if useGlobalLocal == -1 or useGlobalLocal ~= savedUseGlobalLocal then
      ReportManager:ReportClientGlobalResEnabled(useGlobalLocal)
      CS.UnityEngine.PlayerPrefs.SetInt("UseGlobalLocal", useGlobalLocal)
    end
    local oldGroupIDStr = CS.UnityEngine.PlayerPrefs.GetString("CloseComplianceResourceGroupID", "")
    local mOldGroupID = {}
    if oldGroupIDStr ~= "" then
      local vOldGroupID = string.split(oldGroupIDStr, ";")
      for k, v in ipairs(vOldGroupID) do
        mOldGroupID[v] = 1
      end
    end
    if CS.MUF.Resource.ResourceManager.GetUseGlobal() then
      if globalResControlActivity then
        globalResControlActivity:SetCloseGlobalResGroupID()
      else
        CS.MUF.Resource.ResourceManager.SetGlobalResGroup(nil)
        CS.UnityEngine.PlayerPrefs.SetString("CloseComplianceResourceGroupID", "")
      end
    else
      CS.UnityEngine.PlayerPrefs.SetString("CloseComplianceResourceGroupID", "")
    end
    local newUseGlobal = CS.MUF.Resource.ResourceManager.GetUseGlobal()
    if newUseGlobal and CS.MUF.Resource.ResourceManager.NeedReloadDocument() then
      Job_Startup_CheckGlobalRes_Impl.DoProcess(jobNode)
    else
      jobNode.Status = JobStatus.Success
    end
  else
    jobNode.Status = JobStatus.Success
  end
end

function Job_Startup_CheckGlobalRes_Impl.RefreshMultiLan()
  log.info("Job_Startup_CheckGlobalRes_Impl.RefreshMultiLan")
  CS.MUF.Resource.ResourceManager.SetUseLanguageGlobal(false)
  do return end
  local lanResObj = CS.LanResObj()
  lanResObj:Init()
  CS.MultiLanguageManager.Instance:ReloadLanguageConfig()
  ConfigManager:RefreshConfigMultiLan(function(fUnitProgress)
  end, function()
    for id, csui in pairs(StackFlow.UIs) do
      if csui ~= nil then
        csui:RefreshMultiLanguage()
      end
    end
    for id, csui in pairs(StackPopup.UIs) do
      if csui ~= nil then
        csui:RefreshMultiLanguage()
      end
    end
    for id, csui in pairs(StackTop.UIs) do
      if csui ~= nil then
        csui:RefreshMultiLanguage()
      end
    end
    for id, csui in pairs(StackSpecial.UIs) do
      if csui ~= nil then
        csui:RefreshMultiLanguage()
      end
    end
  end)
end

function Job_Startup_CheckGlobalRes_Impl.RefreshDocument()
  log.info("Job_Startup_CheckGlobalRes_Impl.RefreshDocument")
  CS.MUF.Resource.ResourceManager.SetUseDocumentGlobal(true)
  local vDocument = CS.MUF.Resource.ResourceManager.GetGlobalResGroup("document")
  if vDocument and vDocument.Length > 0 then
    CS.AssetBundleHolder.Instance:ReleaseAB("Document/Document.unity3d")
    CS.MUF.Resource.ResourceManager.UnloadAsset("Document/Document.unity3d", CS.MUF.Resource.ResourceType.AssetBundle)
    CS.MUF.Resource.ResourceManager.ReloadLocation("Document/Document.unity3d", CS.MUF.Resource.ResourceType.AssetBundle)
    for i = 0, vDocument.Length - 1 do
      local strDocument = vDocument[i]
      CS.MUF.Resource.ResourceManager.ReloadLocation(strDocument, CS.MUF.Resource.ResourceType.Document)
      local config = ConfigManager:GetConfigInsByName(string.gsub(strDocument, "%.%w+$", ""))
      if config then
        config:Init()
      end
    end
    CS.AssetBundleHolder.Instance:HoldCommonAssetBundle()
  end
  GameManager:OnComplianceSwitch()
end

function Job_Startup_CheckGlobalRes_Impl.DoProcess(jobNode)
  log.info("Job_Startup_CheckGlobalRes_Impl.DoProcess")
  local vResourceAB = {}
  
  local function OnDownloadStart(curBytes, totalBytes)
  end
  
  local function OnDownloadProgress(curBytes, totalBytes, speed)
  end
  
  local function OnDownloadComplete(ret)
    if ret then
      Job_Startup_CheckGlobalRes_Impl.RefreshMultiLan()
      Job_Startup_CheckGlobalRes_Impl.RefreshDocument()
    end
    jobNode.Status = JobStatus.Success
  end
  
  if ChannelManager:IsWindows() then
    CS.MUF.Download.DownloadResource.Instance.BSkipDownload = false
  end
  if CS.MUF.Download.DownloadResource.Instance:IsOpenDownloadEnsurance() and CS.MUF.Download.DownloadResource.Instance:ShouldDownloadResource("Document.unity3d", CS.MUF.Resource.ResourceType.Document) then
    vResourceAB[#vResourceAB + 1] = "Global_Res/Document/Document.unity3d"
  end
  if CS.MUF.Download.DownloadResource.Instance:IsOpenDownloadEnsurance() and CS.MUF.Download.DownloadResource.Instance:ShouldDownloadResource("AllLanguageCN.unity3d", CS.MUF.Resource.ResourceType.Language) then
    vResourceAB[#vResourceAB + 1] = "Global_Res/Document/AllLanguageCN.unity3d"
  end
  if ChannelManager:IsWindows() then
    CS.MUF.Download.DownloadResource.Instance.BSkipDownload = true
  end
  if 0 < #vResourceAB then
    local eNetworkStatus = DownloadManager.NetworkStatus.Mobile
    DownloadManager:DownloadResource(nil, nil, "GlobalRes", OnDownloadStart, OnDownloadProgress, OnDownloadComplete, 0, eNetworkStatus, vResourceAB)
  else
    Job_Startup_CheckGlobalRes_Impl.RefreshMultiLan()
    Job_Startup_CheckGlobalRes_Impl.RefreshDocument()
    jobNode.Status = JobStatus.Success
  end
end

function Job_Startup_CheckGlobalRes_Impl.OnCheckGlobalResSuccess(jobNode)
end

function Job_Startup_CheckGlobalRes_Impl.OnCheckGlobalResFailed(jobNode)
end

function Job_Startup_CheckGlobalRes_Impl.OnCheckGlobalResTimeOut(jobNode)
end

function Job_Startup_CheckGlobalRes_Impl.OnCheckGlobalResDispose(jobNode)
end

return Job_Startup_CheckGlobalRes_Impl
