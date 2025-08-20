local Job_Startup_DownloadStateScript_Impl = {}

function Job_Startup_DownloadStateScript_Impl.InitTGRPDownload(jobNode, iStateScriptVersion)
  local util = require("common/XLua/util")
  CS.MonoMethodUtil.StartCoroutine(util.cs_generator(function()
    ReportManager:ReportLoginProcess("DownloadStateScript", "InitDownloader" .. iStateScriptVersion .. "_Start")
    coroutine.yield(CS.TGRPDownloaderStateScript.Instance:InitDownloader(iStateScriptVersion))
    ReportManager:ReportLoginProcess("DownloadStateScript", "InitDownloader" .. iStateScriptVersion .. "_Success")
    Job_Startup_DownloadStateScript_Impl.TryCheckResListCorrect(jobNode, iStateScriptVersion)
  end))
end

function Job_Startup_DownloadStateScript_Impl.TryCheckResListCorrect(jobNode, iStateScriptVersion)
  ReportManager:ReportLoginProcess("DownloadStateScript", "CheckResListCorrect_Start")
  
  local function OnCheckResListCorrent(iIncorrentCount)
    ReportManager:ReportLoginProcess("DownloadStateScript", "CheckResListCorrect_Success")
    Job_Startup_DownloadStateScript_Impl.TryDownloadStateScript(jobNode, iStateScriptVersion)
  end
  
  local iStateScriptVersionPre = CS.TGRPDownloaderStateScript.Instance.PreviousStateScriptVersion
  log.info("DownloadStateScript iStateScriptVersionPre: " .. iStateScriptVersionPre)
  if iStateScriptVersion == iStateScriptVersionPre then
    OnCheckResListCorrent(0)
    return
  end
  CS.TGRPDownloaderStateScript.Instance:CheckResListCorrect(OnCheckResListCorrent)
end

function Job_Startup_DownloadStateScript_Impl.TryDownloadStateScript(jobNode, iStateScriptVersion)
  local function OnDownloadCompleteAfter()
    CS.TGRPDownloaderStateScript.Instance:LoadFileInfoList()
    
    CS.TGRPDownloaderStateScript.Instance:SaveStateScriptVersion(iStateScriptVersion)
    jobNode.Status = JobStatus.Success
  end
  
  local lUnDownloadedSize = CS.TGRPDownloaderStateScript.Instance.UnDownloadedSize
  if lUnDownloadedSize <= 0 then
    ReportManager:ReportLoginProcess("DownloadStateScript", "NoNeedDownload")
    OnDownloadCompleteAfter()
    return
  end
  local lCurBytes = 0
  local lTotalBytes = 0
  
  local function OnDownloadStart(curBytes, totalBytes)
    lCurBytes = curBytes
    lTotalBytes = totalBytes
    local sProgress = DownloadManager:GetDownloadProgressStr(curBytes, totalBytes)
    log.info("Download StateScript Start: " .. sProgress)
  end
  
  local function OnDownloadProgress(curBytes, totalBytes, speed)
    lCurBytes = curBytes
    lTotalBytes = totalBytes
    jobNode.UnitProgress = curBytes / totalBytes
    local sProgress = DownloadManager:GetDownloadProgressStr(curBytes, totalBytes)
    log.info("Download StateScript Progress: " .. sProgress)
  end
  
  local function OnDownloadComplete(bRet, iRetCode)
    log.info("Download StateScript Complete: " .. tostring(bRet))
    if bRet then
      ReportManager:ReportLoginProcess("DownloadStateScript", "DownloadSuccess")
      OnDownloadCompleteAfter()
      return
    else
      ReportManager:ReportLoginProcess("DownloadStateScript", "DownloadFail_" .. tostring(iRetCode))
      local sErrorTips = ""
      if iRetCode == CS.Hades.HadesDownloadErrorCode.kInsufficientSpace then
        sErrorTips = CS.ConfFact.LangFormat4DataInit("LowStorageWarning")
        local lSpaceNeed = lTotalBytes - lCurBytes
        local lSpaceFree = CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024
        sErrorTips = string.gsub(sErrorTips, "{size1}", DownloadManager:GetDownloadSizeStr(lSpaceFree))
        sErrorTips = string.gsub(sErrorTips, "{size2}", DownloadManager:GetDownloadSizeStr(lSpaceNeed))
      else
        sErrorTips = CS.ConfFact.LangFormat4DataInit("LoginMiniPatchUpgradeDownloadFail")
      end
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("CommonError"),
        content = sErrorTips,
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
        btnNum = 1,
        bLockBack = true,
        func1 = function()
          CS.ApplicationManager.Instance:RestartGame()
        end
      })
      jobNode.Status = JobStatus.Failed
      return
    end
  end
  
  ReportManager:ReportLoginProcess("DownloadStateScript", "DownloadStart")
  CS.TGRPDownloaderStateScript.Instance:DownloadResList(OnDownloadComplete, OnDownloadStart, OnDownloadProgress)
end

function Job_Startup_DownloadStateScript_Impl.OnDownloadStateScript(jobNode)
  if not CS.TGRPDownloaderStateScript.IsOpen then
    log.info("CDN StateScript is NOT open, skip DownloadStateScript")
    ReportManager:ReportLoginProcess("DownloadStateScript", "NotOpen")
    jobNode.Status = JobStatus.Success
    return
  end
  local iStateScriptVersion = DownloadManager:GetStateScriptVersion()
  Job_Startup_DownloadStateScript_Impl.InitTGRPDownload(jobNode, iStateScriptVersion)
end

function Job_Startup_DownloadStateScript_Impl.OnDownloadStateScriptSuccess(jobNode)
end

function Job_Startup_DownloadStateScript_Impl.OnDownloadStateScriptFailed(jobNode)
end

function Job_Startup_DownloadStateScript_Impl.OnDownloadStateScriptTimeOut(jobNode)
end

function Job_Startup_DownloadStateScript_Impl.OnDownloadStateScriptDispose(jobNode)
end

return Job_Startup_DownloadStateScript_Impl
