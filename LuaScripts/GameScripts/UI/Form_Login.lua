local GuideManager = require("GameScripts.Manager.GuideManager")
local Form_Login = class("Form_Login", require("UI/UIFrames/Form_LoginUI"))
local ConfFact = CS.ConfFact
local UIStatic = CS.UIStatic
local eSystemTipType = CS.eSystemTipType
local WeakReference = CS.System.WeakReference
local LuaManagerInstance = CS.LuaManager.Instance
local Mathf = CS.UnityEngine.Mathf

function Form_Login:AfterInit()
  local bConnectGameServer = false
  if self.m_csui.m_param ~= nil then
    bConnectGameServer = self.m_csui.m_param
  end
  TimeService:SetTimer(1.0E-4, 1, function()
    require("common/GlobalRequire")
    if bConnectGameServer then
      local ConnectGameServerFlow = require("JobFlow/JobGraphConnectGameServer/JobGraphConnectGameServer")
      self.m_jobFlow = ConnectGameServerFlow.Instance()
      self.m_jobFlow:Run(handler(self, self.OnStateChange))
    else
      local StartupFlow = require("JobFlow/JobGraphStartup/JobGraphStartup")
      self.m_jobFlow = StartupFlow.Instance()
      self.m_jobFlow:Run(handler(self, self.OnStateChange))
    end
  end)
  self.m_BottomPanel:SetActive(true)
  self.m_panelStart:SetActive(false)
  self.m_title_Text.text = ""
  self.m_isCheckConncentLogin = true
  self.m_progressBar_Image.fillAmount = 0
  self.m_jobProgress = 0
  self.m_jobTargetProgress = 0
  self:ShowVersionAndRoleID()
end

function Form_Login:OnStateChange(node, before, after)
  self.m_jobProgress = self.m_jobTargetProgress
  self.m_jobTargetProgress = self.m_jobFlow:GetJobProgress()
end

function Form_Login:OnActive()
end

function Form_Login:OnInactive()
end

function Form_Login:ShowVersionAndRoleID()
end

function Form_Login:OnBtnStartClicked()
  GuideManager:OnInitEventListener()
  CS.GameFlowManager.Instance:OnJobStartupFinished()
end

function Form_Login:InitEventListener()
end

function Form_Login:RemoveEventListener()
end

function Form_Login:OnUpdate(dt)
  self.m_jobTargetProgress = self.m_jobFlow:GetJobProgress()
  if dt < self.m_jobTargetProgress - self.m_jobProgress then
    self.m_jobProgress = math.min(self.m_jobProgress + dt, self.m_jobTargetProgress)
  else
    self.m_jobProgress = self.m_jobTargetProgress
  end
  self.m_progressBar_Image.fillAmount = self.m_jobProgress
  if self.m_jobProgress == 1 then
    self.m_BottomPanel:SetActive(false)
    self.m_panelStart:SetActive(true)
  end
end

ActiveLuaUI("Form_Login", Form_Login)
return Form_Login
