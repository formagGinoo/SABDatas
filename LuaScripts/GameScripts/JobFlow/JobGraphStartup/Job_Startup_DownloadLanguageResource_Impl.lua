local Job_Startup_DownloadLanguageResource_Impl = {}
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function Job_Startup_DownloadLanguageResource_Impl.OnDownloadLanguageResource(jobNode)
  local function OnDownloadCompleteAfter(bDownloadMultiLanguage)
    ReportManager:ReportLoginProcess("DownloadLanguageResource", "Success")
    
    if bDownloadMultiLanguage then
      local lanResObj = CS.LanResObj()
      lanResObj:Init()
      CS.MultiLanguageManager.Instance:ReloadLanguageConfig()
      ConfigManager:InitFirstMustCfg(function(fUnitProgress)
      end, function()
        for id, csui in pairs(StackFlow.UIs) do
          if csui ~= nil then
            UIManager:RefreshMultiLanguage(csui.m_uiGameObject)
          end
        end
        for id, csui in pairs(StackPopup.UIs) do
          if csui ~= nil then
            UIManager:RefreshMultiLanguage(csui.m_uiGameObject)
          end
        end
        for id, csui in pairs(StackTop.UIs) do
          if csui ~= nil then
            UIManager:RefreshMultiLanguage(csui.m_uiGameObject)
          end
        end
        for id, csui in pairs(StackSpecial.UIs) do
          if csui ~= nil then
            UIManager:RefreshMultiLanguage(csui.m_uiGameObject)
          end
        end
        jobNode.Status = JobStatus.Success
      end)
    else
      jobNode.Status = JobStatus.Success
    end
  end
  
  local stLanguageElment = CData_MultiLanguage:GetValue_ByID(CS.MultiLanguageManager.g_iLanguageID)
  local vPackage = {}
  local vExtraResource = {
    {
      sName = "AllLanguage" .. stLanguageElment.m_LanguageObject,
      eType = DownloadManager.ResourceType.Language
    },
    {
      sName = "AddLanguage" .. stLanguageElment.m_LanguageObject,
      eType = DownloadManager.ResourceType.Language
    },
    {
      sName = "LanResObj_" .. stLanguageElment.m_Translation .. "_add",
      eType = DownloadManager.ResourceType.LanResObj
    }
  }
  local vResourceAB = DownloadManager:GetResourceABList(vPackage, vExtraResource)
  local lSizeTotal = DownloadManager:GetResourceABListTotalBytes(vResourceAB)
  local lSizeDownloaded = DownloadManager:GetResourceABListDownloadedBytes(vResourceAB)
  local lSizeLeft = lSizeTotal - lSizeDownloaded
  if lSizeLeft <= 0 then
    ReportManager:ReportLoginProcess("DownloadLanguageResource", "NoNeedDownload")
    OnDownloadCompleteAfter(false)
    return
  end
  ReportManager:ReportLoginProcess("DownloadLanguageResource", "Download")
  jobNode.UnitProgress = 1
  local fJobProgressMax = jobNode.Graph:GetJobProgress()
  jobNode.UnitProgress = 0
  local fJobProgressMin = jobNode.Graph:GetJobProgress()
  EventCenter.Broadcast(EventDefine.eGameEvent_Login_SetProgressClamp, {fMin = fJobProgressMin, fMax = fJobProgressMax})
  
  local function OnDownloadStart(curBytes, totalBytes)
    curBytes = math.max(curBytes - lSizeDownloaded, 0)
    totalBytes = math.max(totalBytes - lSizeDownloaded, 1)
    local sProgress = DownloadManager:GetDownloadProgressStr(curBytes, totalBytes)
    log.info("DownloadLanguageResource Progress: " .. sProgress)
    EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
  end
  
  local function OnDownloadProgress(curBytes, totalBytes, speed)
    curBytes = math.max(curBytes - lSizeDownloaded, 0)
    totalBytes = math.max(totalBytes - lSizeDownloaded, 1)
    jobNode.UnitProgress = curBytes / totalBytes
    local sProgress = DownloadManager:GetDownloadProgressStr(curBytes, totalBytes)
    log.info("DownloadLanguageResource Progress: " .. sProgress)
    EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
  end
  
  local function OnDownloadComplete(ret)
    log.info("DownloadLanguageResource Complete: " .. tostring(ret))
    if not ret then
      ReportManager:ReportLoginProcess("DownloadLanguageResource", "DownloadFail")
      jobNode.Status = JobStatus.Failed
      log.error("TGRP DownloadLanguageResource Failed")
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("CommonError"),
        content = CS.ConfFact.LangFormat4DataInit("LoginMiniPatchUpgradeDownloadFail"),
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
        btnNum = 1,
        bLockBack = true,
        func1 = function()
          CS.ApplicationManager.Instance:RestartGame()
        end
      })
      return
    end
    EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = false})
    jobNode.UnitProgress = 1
    EventCenter.Broadcast(EventDefine.eGameEvent_Login_SetProgressClamp, {
      fMin = jobNode.Graph:GetJobProgress(),
      fMax = 1,
      jobProgressSpeedMulti = 100
    })
    OnDownloadCompleteAfter(true)
  end
  
  DownloadManager:DownloadResource(vPackage, vExtraResource, "LoginLanguage", OnDownloadStart, OnDownloadProgress, OnDownloadComplete, 0, DownloadManager.NetworkStatus.Mobile)
end

function Job_Startup_DownloadLanguageResource_Impl.OnDownloadLanguageResourceSuccess(jobNode)
end

function Job_Startup_DownloadLanguageResource_Impl.OnDownloadLanguageResourceFailed(jobNode)
end

function Job_Startup_DownloadLanguageResource_Impl.OnDownloadLanguageResourceTimeOut(jobNode)
end

function Job_Startup_DownloadLanguageResource_Impl.OnDownloadLanguageResourceDispose(jobNode)
end

return Job_Startup_DownloadLanguageResource_Impl
