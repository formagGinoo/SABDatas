local Job_Startup_CheckPreRes_Impl = {}

function Job_Startup_CheckPreRes_Impl.OnCheckPreRes(jobNode)
  jobNode.Status = JobStatus.Success
end

function Job_Startup_CheckPreRes_Impl.OnCheckPreResSuccess(jobNode)
end

function Job_Startup_CheckPreRes_Impl.OnCheckPreResFailed(jobNode)
end

function Job_Startup_CheckPreRes_Impl.OnCheckPreResTimeOut(jobNode)
end

function Job_Startup_CheckPreRes_Impl.OnCheckPreResDispose(jobNode)
end

return Job_Startup_CheckPreRes_Impl
