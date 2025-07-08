local Job_Login_GetSelfIp_Impl = {}

function Job_Login_GetSelfIp_Impl.OnGetSelfIp(jobNode)
  jobNode.Status = JobStatus.Success
end

function Job_Login_GetSelfIp_Impl.OnGetSelfIpSuccess(jobNode)
end

function Job_Login_GetSelfIp_Impl.OnGetSelfIpFailed(jobNode)
end

function Job_Login_GetSelfIp_Impl.OnGetSelfIpTimeOut(jobNode)
end

function Job_Login_GetSelfIp_Impl.OnGetSelfIpDispose(jobNode)
end

return Job_Login_GetSelfIp_Impl
