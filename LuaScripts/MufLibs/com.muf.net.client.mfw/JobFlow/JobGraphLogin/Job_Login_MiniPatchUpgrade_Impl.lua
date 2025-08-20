local Job_Login_MiniPatchUpgrade_Impl = {}
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function Job_Login_MiniPatchUpgrade_Impl.TryShowRestart()
  utils.CheckAndPushCommonTips({
    title = CS.ConfFact.LangFormat4DataInit("UpdateComplete"),
    content = CS.ConfFact.LangFormat4DataInit("UpdateRestartConfirm"),
    funcText1 = CS.ConfFact.LangFormat4DataInit("PlayerCancelInfoYes"),
    btnNum = 1,
    bLockBack = true,
    func1 = function()
      CS.ApplicationManager.Instance:RestartGame()
    end
  })
end

function Job_Login_MiniPatchUpgrade_Impl.RealMiniPatchUpgrade(jobNode)
  local function OnDownloadCompleteAfter()
    ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "Success")
    
    jobNode.Status = JobStatus.Success
  end
  
  if ChannelManager:IsWindows() then
    log.info("Windows MiniPatch Not Open")
    ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "Windows_NotOpen")
    OnDownloadCompleteAfter()
    return
  end
  local isOpen = CS.TGRPDownloaderMiniPatch.IsMiniPatchOpen
  local cur_mini_patch_version = DownloadManager:GetMiniPatchVersion()
  local mini_patch_version_number = 0
  if cur_mini_patch_version then
    mini_patch_version_number = tonumber(cur_mini_patch_version)
  end
  local iOldMiniPatchVersion = CS.TGRPDownloaderMiniPatch.Instance:GetCurrentMiniPatchVersion()
  local bClearMiniPatchRes = false
  if isOpen and mini_patch_version_number ~= nil then
    bClearMiniPatchRes = mini_patch_version_number < iOldMiniPatchVersion
  else
    bClearMiniPatchRes = 0 < iOldMiniPatchVersion
  end
  if bClearMiniPatchRes then
    log.info("Job_Login_MiniPatchUpgrade_Impl ClearMiniPatchRes")
    CS.TGRPDownloaderMiniPatch.Instance:ClearMiniPatchRes()
  end
  log.info("MiniPatch is open" .. tostring(isOpen))
  if isOpen == false then
    log.info("MiniPatch is disable, skip MiniPatchUpgrade")
    if bClearMiniPatchRes then
      ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "NotOpen_BackRestart")
      Job_Login_MiniPatchUpgrade_Impl.TryShowRestart()
    else
      ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "NotOpen")
      OnDownloadCompleteAfter()
    end
    return
  end
  if mini_patch_version_number == nil or mini_patch_version_number <= 0 then
    log.info("MiniPatch version number <= 0, skip MiniPatchUpgrade")
    if bClearMiniPatchRes then
      ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "VersionError_BackRestart")
      Job_Login_MiniPatchUpgrade_Impl.TryShowRestart()
    else
      ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "VersionError")
      OnDownloadCompleteAfter()
    end
    return
  end
  local util = require("common/XLua/util")
  CS.MonoMethodUtil.StartCoroutine(util.cs_generator(function()
    ReportManager:ReportLoginProcess("MiniPatchUpgrade", "InitDownloader" .. mini_patch_version_number .. "_Start")
    coroutine.yield(CS.TGRPDownloaderMiniPatch.Instance:InitMiniPatchDownloader(cur_mini_patch_version))
    ReportManager:ReportLoginProcess("MiniPatchUpgrade", "InitDownloader" .. mini_patch_version_number .. "_Success")
    local lUnDownloadedSize = CS.TGRPDownloaderMiniPatch.Instance.UnDownloadedMiniPatchSize
    if lUnDownloadedSize <= 0 then
      if bClearMiniPatchRes then
        ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "NoNeedDownload_BackRestart")
        Job_Login_MiniPatchUpgrade_Impl.TryShowRestart()
      else
        ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "NoNeedDownload")
        OnDownloadCompleteAfter()
      end
      return
    end
    local bBackground = DownloadManager:IsMiniPatchBackground()
    local bShowConfirm = not bBackground
    local lCurBytes = 0
    local lTotalBytes = 0
    
    local function OnDownloadStart(curBytes, totalBytes)
      lCurBytes = curBytes
      lTotalBytes = totalBytes
      local sProgress = DownloadManager:GetDownloadProgressStr(curBytes, totalBytes)
      log.info("Download MiniPatch Progress: " .. sProgress)
      EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
      if bShowConfirm then
        CS.TGRPDownloaderMiniPatch.Instance:PauseDownload()
        ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "ShowConfirmTips")
        utils.CheckAndPushCommonTips({
          title = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTitle"),
          content = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTipsForce"),
          fContentCB = function(sContent)
            local sContentNew = string.customizereplace(sContent, {"{size}"}, DownloadManager:GetDownloadSizeStr(lTotalBytes - lCurBytes))
            return sContentNew
          end,
          funcText1 = CS.ConfFact.LangFormat4DataInit("CommonDownload"),
          btnNum = 1,
          bLockBack = true,
          func1 = function()
            ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "DownloadStart")
            bShowConfirm = false
            CS.TGRPDownloaderMiniPatch.Instance:StartDownload()
          end
        })
      end
    end
    
    local function OnDownloadProgress(curBytes, totalBytes, speed)
      lCurBytes = curBytes
      lTotalBytes = totalBytes
      jobNode.UnitProgress = curBytes / totalBytes
      local sProgress = DownloadManager:GetDownloadProgressStr(curBytes, totalBytes)
      log.info("Download MiniPatch Progress: " .. sProgress)
      EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
    end
    
    local function OnDownloadComplete(bRet, iRetCode)
      log.info("Download MiniPatch Complete: " .. tostring(bRet))
      if bRet then
        CS.TGRPDownloaderMiniPatch.Instance:CheckVersion(cur_mini_patch_version)
        local bNeedRestart = DownloadManager:IsMiniPatchNeedRestart()
        if bBackground then
          ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "DownloadSuccess_Background")
          CS.TGRPDownloaderMiniPatch.Instance:Reload()
        elseif bNeedRestart then
          ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "DownloadSuccess_Restart")
          Job_Login_MiniPatchUpgrade_Impl.TryShowRestart()
          return
        elseif bClearMiniPatchRes then
          ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "DownloadSuccess_NotRestart_BackRestart")
          Job_Login_MiniPatchUpgrade_Impl.TryShowRestart()
          return
        else
          ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "DownloadSuccess_NotRestart")
          CS.TGRPDownloaderMiniPatch.Instance:Reload()
        end
      else
        ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "DownloadFail_" .. tostring(iRetCode))
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
      EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = false})
      jobNode.UnitProgress = 1
      EventCenter.Broadcast(EventDefine.eGameEvent_Login_SetProgressClamp, {
        jobFlow = require("JobFlow/JobGraphStartup/JobGraphStartup").Instance(),
        fMin = 0,
        fMax = 1
      })
      OnDownloadCompleteAfter()
    end
    
    ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "Download" .. cur_mini_patch_version .. (bBackground and "_Background" or "_Foreground"))
    if bBackground then
      CS.TGRPDownloaderMiniPatch.Instance:StartMiniPatchDownload(OnDownloadComplete, OnDownloadStart, OnDownloadProgress)
      if bClearMiniPatchRes then
        ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "Download" .. cur_mini_patch_version .. (bBackground and "_Background" or "_Foreground") .. "_BackRestart")
        Job_Login_MiniPatchUpgrade_Impl.TryShowRestart()
        return
      else
        OnDownloadCompleteAfter()
      end
    else
      jobNode.UnitProgress = 1
      local fJobProgressMax = jobNode.Graph:GetJobProgress()
      jobNode.UnitProgress = 0
      local fJobProgressMin = jobNode.Graph:GetJobProgress()
      EventCenter.Broadcast(EventDefine.eGameEvent_Login_SetProgressClamp, {
        jobFlow = jobNode.Graph,
        fMin = fJobProgressMin,
        fMax = fJobProgressMax,
        jobProgressSpeedMulti = 1
      })
      CS.TGRPDownloaderMiniPatch.Instance:StartMiniPatchDownload(OnDownloadComplete, OnDownloadStart, OnDownloadProgress)
    end
  end))
end

function Job_Login_MiniPatchUpgrade_Impl.OnMiniPatchUpgrade(jobNode)
  ReportManager:ReportLoginProcess("InitNetwork_Login_MiniPatchUpgrade", "Start")
  Job_Login_MiniPatchUpgrade_Impl.RealMiniPatchUpgrade(jobNode)
end

function Job_Login_MiniPatchUpgrade_Impl.OnMiniPatchUpgradeSuccess(jobNode)
end

function Job_Login_MiniPatchUpgrade_Impl.OnMiniPatchUpgradeFailed(jobNode)
end

function Job_Login_MiniPatchUpgrade_Impl.OnMiniPatchUpgradeTimeOut(jobNode)
end

function Job_Login_MiniPatchUpgrade_Impl.OnMiniPatchUpgradeDispose(jobNode)
end

return Job_Login_MiniPatchUpgrade_Impl
