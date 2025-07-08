local Job_InitGSDK_Finished_Impl = {}

function Job_InitGSDK_Finished_Impl.OnFinished(jobNode)
  jobNode.Status = JobStatus.Success
end

function Job_InitGSDK_Finished_Impl.OnFinishedSuccess(jobNode)
end

function Job_InitGSDK_Finished_Impl.OnFinishedFailed(jobNode)
end

function Job_InitGSDK_Finished_Impl.OnFinishedTimeOut(jobNode)
end

function Job_InitGSDK_Finished_Impl.OnFinishedDispose(jobNode)
end

return Job_InitGSDK_Finished_Impl
