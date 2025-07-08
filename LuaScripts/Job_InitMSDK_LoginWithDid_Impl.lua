local Job_InitMSDK_LoginWithDid_Impl = {}

function Job_InitMSDK_LoginWithDid_Impl.OnLoginWithDid(jobNode)
  jobNode.Status = JobStatus.Success
end

function Job_InitMSDK_LoginWithDid_Impl.OnLoginWithDidSuccess(jobNode)
end

function Job_InitMSDK_LoginWithDid_Impl.OnLoginWithDidFailed(jobNode)
end

function Job_InitMSDK_LoginWithDid_Impl.OnLoginWithDidTimeOut(jobNode)
end

function Job_InitMSDK_LoginWithDid_Impl.OnLoginWithDidDispose(jobNode)
end

return Job_InitMSDK_LoginWithDid_Impl
