local Job_Startup_InitNetworkGame_Impl = {}

function Job_Startup_InitNetworkGame_Impl.OnInitNetworkGame(jobNode)
  local ConnectGameServerFlow = require("JobFlow/JobGraphConnectGameServer/JobGraphConnectGameServer")
  ConnectGameServerFlow.Instance():Run(function(node, before, after)
    jobNode.UnitProgress = ConnectGameServerFlow.Instance():GetJobProgress()
    if ConnectGameServerFlow.Instance():GetJobProgress() == 1 then
      ConnectGameServerFlow.Instance():Dispose()
      jobNode.Status = JobStatus.Success
    end
  end)
end

function Job_Startup_InitNetworkGame_Impl.OnInitNetworkGameSuccess(jobNode)
end

function Job_Startup_InitNetworkGame_Impl.OnInitNetworkGameFailed(jobNode)
end

function Job_Startup_InitNetworkGame_Impl.OnInitNetworkGameTimeOut(jobNode)
end

function Job_Startup_InitNetworkGame_Impl.OnInitNetworkGameDispose(jobNode)
end

return Job_Startup_InitNetworkGame_Impl
