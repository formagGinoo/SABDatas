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
          local status, err = pcall(function()
            DmmManager:Login(OnLoginCallback)
          end)
          if not status then
            log.error("DmmManager:Login failed: " .. tostring(err))
            ReportManager:ReportLoginProcess("InitDMMSDK_Login", "Failed_InitError", true)
            TimeService:SetTimer(1.0, 1, function()
              tryLoginDmm()
            end)
          end
        end
        
        TimeService:SetTimer(0.1, 1, function()
          tryLoginDmm()
        end)
      else
        local args = CS.Environment.GetCommandLineArgs()
        for i = 1, #args do
          CS.UnityEngine.Debug.LogError(args[i])
        end
        CS.Debug.LogError("InitDMMSDK_Login failed: " .. tostring(message))
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
  elseif ChannelManager:IsWegameChannel() then
    ReportManager:ReportLoginProcess("InitWegame_Login", "Start", true)
    local tryLoginWegame
    
    local function OnLoginCallback(response)
      local resultTable = json.decode(response)
      if resultTable.result == 0 then
        log.info("Wegame OnLoginSuccessCB " .. resultTable.session_ticket.ticket)
        ReportManager:ReportLoginProcess("InitWegame_Login", "Success", true)
        WegameManager:SetTicket(resultTable.session_ticket.ticket)
        jobNode.Status = JobStatus.Success
      else
        log.info("Wegame OnLoginFailCB: " .. tostring(error))
        ReportManager:ReportLoginProcess("InitWegame_Login", "Failed_" .. tostring(error), true)
        tryLoginWegame()
      end
    end
    
    function tryLoginWegame()
      if not WegameManager.wegameManager then
        log.warn("WegameManager not initialized, attempting to initialize...")
        WegameManager:Initialize()
      end
      local status, err = pcall(function()
        WegameManager:Login(OnLoginCallback)
      end)
      if not status then
        log.error("WegameManager:Login failed: " .. tostring(err))
        ReportManager:ReportLoginProcess("InitWegame_Login", "Failed_InitError", true)
        TimeService:SetTimer(1.0, 1, function()
          tryLoginWegame()
        end)
      end
    end
    
    TimeService:SetTimer(0.1, 1, function()
      tryLoginWegame()
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
      local status, err = pcall(function()
        QSDKManager:Login(OnLoginSuccessCB, OnLoginFailCB)
      end)
      if not status then
        log.error("QSDKManager:Login failed: " .. tostring(err))
        ReportManager:ReportLoginProcess("InitQSDK_Login", "Failed_InitError", true)
        TimeService:SetTimer(1.0, 1, function()
          tryLogin()
        end)
      end
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
