local Job_Startup_InitDownloadResource_Impl = {}

function Job_Startup_InitDownloadResource_Impl.OnInitDownloadResource(jobNode)
  if CS.VersionContext.GetContext():IsChinaChannel() then
    local reportClient = CS.com.muf.net.client.mfw.NetSession.Instance:AddClient(CS.com.muf.net.client.mfw.NetClientType.Report, "report")
    local reportIpList = CS.com.muf.net.client.mfw.IpContextUtil.GetReportIpList()
    reportClient:AddIpList(reportIpList)
    CS.ReportService.Instance:InitNetwork()
  end
  CS.MUF.Download.DownloadResource.Instance:InitDownload()
  CS.TGRPDownloader.InitService()
  if ChannelManager:IsWindows() then
    jobNode.Status = JobStatus.Success
    return
  end
  TimeService:SetTimer(1.0E-4, 1, function()
    jobNode.Status = JobStatus.Success
  end)
end

function Job_Startup_InitDownloadResource_Impl.OnInitDownloadResourceSuccess(jobNode)
end

function Job_Startup_InitDownloadResource_Impl.OnInitDownloadResourceFailed(jobNode)
end

function Job_Startup_InitDownloadResource_Impl.OnInitDownloadResourceTimeOut(jobNode)
end

function Job_Startup_InitDownloadResource_Impl.OnInitDownloadResourceDispose(jobNode)
end

return Job_Startup_InitDownloadResource_Impl
