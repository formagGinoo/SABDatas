local Job_Startup_CheckNetwork_Impl = {}

function Job_Startup_CheckNetwork_Impl.OnCheckNetwork(jobNode)
  Job_Startup_CheckNetwork_Impl.retryCount = 0
  Job_Startup_CheckNetwork_Impl.DoCheck(jobNode)
end

function Job_Startup_CheckNetwork_Impl.DoCheck(jobNode)
  if CS.Util.NetAvailable == true then
    jobNode.Status = JobStatus.Success
  else
    Job_Startup_CheckNetwork_Impl.retryCount = Job_Startup_CheckNetwork_Impl.retryCount + 1
    if Job_Startup_CheckNetwork_Impl.retryCount < 2 then
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("CommonError"),
        content = CS.ConfFact.LangFormat4DataInit("LoginConnectServerFail"),
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
        btnNum = 1,
        func1 = function()
          Job_Startup_CheckNetwork_Impl.DoCheck(jobNode)
        end
      })
    else
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("CommonError"),
        content = CS.ConfFact.LangFormat4DataInit("StartCheckNetworkFail"),
        btnNum = 2,
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
        func1 = function()
          Job_Startup_CheckNetwork_Impl.DoCheck(jobNode)
        end,
        funcText2 = CS.ConfFact.LangFormat4DataInit("CommonExit"),
        func2 = function()
          CS.ApplicationManager.Instance:ExitGame()
        end
      })
    end
  end
end

function Job_Startup_CheckNetwork_Impl.OnCheckNetworkSuccess(jobNode)
end

function Job_Startup_CheckNetwork_Impl.OnCheckNetworkFailed(jobNode)
end

function Job_Startup_CheckNetwork_Impl.OnCheckNetworkTimeOut(jobNode)
end

function Job_Startup_CheckNetwork_Impl.OnCheckNetworkDispose(jobNode)
end

return Job_Startup_CheckNetwork_Impl
