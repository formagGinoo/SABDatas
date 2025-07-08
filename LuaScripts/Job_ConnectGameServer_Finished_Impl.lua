local Job_ConnectGameServer_Finished_Impl = {}

function Job_ConnectGameServer_Finished_Impl.OnFinished(jobNode)
  ReportManager:ReportLoginProcess("InitNetworkGame_Finished", "")
  jobNode.Status = JobStatus.Success
end

function Job_ConnectGameServer_Finished_Impl.OnFinishedSuccess(jobNode)
end

function Job_ConnectGameServer_Finished_Impl.OnFinishedFailed(jobNode)
end

function Job_ConnectGameServer_Finished_Impl.OnFinishedTimeOut(jobNode)
end

function Job_ConnectGameServer_Finished_Impl.OnFinishedDispose(jobNode)
end

return Job_ConnectGameServer_Finished_Impl
