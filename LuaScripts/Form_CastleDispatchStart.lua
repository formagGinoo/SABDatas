local Form_CastleDispatchStart = class("Form_CastleDispatchStart", require("UI/UIFrames/Form_CastleDispatchStartUI"))

function Form_CastleDispatchStart:SetInitParam(param)
end

function Form_CastleDispatchStart:AfterInit()
  self.super.AfterInit(self)
end

function Form_CastleDispatchStart:OnActive()
  self.super.OnActive(self)
  self.m_btnClose:SetActive(false)
  self.timer = TimeService:SetTimer(2, 1, function()
    if self.m_btnClose then
      self.m_btnClose:SetActive(true)
    end
    if self.OnBtnCloseClicked then
      self:OnBtnCloseClicked()
    end
  end)
end

function Form_CastleDispatchStart:OnInactive()
  self.super.OnInactive(self)
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function Form_CastleDispatchStart:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_CastleDispatchStart:IsOpenGuassianBlur()
  return true
end

function Form_CastleDispatchStart:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_CastleDispatchStart", Form_CastleDispatchStart)
return Form_CastleDispatchStart
