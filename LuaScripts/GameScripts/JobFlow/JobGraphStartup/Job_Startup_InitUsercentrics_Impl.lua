local Job_Startup_InitUsercentrics_Impl = {}

function Job_Startup_InitUsercentrics_Impl.OnInitUsercentrics(jobNode)
  if CS.UnityEngine.Application.isEditor then
    jobNode.Status = JobStatus.Success
    return
  end
  if not ChannelManager:IsEUChannel() or ChannelManager:IsWindows() then
    jobNode.Status = JobStatus.Success
    return
  end
  Job_Startup_InitUsercentrics_Impl.InitUsercentrics(jobNode)
end

function Job_Startup_InitUsercentrics_Impl.InitUsercentrics(jobNode)
  CS.UserCentricsCtrl.Instance:Initialize(function(bIsSuccess)
    jobNode.Status = JobStatus.Success
    if bIsSuccess then
    else
      log.error("UsercentricsCtrl  Initialize Failed")
    end
  end)
end

function Job_Startup_InitUsercentrics_Impl.OnInitUsercentricsSuccess(jobNode)
end

function Job_Startup_InitUsercentrics_Impl.OnInitUsercentricsFailed(jobNode)
end

function Job_Startup_InitUsercentrics_Impl.OnInitUsercentricsTimeOut(jobNode)
end

function Job_Startup_InitUsercentrics_Impl.OnInitUsercentricsDispose(jobNode)
end

return Job_Startup_InitUsercentrics_Impl
