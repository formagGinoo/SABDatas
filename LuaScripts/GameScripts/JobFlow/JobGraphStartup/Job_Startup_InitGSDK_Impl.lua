local Job_Startup_InitGSDK_Impl = {}

function Job_Startup_InitGSDK_Impl.OnInitGSDK(jobNode)
  if ChannelManager:IsUsingQSDK() or ChannelManager:IsDMMChannel() or ChannelManager:IsWegameChannel() then
    local InitGSDKFlow = require("JobFlow/JobGraphInitGSDK/JobGraphInitGSDK")
    InitGSDKFlow.Instance():Run(function(node, before, after)
      jobNode.UnitProgress = InitGSDKFlow.Instance():GetJobProgress()
      if InitGSDKFlow.Instance():GetJobProgress() == 1 then
        InitGSDKFlow.Instance():Dispose()
        jobNode.Status = JobStatus.Success
      end
    end)
  else
    jobNode.Status = JobStatus.Success
  end
end

function Job_Startup_InitGSDK_Impl.OnInitGSDKSuccess(jobNode)
end

function Job_Startup_InitGSDK_Impl.OnInitGSDKFailed(jobNode)
end

function Job_Startup_InitGSDK_Impl.OnInitGSDKTimeOut(jobNode)
end

function Job_Startup_InitGSDK_Impl.OnInitGSDKDispose(jobNode)
end

return Job_Startup_InitGSDK_Impl
