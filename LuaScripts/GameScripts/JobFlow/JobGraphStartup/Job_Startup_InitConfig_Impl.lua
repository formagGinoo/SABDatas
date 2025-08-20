local Job_Startup_InitConfig_Impl = {}
local ConfigManager = _ENV.ConfigManager

function Job_Startup_InitConfig_Impl.OnInitConfig(jobNode)
  ReportManager:ReportLoginProcess("InitConfig", "Start")
  ConfigManager:InitConfig(function(fUnitProgress)
    jobNode.UnitProgress = fUnitProgress
  end, function()
    CineVoiceInBattleManager:InitTableData()
    CS.BattleMD5:ReloadMD5()
    TimeService:SetTimer(0.001, 1, function()
      ReportManager:ReportLoginProcess("InitConfig", "Success")
      jobNode.Status = JobStatus.Success
    end)
  end)
end

function Job_Startup_InitConfig_Impl.OnInitConfigSuccess(jobNode)
  GameManager:OnAfterInitConfig()
end

function Job_Startup_InitConfig_Impl.OnInitConfigFailed(jobNode)
end

function Job_Startup_InitConfig_Impl.OnInitConfigTimeOut(jobNode)
end

function Job_Startup_InitConfig_Impl.OnInitConfigDispose(jobNode)
end

return Job_Startup_InitConfig_Impl
