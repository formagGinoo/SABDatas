local Job_InitGSDK_Init_Impl = {}

function Job_InitGSDK_Init_Impl.OnInit(jobNode)
  if ChannelManager:IsDMMChannel() then
    ReportManager:ReportLoginProcess("InitDMM_Init", "Start", true)
    DmmManager:Initialize()
    jobNode.Status = JobStatus.Success
  else
    ReportManager:ReportLoginProcess("InitQSDK_Init", "Start", true)
    
    local function OnInitSuccessCB()
      log.info("QSDK OnInitSuccessCB")
      ReportManager:ReportLoginProcess("InitQSDK_Init", "Success", true)
      QSDKManager:RegisterEvent()
      jobNode.Status = JobStatus.Success
    end
    
    local function OnInitFailCB(errorCode)
      ReportManager:ReportLoginProcess("InitQSDK_Init", "Failed", true)
      log.info("QSDK OnInitFailCB: " .. tostring(errorCode))
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
    
    QSDKManager:Initialize(OnInitSuccessCB, OnInitFailCB)
  end
end

function Job_InitGSDK_Init_Impl.OnInitSuccess(jobNode)
end

function Job_InitGSDK_Init_Impl.OnInitFailed(jobNode)
end

function Job_InitGSDK_Init_Impl.OnInitTimeOut(jobNode)
end

function Job_InitGSDK_Init_Impl.OnInitDispose(jobNode)
end

return Job_InitGSDK_Init_Impl
