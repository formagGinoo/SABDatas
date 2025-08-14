local Job_InitMSDK_Init_Impl = {}

function Job_InitMSDK_Init_Impl.OnInit(jobNode)
  local function OnInitSuccessCB()
    jobNode.Status = JobStatus.Success
  end
  
  local function OnInitFailCB()
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("InitMSDKInitFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
    jobNode.Status = JobStatus.Failed
  end
  
  CS.MSDKLogin.Instance:Init(OnInitSuccessCB, OnInitFailCB)
end

function Job_InitMSDK_Init_Impl.OnInitSuccess(jobNode)
end

function Job_InitMSDK_Init_Impl.OnInitFailed(jobNode)
end

function Job_InitMSDK_Init_Impl.OnInitTimeOut(jobNode)
end

function Job_InitMSDK_Init_Impl.OnInitDispose(jobNode)
end

return Job_InitMSDK_Init_Impl
