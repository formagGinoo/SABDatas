local Job_InitMSDK_AccountInit_Impl = {}

function Job_InitMSDK_AccountInit_Impl.OnAccountInit(jobNode)
  local function OnAccountInitSuccessCB()
    jobNode.Status = JobStatus.Success
  end
  
  local function OnAccountInitFailCB()
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("InitMSDKAccountInitFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
    jobNode.Status = JobStatus.Failed
  end
  
  CS.MSDKLogin.Instance:AccountInit(OnAccountInitSuccessCB, OnAccountInitFailCB)
end

function Job_InitMSDK_AccountInit_Impl.OnAccountInitSuccess(jobNode)
end

function Job_InitMSDK_AccountInit_Impl.OnAccountInitFailed(jobNode)
end

function Job_InitMSDK_AccountInit_Impl.OnAccountInitTimeOut(jobNode)
end

function Job_InitMSDK_AccountInit_Impl.OnAccountInitDispose(jobNode)
end

return Job_InitMSDK_AccountInit_Impl
