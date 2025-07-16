local Job_Startup_DownloadNecessaryResource_Impl = {}
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function Job_Startup_DownloadNecessaryResource_Impl.RefreshMultiLan(jobNode)
  log.info("Job_Startup_DownloadNecessaryResource_Impl.RefreshMultiLan")
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
    jobNode.Status = JobStatus.Success
  end)
end

function Job_Startup_DownloadNecessaryResource_Impl.OnDownloadNecessaryResource(jobNode)
  ReportManager:ReportLoginProcess("DownloadNecessaryResource", "Start")
  DownloadManager:SetThrottleNetSpeed(0)
  local vExtraResourceMultiLan = {}
  local stLanguageElment = CData_MultiLanguage:GetValue_ByID(CS.MultiLanguageManager.g_iLanguageID)
  vExtraResourceMultiLan[#vExtraResourceMultiLan + 1] = {
    sName = "AllLanguage" .. stLanguageElment.m_LanguageObject,
    eType = DownloadManager.ResourceType.Language
  }
  vExtraResourceMultiLan[#vExtraResourceMultiLan + 1] = {
    sName = "AddLanguage" .. stLanguageElment.m_LanguageObject,
    eType = DownloadManager.ResourceType.Language
  }
  vExtraResourceMultiLan[#vExtraResourceMultiLan + 1] = {
    sName = "LanResObj_" .. stLanguageElment.m_Translation .. "_add",
    eType = DownloadManager.ResourceType.LanResObj
  }
  local vResourceABMultiLan = DownloadManager:GetResourceABList(nil, vExtraResourceMultiLan)
  local lSizeTotalMultiLan = DownloadManager:GetResourceABListTotalBytes(vResourceABMultiLan)
  local lSizeDownloadedMultiLan = DownloadManager:GetResourceABListDownloadedBytes(vResourceABMultiLan)
  local bDownloadMultiLan = 0 < lSizeTotalMultiLan - lSizeDownloadedMultiLan
  
  local function OnDownloadCompleteAfter()
    ReportManager:ReportLoginProcess("DownloadNecessaryResource", "Success")
    if bDownloadMultiLan then
      Job_Startup_DownloadNecessaryResource_Impl.RefreshMultiLan(jobNode)
    else
      jobNode.Status = JobStatus.Success
    end
  end
  
  local iNewbieMainLevelID = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("NewbieMainLevelID").m_Value)
  local bNewbie = not LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, iNewbieMainLevelID)
  local sNewbiePrefix = bNewbie and "Newbie_" or "Baisc_"
  local iDownloadBigSize = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("LoginMinResourceLimit").m_Value) * 1024 * 1024
  
  local function OnConfirmDownloadResource(vPackage, vExtraResource, lSizeTotal, lSizeDownloaded, eNetworkStatus, vResourceABSpecified)
    local bDownloadBig = lSizeTotal - lSizeDownloaded > iDownloadBigSize
    ReportManager:ReportLoginProcess("DownloadNecessaryResource", sNewbiePrefix .. "Download_" .. (bDownloadBig and "Big" or "Small"))
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
      log.info(sNewbiePrefix .. "DownloadNecessary Progress: " .. sProgress)
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
      log.info(sNewbiePrefix .. "DownloadNecessary Progress: " .. sProgress)
      if bDownloadBig then
        stDownloadInfo.lCurBytes = curBytes
        stDownloadInfo.lTotalBytes = totalBytes
        EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgressBig, stDownloadInfo)
      else
        EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
      end
    end
    
    local function OnDownloadComplete(ret)
      log.info(sNewbiePrefix .. "DownloadNecessary Complete: " .. tostring(ret))
      if not ret then
        ReportManager:ReportLoginProcess("DownloadNecessaryResource", sNewbiePrefix .. "Download_" .. (bDownloadBig and "Big" or "Small") .. "_Fail")
        jobNode.Status = JobStatus.Failed
        log.error(sNewbiePrefix .. "TGRP DownloadNecessary Failed")
        utils.CheckAndPushCommonTips({
          title = CS.ConfFact.LangFormat4DataInit("CommonError"),
          content = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceFail"),
          funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
          btnNum = 1,
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
      DownloadManager:DownloadResource(nil, nil, "Login" .. (bNewbie and "Newbie" or "Baisc"), OnDownloadStart, OnDownloadProgress, OnDownloadComplete, 0, eNetworkStatus, vResourceABSpecified)
    else
      DownloadManager:DownloadResource(vPackage, vExtraResource, "Login" .. (bNewbie and "Newbie" or "Baisc"), OnDownloadStart, OnDownloadProgress, OnDownloadComplete, 0, eNetworkStatus)
    end
  end
  
  local vPackageAll = {}
  local vExtraResourceAll = {}
  local sPackages = ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("CoreResourcePack").m_Value
  local vCorePackages = string.split(sPackages, "/")
  for k, v in ipairs(vCorePackages) do
    vPackageAll[#vPackageAll + 1] = {
      sName = v,
      eType = DownloadManager.ResourcePackageType.Custom
    }
  end
  local levelMainHelper = LevelManager:GetLevelMainHelper()
  local chapterCfg = levelMainHelper:GetCurrentLevelCfg(LevelManager.MainLevelSubType.MainStory)
  if chapterCfg and chapterCfg.m_ChapterID <= 9 then
    for i = chapterCfg.m_ChapterID, 9 do
      if i == 1 then
        vPackageAll[#vPackageAll + 1] = {
          sName = "Pack_0-3",
          eType = DownloadManager.ResourcePackageType.Custom
        }
      else
        local sChapterName = string.format("Pack_MainLevel_%d", chapterCfg.m_ChapterID - 1)
        vPackageAll[#vPackageAll + 1] = {
          sName = sChapterName,
          eType = DownloadManager.ResourcePackageType.Custom
        }
      end
    end
  end
  sPackages = ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("ExpansionResourcePack").m_Value
  local vExpansionPackages = string.split(sPackages, "/")
  for k, v in ipairs(vExpansionPackages) do
    vPackageAll[#vPackageAll + 1] = {
      sName = v,
      eType = DownloadManager.ResourcePackageType.Custom
    }
  end
  if bNewbie then
    vPackageAll[#vPackageAll + 1] = {
      sName = "Pack_Prologue",
      eType = DownloadManager.ResourcePackageType.Custom
    }
  end
  for _, stExtraResource in pairs(vExtraResourceMultiLan) do
    vExtraResourceAll[#vExtraResourceAll + 1] = stExtraResource
  end
  local vResourceABAll = DownloadManager:GetResourceABList(vPackageAll, vExtraResourceAll)
  local lSizeTotalAll = DownloadManager:GetResourceABListTotalBytes(vResourceABAll)
  local lSizeDownloadedAll = DownloadManager:GetResourceABListDownloadedBytes(vResourceABAll)
  local vPackage = {}
  local vExtraResource = {}
  local vResourceAB = {}
  local lSizeTotal = 0
  local lSizeDownloaded = 0
  local isForceDownload = RoleManager:GetABTestDownloadAllResourceNewbie() == 2
  if isForceDownload then
    vPackage = vPackageAll
    vExtraResource = vExtraResourceAll
    vResourceAB = vResourceABAll
    lSizeTotal = lSizeTotalAll
    lSizeDownloaded = lSizeDownloadedAll
  else
    if bNewbie then
      vPackage[#vPackage + 1] = {
        sName = "Pack_Prologue",
        eType = DownloadManager.ResourcePackageType.Custom
      }
    else
      vPackage[#vPackage + 1] = {
        sName = "Pack_Hall",
        eType = DownloadManager.ResourcePackageType.Custom
      }
    end
    for _, stExtraResource in pairs(vExtraResourceMultiLan) do
      vExtraResource[#vExtraResource + 1] = stExtraResource
    end
    vResourceAB = DownloadManager:GetResourceABList(vPackage, vExtraResource)
    lSizeTotal = DownloadManager:GetResourceABListTotalBytes(vResourceAB)
    lSizeDownloaded = DownloadManager:GetResourceABListDownloadedBytes(vResourceAB)
  end
  local lSizeLeft = lSizeTotal - lSizeDownloaded
  if lSizeLeft <= 0 then
    ReportManager:ReportLoginProcess("DownloadNecessaryResource", sNewbiePrefix .. "NoNeedDownload")
    OnDownloadCompleteAfter()
    return
  end
  local lSpaceNeed = lSizeTotal - lSizeDownloaded
  local lSpaceFree = CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024
  log.info(string.format("Download Necessary Resource: Space Need %.02fMB, Free %.02fMB", lSpaceNeed / 1024 / 1024, lSpaceFree / 1024 / 1024))
  if lSpaceNeed > lSpaceFree then
    ReportManager:ReportLoginProcess("DownloadNecessaryResource", "NotEnoughSpace")
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LowStorageWarning"),
      fContentCB = function(sContent)
        local sContentNew = string.customizereplace(sContent, {"{size1}"}, DownloadManager:GetDownloadSizeStr(lSpaceFree))
        sContentNew = string.customizereplace(sContentNew, {"{size2}"}, DownloadManager:GetDownloadSizeStr(lSpaceNeed))
        return sContentNew
      end,
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:ExitGame()
      end
    })
    jobNode.Status = JobStatus.Failed
    return
  end
  if iDownloadBigSize < lSizeLeft then
    ReportManager:ReportLoginProcess("DownloadNecessaryResource", sNewbiePrefix .. "ShowConfirmTips")
    if lSpaceFree >= lSizeTotalAll - lSizeDownloadedAll then
      StackFlow:Push(UIDefines.ID_FORM_LOGINDOWNLOADTIPS, {
        isNewbie = bNewbie,
        isNecessary = true,
        isForceDownload = isForceDownload,
        callback = function(bDownloadNow, bAutoConfirm, stDownloadInfo, iSelectFlag)
          local suffix = bAutoConfirm and "_Auto" or "_Manual"
          if isForceDownload then
            ReportManager:ReportLoginProcess("DownloadNecessaryResource", sNewbiePrefix .. "ABTest2" .. suffix)
          elseif iSelectFlag == 1 then
            ReportManager:ReportLoginProcess("DownloadNecessaryResource", sNewbiePrefix .. "ABTest3_Necessary" .. suffix)
          else
            ReportManager:ReportLoginProcess("DownloadNecessaryResource", sNewbiePrefix .. "ABTest3_All" .. suffix)
          end
          local eNetworkStatus
          if CS.DeviceUtil.IsWIFIConnected() then
            eNetworkStatus = DownloadManager.NetworkStatus.Wifi
          else
            eNetworkStatus = DownloadManager.NetworkStatus.Mobile
          end
          OnConfirmDownloadResource(nil, nil, stDownloadInfo.lSizeTotal, stDownloadInfo.lSizeDownloaded, eNetworkStatus, stDownloadInfo.vResourceAB)
        end
      })
    else
      local vFileInfoShouldDownload = DownloadManager:GetFileInfoListShouldDownload()
      local vFilePathShouldDownload = {}
      local iCountShouldDownload = 0
      for i = 0, vFileInfoShouldDownload.Count - 1 do
        local sFilePath = vFileInfoShouldDownload[i]:GetResPath()
        iCountShouldDownload = iCountShouldDownload + 1
        vFilePathShouldDownload[iCountShouldDownload] = sFilePath
      end
      local lTotalBytesAll = DownloadManager:GetResourceABListTotalBytes(vFilePathShouldDownload)
      local lDownloadedBytesAll = DownloadManager:GetResourceABListDownloadedBytes(vFilePathShouldDownload)
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTitle"),
        content = bNewbie and CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceNewbieDesc") or CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceBasicDesc"),
        bUpdateContent = true,
        contentAlign = CS.TMPro.TextAlignmentOptions.Left,
        fContentCB = function(sContent)
          local sContentNew = string.customizereplace(sContent, {"{size}"}, DownloadManager:GetDownloadSizeStr(lSizeLeft))
          sContentNew = string.customizereplace(sContentNew, {"{size_all}"}, DownloadManager:GetDownloadSizeStr(lTotalBytesAll - lDownloadedBytesAll - lSizeLeft))
          if not CS.DeviceUtil.IsWIFIConnected() then
            sContentNew = sContentNew .. "\n" .. CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceMobilePrompt")
          end
          return sContentNew
        end,
        fAutoConfirmDelay = 10,
        fRefreshAutoConfirmCB = function()
          return CS.DeviceUtil.IsWIFIConnected()
        end,
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
        btnNum = 3,
        bLockBack = true,
        func1 = function(bAutoConfirm)
          ReportManager:ReportLoginProcess("DownloadNecessaryResource", sNewbiePrefix .. "ABTest3_SpaceNotEnough_" .. (bAutoConfirm and "Auto" or "Manual"))
          LocalDataManager:SetIntSimple("LoginDownloadTipsSelect", 1)
          local eNetworkStatus
          if CS.DeviceUtil.IsWIFIConnected() then
            eNetworkStatus = DownloadManager.NetworkStatus.Wifi
          else
            eNetworkStatus = DownloadManager.NetworkStatus.Mobile
          end
          OnConfirmDownloadResource(vPackage, vExtraResource, lSizeTotal, lSizeDownloaded, eNetworkStatus)
        end
      })
    end
  else
    OnConfirmDownloadResource(vPackage, vExtraResource, lSizeTotal, lSizeDownloaded, DownloadManager.NetworkStatus.Mobile)
  end
end

function Job_Startup_DownloadNecessaryResource_Impl.OnDownloadNecessaryResourceSuccess(jobNode)
end

function Job_Startup_DownloadNecessaryResource_Impl.OnDownloadNecessaryResourceFailed(jobNode)
end

function Job_Startup_DownloadNecessaryResource_Impl.OnDownloadNecessaryResourceTimeOut(jobNode)
end

function Job_Startup_DownloadNecessaryResource_Impl.OnDownloadNecessaryResourceDispose(jobNode)
end

return Job_Startup_DownloadNecessaryResource_Impl
