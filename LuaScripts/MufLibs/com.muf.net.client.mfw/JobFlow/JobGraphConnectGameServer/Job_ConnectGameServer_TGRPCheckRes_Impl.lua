local Job_ConnectGameServer_TGRPCheckRes_Impl = {}
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function Job_ConnectGameServer_TGRPCheckRes_Impl:TryTGRPCheckRes(jobNode)
  local versionContext = CS.VersionContext.GetContext()
  local sLocalResVer = CS.VersionUtil.GetResVer(versionContext.ClientLocalVersion)
  local sAddResPreResVer = LocalDataManager:GetStringSimple("DownloadAddResPre_Start", "")
  
  local function OnCheckResCompleteAfter()
    ReportManager:ReportLoginProcess("InitNetworkGame_Finished", "")
    jobNode.Status = JobStatus.Success
  end
  
  if sLocalResVer ~= sAddResPreResVer then
    OnCheckResCompleteAfter()
  else
    local vFileInfoPathAll = CS.TGRPDownloaderAddResPre.Instance:GetCheckResListOnHotUpdate()
    if vFileInfoPathAll.Count == 0 then
      log.info("Job_ConnectGameServer_TGRPCheckRes_Impl.TryTGRPCheckRes, No files to check.")
      OnCheckResCompleteAfter()
      return
    end
    
    local function OnCheckResStart()
      log.info("Job_ConnectGameServer_TGRPCheckRes_Impl.OnCheckResStart, File Count: " .. vFileInfoPathAll.Count)
      local sProgress = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(2014).m_mMessage .. " 0 / " .. vFileInfoPathAll.Count
      EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
    end
    
    local function OnCheckResProgress(iCurFiles, iTotalFiles)
      if iTotalFiles <= 0 then
        iTotalFiles = 1
      end
      jobNode.UnitProgress = iCurFiles / iTotalFiles
      local sProgress = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(2014).m_mMessage .. " " .. iCurFiles .. " / " .. iTotalFiles
      EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
    end
    
    local function OnCheckResComplete(iIncorrectCount)
      log.info("Job_ConnectGameServer_TGRPCheckRes_Impl.TryTGRPCheckRes: iIncorrectCount = " .. iIncorrectCount)
      LocalDataManager:SetStringSimple("DownloadAddResPre_Start", "", true)
      CS.TGRPDownloaderAddResPre.Instance:ClearAddResPreDir()
      EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = false})
      jobNode.UnitProgress = 1
      EventCenter.Broadcast(EventDefine.eGameEvent_Login_SetProgressClamp, {
        fMin = 0,
        fMax = 1,
        jobProgressSpeedMulti = 100
      })
      OnCheckResCompleteAfter()
    end
    
    CS.TGRPDownloader.CheckResListCorrect(vFileInfoPathAll, OnCheckResComplete, OnCheckResStart, OnCheckResProgress)
  end
end

function Job_ConnectGameServer_TGRPCheckRes_Impl.OnTGRPCheckRes(jobNode)
  Job_ConnectGameServer_TGRPCheckRes_Impl:TryTGRPCheckRes(jobNode)
end

function Job_ConnectGameServer_TGRPCheckRes_Impl.OnTGRPCheckResSuccess(jobNode)
end

function Job_ConnectGameServer_TGRPCheckRes_Impl.OnTGRPCheckResFailed(jobNode)
end

function Job_ConnectGameServer_TGRPCheckRes_Impl.OnTGRPCheckResTimeOut(jobNode)
end

function Job_ConnectGameServer_TGRPCheckRes_Impl.OnTGRPCheckResDispose(jobNode)
end

return Job_ConnectGameServer_TGRPCheckRes_Impl
