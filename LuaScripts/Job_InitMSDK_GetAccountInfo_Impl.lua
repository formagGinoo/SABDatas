local Job_InitMSDK_GetAccountInfo_Impl = {}

function Job_InitMSDK_GetAccountInfo_Impl.OnGetAccountInfo(jobNode)
  local function OnGetAccountInfoSuccessCB()
    jobNode.Status = JobStatus.Success
  end
  
  local function OnGetAccountInfoFailCB()
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("InitMSDKGetAccountInfoFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
    jobNode.Status = JobStatus.Failed
  end
  
  CS.MSDKLogin.Instance:GetAccountInfo(OnGetAccountInfoSuccessCB, OnGetAccountInfoFailCB)
end

function Job_InitMSDK_GetAccountInfo_Impl.OnGetAccountInfoSuccess(jobNode)
end

function Job_InitMSDK_GetAccountInfo_Impl.OnGetAccountInfoFailed(jobNode)
end

function Job_InitMSDK_GetAccountInfo_Impl.OnGetAccountInfoTimeOut(jobNode)
end

function Job_InitMSDK_GetAccountInfo_Impl.OnGetAccountInfoDispose(jobNode)
end

return Job_InitMSDK_GetAccountInfo_Impl
