local Job_Startup_DownloadAllResource_Impl = {}
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function Job_Startup_DownloadAllResource_Impl.OnDownloadAllResource(jobNode)
  local function OnDownloadCompleteAfter()
    ReportManager:ReportLoginProcess("DownloadAllResource", "Success")
    
    local versionContext = CS.VersionContext.GetContext()
    local sLocalResVer = CS.VersionUtil.GetResVer(versionContext.ClientLocalVersion)
    LocalDataManager:SetStringSimple("Login_Download_LocalVersion", sLocalResVer)
    if CS.GameQualityManager.Instance.IsSimulator then
      DownloadManager:SetThrottleNetSpeed(20971520)
    end
    if not CS.UI.UILuaHelper.IsUnityEditor() then
      DownloadManager:DownloadAddResAll()
    end
    StackSpecial:TryLoadUI(UIDefines.ID_FORM_VIEDO, nil, nil)
    StackSpecial:TryLoadUI(UIDefines.ID_FORM_DIALOGUE, nil, nil)
    StackSpecial:TryLoadUI(UIDefines.ID_FORM_DIALOGUECAPTIONS, nil, nil)
    StackSpecial:TryLoadUI(UIDefines.ID_FORM_BLACKTOP, nil, nil)
    StackSpecial:RegisterUIAlwaysUpdate(UIDefines.ID_FORM_BLACKTOP)
    StackSpecial:TryLoadUI(UIDefines.ID_FORM_GUIDE, nil, nil)
    jobNode.Status = JobStatus.Success
  end
  
  if ChannelManager:IsWindows() then
    OnDownloadCompleteAfter()
    return
  end
  ReportManager:ReportLoginProcess("DownloadAllResource", "Start")
  local iDownloadBigSize = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("LoginMinResourceLimit").m_Value) * 1024 * 1024
  local iNewbieMainLevelID = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("NewbieMainLevelID").m_Value)
  local bNewbie = not LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, iNewbieMainLevelID)
  local sNewbiePrefix = bNewbie and "Newbie_" or "Baisc_"
  local sCoreResourcePackName, sExpansionResourcePackName = DownloadManager:GetLoginResourcePackName()
  local vFilePathShouldDownload = {}
  local isForceDownload = RoleManager:GetABTestDownloadAllResourceNewbie() == 2
  local vPackage = {}
  local vExtraResource = {}
  local loginDownloadTipsSelect = LocalDataManager:GetIntSimple("LoginDownloadTipsSelect", 2)
  if loginDownloadTipsSelect == 2 then
    local sPackages = ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName(sCoreResourcePackName).m_Value
    local vPackages = string.split(sPackages, "/")
    for k, v in ipairs(vPackages) do
      if not bNewbie and v == "Pack_Hall" then
      else
        vPackage[#vPackage + 1] = {
          sName = v,
          eType = DownloadManager.ResourcePackageType.Custom
        }
      end
    end
    local levelMainHelper = LevelManager:GetLevelMainHelper()
    local chapterCfg = levelMainHelper:GetCurrentLevelCfg(LevelManager.MainLevelSubType.MainStory)
    if chapterCfg and chapterCfg.m_ChapterID <= 6 then
      for i = chapterCfg.m_ChapterID, 6 do
        if i == 1 then
          vPackage[#vPackage + 1] = {
            sName = "Pack_0-3",
            eType = DownloadManager.ResourcePackageType.Custom
          }
        else
          local sChapterName = string.format("Pack_MainLevel_%d", i - 1)
          vPackage[#vPackage + 1] = {
            sName = sChapterName,
            eType = DownloadManager.ResourcePackageType.Custom
          }
        end
      end
    end
    sPackages = ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName(sExpansionResourcePackName).m_Value
    vPackages = string.split(sPackages, "/")
    for k, v in ipairs(vPackages) do
      vPackage[#vPackage + 1] = {
        sName = v,
        eType = DownloadManager.ResourcePackageType.Custom
      }
    end
    local stLanguageElment = CData_MultiLanguage:GetValue_ByID(CS.MultiLanguageManager.g_iLanguageID)
    vExtraResource[#vExtraResource + 1] = {
      sName = "AllLanguage" .. stLanguageElment.m_LanguageObject,
      eType = DownloadManager.ResourceType.Language
    }
    vExtraResource[#vExtraResource + 1] = {
      sName = "AddLanguage" .. stLanguageElment.m_LanguageObject,
      eType = DownloadManager.ResourceType.Language
    }
    vExtraResource[#vExtraResource + 1] = {
      sName = "LanResObj_" .. stLanguageElment.m_Translation .. "_add",
      eType = DownloadManager.ResourceType.LanResObj
    }
  end
  if 0 < #vPackage then
    vFilePathShouldDownload = DownloadManager:GetResourceABList(vPackage, vExtraResource)
  end
  local lTotalBytesAll = DownloadManager:GetResourceABListTotalBytes(vFilePathShouldDownload)
  local lDownloadedBytesAll = DownloadManager:GetResourceABListDownloadedBytes(vFilePathShouldDownload)
  if lTotalBytesAll - lDownloadedBytesAll <= 0 then
    ReportManager:ReportLoginProcess("DownloadAllResource", "NoNeedDownload")
    OnDownloadCompleteAfter()
    return
  end
  
  local function OnConfirmDownloadAllResource(vPackage, vExtraResource, lSizeTotal, lSizeDownloaded, eNetworkStatus, vResourceABSpecified)
    local bDownloadBig = lSizeTotal - lSizeDownloaded > iDownloadBigSize
    ReportManager:ReportLoginProcess("DownloadAllResource", sNewbiePrefix .. "Download_" .. (bDownloadBig and "Big" or "Small"))
    local stDownloadInfo = {
      lCurBytes = lSizeDownloaded,
      lTotalBytes = lSizeTotal,
      bShow = true
    }
    if bDownloadBig then
      StackFlow:Push(UIDefines.ID_FORM_LOGINDOWNLOAD, stDownloadInfo)
    else
      jobNode.UnitProgress = 1
      local fJobProgressMax = jobNode.Graph:GetJobProgress()
      jobNode.UnitProgress = 0
      local fJobProgressMin = jobNode.Graph:GetJobProgress()
      EventCenter.Broadcast(EventDefine.eGameEvent_Login_SetProgressClamp, {fMin = fJobProgressMin, fMax = fJobProgressMax})
    end
    
    local function OnDownloadStart(curBytes, totalBytes)
      curBytes = math.max(curBytes - lSizeDownloaded, 0)
      totalBytes = math.max(totalBytes - lSizeDownloaded, 1)
      local sProgress = DownloadManager:GetDownloadProgressStr(curBytes, totalBytes)
      log.info("DownloadAll Progress: " .. sProgress)
      if bDownloadBig then
        stDownloadInfo.lCurBytes = curBytes
        stDownloadInfo.lTotalBytes = totalBytes
        EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgressBig, stDownloadInfo)
      else
        EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
      end
    end
    
    local function OnDownloadProgress(curBytes, totalBytes, speed)
      curBytes = math.max(curBytes - lSizeDownloaded, 0)
      totalBytes = math.max(totalBytes - lSizeDownloaded, 1)
      jobNode.UnitProgress = curBytes / totalBytes
      local sProgress = DownloadManager:GetDownloadProgressStr(curBytes, totalBytes)
      log.info("DownloadAll Progress: " .. sProgress)
      if bDownloadBig then
        stDownloadInfo.lCurBytes = curBytes
        stDownloadInfo.lTotalBytes = totalBytes
        EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgressBig, stDownloadInfo)
      else
        EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
      end
    end
    
    local function OnDownloadComplete(ret)
      log.info("DownloadAll Complete: " .. tostring(ret))
      if not ret then
        ReportManager:ReportLoginProcess("DownloadAllResource", sNewbiePrefix .. "Download_" .. (bDownloadBig and "Big" or "Small") .. "Fail")
        jobNode.Status = JobStatus.Failed
        log.error("TGRP DownloadAll Failed")
        utils.CheckAndPushCommonTips({
          tipsID = 9977,
          bLockBack = true,
          func1 = function()
            CS.ApplicationManager.Instance:RestartGame()
          end
        })
        return
      end
      if bDownloadBig then
        stDownloadInfo.lCurBytes = stDownloadInfo.lTotalBytes
        stDownloadInfo.bShow = false
        EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgressBig, stDownloadInfo)
      else
        EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = false})
        jobNode.UnitProgress = 1
        EventCenter.Broadcast(EventDefine.eGameEvent_Login_SetProgressClamp, {
          fMin = jobNode.Graph:GetJobProgress(),
          fMax = 1,
          jobProgressSpeedMulti = 100
        })
      end
      OnDownloadCompleteAfter()
    end
    
    if vResourceABSpecified then
      DownloadManager:DownloadResource(nil, nil, "LoginAll", OnDownloadStart, OnDownloadProgress, OnDownloadComplete, 0, eNetworkStatus, vResourceABSpecified)
    else
      DownloadManager:DownloadResource(vPackage, vExtraResource, "LoginAll", OnDownloadStart, OnDownloadProgress, OnDownloadComplete, 0, eNetworkStatus)
    end
  end
  
  if iDownloadBigSize >= lTotalBytesAll - lDownloadedBytesAll then
    OnConfirmDownloadAllResource(nil, nil, lTotalBytesAll, lDownloadedBytesAll, DownloadManager.NetworkStatus.Mobile, vFilePathShouldDownload)
    return
  end
  local lSpaceNeed = lTotalBytesAll - lDownloadedBytesAll
  local lSpaceFree = CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024
  if lSpaceNeed > lSpaceFree then
    if isForceDownload then
      ReportManager:ReportLoginProcess("DownloadAllResource", sNewbiePrefix .. "ABTest2_NotEnoughSpace_SkipDownload")
    else
      ReportManager:ReportLoginProcess("DownloadAllResource", sNewbiePrefix .. "ABTest3_NotEnoughSpace_SkipDownload")
    end
    OnDownloadCompleteAfter()
    return
  end
  ReportManager:ReportLoginProcess("DownloadAllResource", sNewbiePrefix .. "ShowConfirmTips")
  StackFlow:Push(UIDefines.ID_FORM_LOGINDOWNLOADTIPS, {
    isNewbie = bNewbie,
    isNecessary = false,
    isForceDownload = isForceDownload,
    callback = function(bDownloadNow, bAutoConfirm, stDownloadInfo, iSelectFlag)
      if bDownloadNow then
        local suffix = bAutoConfirm and "_Auto" or "_Manual"
        if isForceDownload then
          ReportManager:ReportLoginProcess("DownloadAllResource", sNewbiePrefix .. "ABTest2" .. suffix)
        else
          ReportManager:ReportLoginProcess("DownloadAllResource", sNewbiePrefix .. "ABTest3_All" .. suffix)
        end
        local eNetworkStatus
        if CS.DeviceUtil.IsWIFIConnected() then
          eNetworkStatus = DownloadManager.NetworkStatus.Wifi
        else
          eNetworkStatus = DownloadManager.NetworkStatus.Mobile
        end
        OnConfirmDownloadAllResource(nil, nil, stDownloadInfo.lSizeTotal, stDownloadInfo.lSizeDownloaded, eNetworkStatus, stDownloadInfo.vResourceAB)
      else
        ReportManager:ReportLoginProcess("DownloadAllResource", sNewbiePrefix .. "ABTest3_SkipDownload")
        OnDownloadCompleteAfter()
      end
    end
  })
end

function Job_Startup_DownloadAllResource_Impl.OnDownloadAllResourceSuccess(jobNode)
end

function Job_Startup_DownloadAllResource_Impl.OnDownloadAllResourceFailed(jobNode)
end

function Job_Startup_DownloadAllResource_Impl.OnDownloadAllResourceTimeOut(jobNode)
end

function Job_Startup_DownloadAllResource_Impl.OnDownloadAllResourceDispose(jobNode)
end

return Job_Startup_DownloadAllResource_Impl
