local Job_InitGSDK_Login_Impl = {}
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function Job_InitGSDK_Login_Impl.OnLogin(jobNode)
  if ChannelManager:IsDMMChannel() then
    ReportManager:ReportLoginProcess("InitDMMSDK_Login", "Start", true)
    CS.DMMSDKManger.Instance:InitStore(function(success, message)
      if success then
        local tryLoginDmm
        
        local function OnLoginCallback(result, error)
          if CS.UnityEngine.Application.isEditor then
            local info = {
              viewerId = 115789,
              onetimeToken = "4ecdd2c47a2fda6ab66e67d1360bf43d",
              accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhcHBfaWQiOjExMjcsImNvbnN1bWVyX2tleSI6IjdScTd2NWVzWmh5Y0cxSmkiLCJjb25zdW1lcl9zZWNyZXQiOiJEeWJBVGI2YTBmQ0lKNFtWLT81bk0kP3c_d01vdmg5RSIsInZpZXdlcl9pZCI6MTE1Nzg5LCJvbmV0aW1lX3Rva2VuIjoiNGVjZGQyYzQ3YTJmZGE2YWI2NmU2N2QxMzYwYmY0M2QifQ.mk0Y3xGhwh39Q98q4pIYDIEVOggQ_9mqgIe0_-zRljw",
              openId = "115789",
              pfAccessToken = "Lr0SevWxnb3UN4VM5oZaGhpAFygdCD6wOKEmJ9Hft1QlXYTPqs8u2IR7kjizcB"
            }
            DmmManager:SetAccountInfo(info)
            jobNode.Status = JobStatus.Success
            return
          end
          if not error or error == 0 then
            log.info("DMMSDK OnLoginSuccessCB " .. tostring(result))
            local resultTable = json.decode(result)
            ReportManager:ReportLoginProcess("InitDMMSDK_Login", "Success", true)
            DmmManager:SetAccountInfo(resultTable)
            jobNode.Status = JobStatus.Success
          else
            log.info("DMMSDK OnLoginFailCB: " .. tostring(error))
            ReportManager:ReportLoginProcess("InitDMMSDK_Login", "Failed_" .. tostring(error), true)
            tryLoginDmm()
          end
        end
        
        function tryLoginDmm()
          DmmManager:Login(OnLoginCallback)
        end
        
        TimeService:SetTimer(0.1, 1, function()
          tryLoginDmm()
        end)
      else
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
    end)
  else
    ReportManager:ReportLoginProcess("InitQSDK_Login", "Start", true)
    local tryLogin
    
    local function OnLoginSuccessCB(accountInfo)
      log.info("QSDK OnLoginSuccessCB " .. tostring(accountInfo))
      ReportManager:ReportLoginProcess("InitQSDK_Login", "Success", true)
      QSDKManager:SetAccountInfo(accountInfo)
      jobNode.Status = JobStatus.Success
    end
    
    local function OnLoginFailCB(errorCode)
      log.info("QSDK OnLoginFailCB: " .. tostring(errorCode))
      ReportManager:ReportLoginProcess("InitQSDK_Login", "Failed_" .. tostring(errorCode), true)
      if QSDKManager:IsHuawei() then
        EventCenter.Broadcast(EventDefine.eGameEvent_QSDKLogin_Failed, jobNode)
      else
        tryLogin()
      end
    end
    
    function tryLogin()
      QSDKManager:Login(OnLoginSuccessCB, OnLoginFailCB)
    end
    
    TimeService:SetTimer(0.1, 1, function()
      tryLogin()
    end)
  end
end

function Job_InitGSDK_Login_Impl.OnLoginSuccess(jobNode)
end

function Job_InitGSDK_Login_Impl.OnLoginFailed(jobNode)
end

function Job_InitGSDK_Login_Impl.OnLoginTimeOut(jobNode)
end

function Job_InitGSDK_Login_Impl.OnLoginDispose(jobNode)
end

return Job_InitGSDK_Login_Impl
