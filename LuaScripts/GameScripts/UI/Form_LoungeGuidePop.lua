local Form_LoungeGuidePop = class("Form_LoungeGuidePop", require("UI/UIFrames/Form_LoungeGuidePopUI"))

function Form_LoungeGuidePop:SetInitParam(param)
end

function Form_LoungeGuidePop:AfterInit()
  self.super.AfterInit(self)
  if not utils.isNull(self.m_btnClose) then
    self.m_btnClose:SetActive(true)
  end
end

function Form_LoungeGuidePop:OnActive()
  self.super.OnActive(self)
end

function Form_LoungeGuidePop:OnInactive()
  self.super.OnInactive(self)
  self:broadcastEvent("eGameEvent_Lounge_GuidePop_Inactive")
end

function Form_LoungeGuidePop:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_LoungeGuidePop:OnBtncloseClicked()
  self:CloseForm()
end

function Form_LoungeGuidePop:IsOpenGuassianBlur()
  return true
end

function Form_LoungeGuidePop:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_LoungeGuidePop", Form_LoungeGuidePop)
return Form_LoungeGuidePop
