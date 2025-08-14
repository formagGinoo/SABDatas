local Job_InitMSDK_Finished_Impl = {}

function Job_InitMSDK_Finished_Impl.OnFinished(jobNode)
  CS.MSDKLogin.Instance:UpdateClientVersion()
  jobNode.Status = JobStatus.Success
end

function Job_InitMSDK_Finished_Impl.OnFinishedSuccess(jobNode)
end

function Job_InitMSDK_Finished_Impl.OnFinishedFailed(jobNode)
end

function Job_InitMSDK_Finished_Impl.OnFinishedTimeOut(jobNode)
end

function Job_InitMSDK_Finished_Impl.OnFinishedDispose(jobNode)
end

return Job_InitMSDK_Finished_Impl
