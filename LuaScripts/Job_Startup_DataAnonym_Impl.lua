local Job_Startup_DataAnonym_Impl = {}

function Job_Startup_DataAnonym_Impl.TryRequestDataAnonym(jobNode)
  local function OnGetDataAnonymCB(bSuccess, sMessage)
    if bSuccess then
      ReportManager:ReportLoginProcess("DataAnonym", "Success")
      
      if ChannelManager:IsWindows() then
        if not CS.UnityEngine.Application.isEditor then
          CS.BugSplatUtils.Instance:SetDeviceId(CS.DeviceUtil.GetDeviceID())
        end
      else
        CS.BuglyUtils.Instance:SetDeviceId(CS.DeviceUtil.GetDeviceID())
      end
      jobNode.Status = JobStatus.Success
    else
      ReportManager:ReportLoginProcess("DataAnonym", "Failed: " .. sMessage)
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("CommonError"),
        content = CS.ConfFact.LangFormat4DataInit("DataAnonymFail"),
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
        funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
        btnNum = 2,
        bLockBack = true,
        func1 = function()
          Job_Startup_DataAnonym_Impl.TryRequestDataAnonym(jobNode)
        end,
        func2 = function()
          jobNode.Status = JobStatus.Failed
          CS.ApplicationManager.Instance:RestartGame()
        end
      })
    end
  end
  
  CS.MonoMethodUtil.StartCoroutine(CS.DeviceUtil.GetDataAnonym(OnGetDataAnonymCB))
end

function Job_Startup_DataAnonym_Impl.OnDataAnonym(jobNode)
  ReportManager:ReportLoginProcess("DataAnonym", "Start")
  Job_Startup_DataAnonym_Impl.TryRequestDataAnonym(jobNode)
end

function Job_Startup_DataAnonym_Impl.OnDataAnonymSuccess(jobNode)
end

function Job_Startup_DataAnonym_Impl.OnDataAnonymFailed(jobNode)
end

function Job_Startup_DataAnonym_Impl.OnDataAnonymTimeOut(jobNode)
end

function Job_Startup_DataAnonym_Impl.OnDataAnonymDispose(jobNode)
end

return Job_Startup_DataAnonym_Impl
