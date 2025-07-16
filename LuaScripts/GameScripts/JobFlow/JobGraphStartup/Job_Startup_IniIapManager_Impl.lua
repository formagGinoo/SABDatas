local Job_Startup_IniIapManager_Impl = {}

function Job_Startup_IniIapManager_Impl.OnIniIapManager(jobNode)
  IAPManager:Initialize(function(isSuccess)
    log.info("IAPManager:Initialize isSuccess = " .. tostring(isSuccess))
  end)
  jobNode.Status = JobStatus.Success
end

function Job_Startup_IniIapManager_Impl.OnIniIapManagerSuccess(jobNode)
end

function Job_Startup_IniIapManager_Impl.OnIniIapManagerFailed(jobNode)
end

function Job_Startup_IniIapManager_Impl.OnIniIapManagerTimeOut(jobNode)
end

function Job_Startup_IniIapManager_Impl.OnIniIapManagerDispose(jobNode)
end

return Job_Startup_IniIapManager_Impl
