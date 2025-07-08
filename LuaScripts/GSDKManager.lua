local BaseManager = require("Manager/Base/BaseManager")
local GSDKManager = class("GSDKManager", BaseManager)

function GSDKManager:OnCreate()
end

function GSDKManager:OnUpdate(dt)
end

function GSDKManager:RegisterEvent()
  CS.GSDKUtils.Instance:RegisterEvent(handler(self, self.OnAntiAddictionStatusEvent))
end

function GSDKManager:Initialize(OnInitSuccessCB, OnInitFailCB)
  CS.GSDKUtils.Instance:Initialize(OnInitSuccessCB, OnInitFailCB)
end

function GSDKManager:Login(OnLoginSuccessCB, OnLoginFailCB)
  CS.GSDKUtils.Instance:Login(OnLoginSuccessCB, OnLoginFailCB)
end

function GSDKManager:Logout(OnLogoutCB)
  CS.GSDKUtils.Instance:Logout(function(bSuccess, code)
    TimeService:SetTimer(0.1, 1, function()
      if OnLogoutCB then
        OnLogoutCB(bSuccess, code)
      end
    end)
  end)
end

function GSDKManager:SetAccountInfo(accountInfo)
  self.m_accountInfo = accountInfo
end

function GSDKManager:GetAccountInfo()
  return self.m_accountInfo
end

function GSDKManager:FetchRealNameState(OnFetchRealNameStateCB)
  CS.GSDKUtils.Instance:FetchRealNameState(OnFetchRealNameStateCB)
end

function GSDKManager:ComplianceRealNameAuth(OnComplianceRealNameAuth)
  CS.GSDKUtils.Instance:ComplianceRealNameAuth(OnComplianceRealNameAuth)
end

function GSDKManager:FetchServiceAntiAddictionStatusFromLocal(OnAntiAddictionStatusCB)
  self.m_OnAntiAddictionStatusCB = OnAntiAddictionStatusCB
  CS.GSDKUtils.Instance:FetchServiceAntiAddictionStatusFromLocal()
end

function GSDKManager:FetchServiceAntiAddictionStatusFromServer(OnAntiAddictionStatusCB)
  self.m_OnAntiAddictionStatusCB = OnAntiAddictionStatusCB
  CS.GSDKUtils.Instance:FetchServiceAntiAddictionStatusFromServer()
end

function GSDKManager:ShowUserCenter()
  CS.GSDKUtils.Instance:ShowUserCenter()
end

function GSDKManager:ShowLicense()
  CS.GSDKUtils.Instance:ShowLicense()
end

function GSDKManager:ShowPrivacyPolicy()
  CS.GSDKUtils.Instance:ShowPrivacyPolicy()
end

function GSDKManager:IsProtocolUpdated()
  return CS.GSDKUtils.Instance:IsProtocolUpdated()
end

function GSDKManager:ShowLicenseUpdateGuide(OnProtocolAgreeCB)
  return CS.GSDKUtils.Instance:ShowLicenseUpdateGuide(OnProtocolAgreeCB)
end

local AntiAddictionOperation = {
  Fail = -1,
  Ignore = 0,
  MinorRemind = 1,
  ForceOffline = 2,
  MinorLimit = 3,
  MinorCurfew = 4,
  VisitorLimit = 5,
  VisitorRemind = 6,
  RemindOffline = 7,
  VisitorCurfew = 8,
  MinorLoginTips = 10,
  VisitorLoginTips = 11
}

function GSDKManager:OnAntiAddictionStatusEvent(info, operation, isLogin)
  log.info("GSDKManager:OnAntiAddictionStatusEvent:" .. tostring(operation))
  if operation == AntiAddictionOperation.MinorCurfew then
    utils.CheckAndPushCommonTips({
      content = isLogin and info.loginMessage or info.message,
      btnNum = 2,
      funcText1 = "切换账号",
      funcText2 = "退出游戏",
      func1 = function()
        self:Logout(function()
          CS.ApplicationManager.Instance:RestartGame()
        end)
      end,
      func2 = function()
        CS.ApplicationManager.Instance:ExitGame()
      end
    })
    if self.m_OnAntiAddictionStatusCB then
      self.m_OnAntiAddictionStatusCB(false)
    end
  elseif operation == AntiAddictionOperation.VisitorLimit then
    self:ComplianceRealNameAuth(function(IsSuccess, code)
      if IsSuccess then
        if self.m_OnAntiAddictionStatusCB then
          self.m_OnAntiAddictionStatusCB(true)
        end
      else
        utils.CheckAndPushCommonTips({
          tipsID = 9993,
          bLockBack = true,
          func1 = function()
            CS.ApplicationManager.Instance:RestartGame()
          end
        })
        if self.m_OnAntiAddictionStatusCB then
          self.m_OnAntiAddictionStatusCB(false)
        end
      end
    end)
  elseif self.m_OnAntiAddictionStatusCB then
    self.m_OnAntiAddictionStatusCB(true)
  end
end

return GSDKManager
