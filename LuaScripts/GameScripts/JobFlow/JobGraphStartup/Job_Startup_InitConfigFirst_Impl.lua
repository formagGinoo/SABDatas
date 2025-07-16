local Job_Startup_InitConfigFirst_Impl = {}

function Job_Startup_InitConfigFirst_Impl.OnInitConfigFirst(jobNode)
  CS.AssetBundleHolder.Instance:HoldCommonAssetBundle()
  ConfigManager:InitFirstMustCfg(function(fUnitProgress)
    jobNode.UnitProgress = fUnitProgress
  end, function()
    for id, csui in pairs(StackFlow.UIs) do
      if csui ~= nil then
        UIManager:RefreshMultiLanguage(csui.m_uiGameObject)
      end
    end
    for id, csui in pairs(StackPopup.UIs) do
      if csui ~= nil then
        UIManager:RefreshMultiLanguage(csui.m_uiGameObject)
      end
    end
    for id, csui in pairs(StackTop.UIs) do
      if csui ~= nil then
        UIManager:RefreshMultiLanguage(csui.m_uiGameObject)
      end
    end
    for id, csui in pairs(StackSpecial.UIs) do
      if csui ~= nil then
        UIManager:RefreshMultiLanguage(csui.m_uiGameObject)
      end
    end
    jobNode.Status = JobStatus.Success
  end)
end

function Job_Startup_InitConfigFirst_Impl.OnInitConfigFirstSuccess(jobNode)
end

function Job_Startup_InitConfigFirst_Impl.OnInitConfigFirstFailed(jobNode)
end

function Job_Startup_InitConfigFirst_Impl.OnInitConfigFirstTimeOut(jobNode)
end

function Job_Startup_InitConfigFirst_Impl.OnInitConfigFirstDispose(jobNode)
end

return Job_Startup_InitConfigFirst_Impl
