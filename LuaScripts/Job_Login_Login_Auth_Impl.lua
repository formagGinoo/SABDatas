local Job_Login_Login_Auth_Impl = {}

function Job_Login_Login_Auth_Impl.OnLogin_Auth(jobNode)
  jobNode.Status = JobStatus.Success
end

function Job_Login_Login_Auth_Impl.OnLogin_AuthSuccess(jobNode)
end

function Job_Login_Login_Auth_Impl.OnLogin_AuthFailed(jobNode)
end

function Job_Login_Login_Auth_Impl.OnLogin_AuthTimeOut(jobNode)
end

function Job_Login_Login_Auth_Impl.OnLogin_AuthDispose(jobNode)
end

return Job_Login_Login_Auth_Impl
