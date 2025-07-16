local Job_Startup_InitNetwork_Impl = {}
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")
local tempJobNode

local function onReLogin()
  RPCS():Init()
  local jobNode = tempJobNode
  local LoginFlow = require("JobFlow/JobGraphLogin/JobGraphLogin")
  LoginFlow.Instance():Run(function(node, before, after)
    jobNode.UnitProgress = LoginFlow.Instance():GetJobProgress()
    if LoginFlow.Instance():GetJobProgress() == 1 then
      LoginFlow.Instance():Dispose()
      jobNode.Status = JobStatus.Success
    end
  end)
end

function Job_Startup_InitNetwork_Impl.OnInitNetwork(jobNode)
  CS.GameQualityManager.Instance:ReportQualityEvent()
  EventCenter.AddListener(EventDefine.eGameEvent_Login_ReLogin, onReLogin)
  require("apis/RequireAllRpcs")
  log.info("---------------------------------------------------------- init rpcs ----------------------------------------------------------")
  RPCS():Init()
  tempJobNode = jobNode
  local LoginFlow = require("JobFlow/JobGraphLogin/JobGraphLogin")
  LoginFlow.Instance():Run(function(node, before, after)
    jobNode.UnitProgress = LoginFlow.Instance():GetJobProgress()
    if LoginFlow.Instance():GetJobProgress() == 1 then
      LoginFlow.Instance():Dispose()
      EventCenter.RemoveListener(EventDefine.eGameEvent_Login_ReLogin, onReLogin)
      jobNode.Status = JobStatus.Success
    end
  end)
end

function Job_Startup_InitNetwork_Impl.OnInitNetworkSuccess(jobNode)
end

function Job_Startup_InitNetwork_Impl.OnInitNetworkFailed(jobNode)
end

function Job_Startup_InitNetwork_Impl.OnInitNetworkTimeOut(jobNode)
end

function Job_Startup_InitNetwork_Impl.OnInitNetworkDispose(jobNode)
  EventCenter.RemoveListener(EventDefine.eGameEvent_Login_ReLogin, onReLogin)
end

return Job_Startup_InitNetwork_Impl
