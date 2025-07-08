local Form_CastleStarExcitingWindow = class("Form_CastleStarExcitingWindow", require("UI/UIFrames/Form_CastleStarExcitingWindowUI"))

function Form_CastleStarExcitingWindow:SetInitParam(param)
end

function Form_CastleStarExcitingWindow:AfterInit()
  self.super.AfterInit(self)
end

function Form_CastleStarExcitingWindow:OnActive()
  self.super.OnActive(self)
  local id, starId = self.m_csui.m_param.id, self.m_csui.m_param.starId
  local cfg = StargazingManager:GetStarInfo(id, starId)
  self.m_txt_infor_Text.text = cfg.m_mEffectDes
  self.callback = self.m_csui.m_param.callback
end

function Form_CastleStarExcitingWindow:OnInactive()
  self.super.OnInactive(self)
end

function Form_CastleStarExcitingWindow:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleStarExcitingWindow:OnBtnCloseClicked()
  self:CloseForm()
  if self.callback then
    self.callback()
  end
end

function Form_CastleStarExcitingWindow:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CastleStarExcitingWindow", Form_CastleStarExcitingWindow)
return Form_CastleStarExcitingWindow
