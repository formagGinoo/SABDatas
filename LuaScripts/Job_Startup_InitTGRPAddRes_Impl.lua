local Job_Startup_InitTGRPAddRes_Impl = {}

function Job_Startup_InitTGRPAddRes_Impl.OnInitTGRPAddRes(jobNode)
  ReportManager:ReportLoginProcess("InitTGRPAddRes", "Start")
  local util = require("common/XLua/util")
  CS.MonoMethodUtil.StartCoroutine(util.cs_generator(function()
    ReportManager:ReportLoginProcess("InitTGRPAddRes", "InitDownloader_Start")
    coroutine.yield(CS.TGRPDownloader.InitAddResDownloader())
    ReportManager:ReportLoginProcess("InitTGRPAddRes", "InitDownloader_Success")
    CS.TGRPDownloader.RefreshDownloadedFileInfo()
    DownloadManager:InitDebugOptions()
    ReportManager:ReportLoginProcess("InitTGRPAddRes", "Success")
    jobNode.Status = JobStatus.Success
  end))
end

function Job_Startup_InitTGRPAddRes_Impl.OnInitTGRPAddResSuccess(jobNode)
end

function Job_Startup_InitTGRPAddRes_Impl.OnInitTGRPAddResFailed(jobNode)
end

function Job_Startup_InitTGRPAddRes_Impl.OnInitTGRPAddResTimeOut(jobNode)
end

function Job_Startup_InitTGRPAddRes_Impl.OnInitTGRPAddResDispose(jobNode)
end

return Job_Startup_InitTGRPAddRes_Impl
