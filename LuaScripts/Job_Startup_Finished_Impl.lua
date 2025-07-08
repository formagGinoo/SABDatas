local Job_Startup_Finished_Impl = {}

function Job_Startup_Finished_Impl.OnFinished(jobNode)
  ReportManager:ReportLoginProcess("Finished", "")
  jobNode.Status = JobStatus.Success
end

function Job_Startup_Finished_Impl.OnFinishedSuccess(jobNode)
  local StartupFlow = require("JobFlow/JobGraphStartup/JobGraphStartup")
  StartupFlow.Instance():Dispose()
end

function Job_Startup_Finished_Impl.OnFinishedFailed(jobNode)
end

function Job_Startup_Finished_Impl.OnFinishedTimeOut(jobNode)
end

function Job_Startup_Finished_Impl.OnFinishedDispose(jobNode)
end

return Job_Startup_Finished_Impl
