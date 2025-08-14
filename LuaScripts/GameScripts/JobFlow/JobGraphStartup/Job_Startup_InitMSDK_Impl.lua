local Job_Startup_InitMSDK_Impl = {}

function Job_Startup_InitMSDK_Impl.OnInitMSDK(jobNode)
  CS.LuaCallCS.AddLuaSearchPath("MufLibs/com.muf.net.client.mfw/", false)
  CS.LuaCallCS.AddLuaSearchPath("MufLibs/com.muf.net.client.mfw/sdplua/", false)
  if ChannelManager:IsUsingQSDK() or ChannelManager:IsDMMChannel() or ChannelManager:IsWegameChannel() then
    jobNode.Status = JobStatus.Success
  else
    local InitMSDKFlow = require("JobFlow/JobGraphInitMSDK/JobGraphInitMSDK")
    InitMSDKFlow.Instance():Run(function(node, before, after)
      jobNode.UnitProgress = InitMSDKFlow.Instance():GetJobProgress()
      if InitMSDKFlow.Instance():GetJobProgress() == 1 then
        InitMSDKFlow.Instance():Dispose()
        log.info("MSDK DID: " .. CS.MSDKManager.Instance:NativeGetDID())
        jobNode.Status = JobStatus.Success
      end
    end)
  end
end

function Job_Startup_InitMSDK_Impl.OnInitMSDKSuccess(jobNode)
end

function Job_Startup_InitMSDK_Impl.OnInitMSDKFailed(jobNode)
end

function Job_Startup_InitMSDK_Impl.OnInitMSDKTimeOut(jobNode)
end

function Job_Startup_InitMSDK_Impl.OnInitMSDKDispose(jobNode)
end

return Job_Startup_InitMSDK_Impl
