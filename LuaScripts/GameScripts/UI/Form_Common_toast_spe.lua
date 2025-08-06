local Form_Common_toast_spe = class("Form_Common_toast_spe", require("UI/UIFrames/Form_Common_toast_speUI"))
local ConfigManger = _ENV.ConfigManger

function Form_Common_toast_spe:SetInitParam(param)
end

function Form_Common_toast_spe:AfterInit()
  self.super.AfterInit(self)
end

function Form_Common_toast_spe:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
end

function Form_Common_toast_spe:OnInactive()
  self.super.OnInactive(self)
end

function Form_Common_toast_spe:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Common_toast_spe:FreshData()
  local tParam = self.m_csui.m_param
  self.m_showString = nil
  if tParam then
    local param = tParam
    local showString
    if type(param) == "string" then
      showString = param
    elseif type(param) == "number" then
      showString = ConfigManger:GetClientMessageTextById(param)
    end
    self.m_showString = showString
    self.m_csui.m_param = nil
  end
end

function Form_Common_toast_spe:FreshUI()
  if not self.m_showString then
    self:CloseForm()
    return
  end
  self.m_txt_toast_Text.text = self.m_showString
  if self.m_hideTimer then
    TimeService:KillTimer(self.m_hideTimer)
    self.m_hideTimer = nil
  end
  self.m_hideTimer = TimeService:SetTimer(self.m_uiVariables.HideTimeNum, 1, function()
    self.m_showString = nil
    self.m_hideTimer = nil
    self:CloseForm()
  end)
end

local fullscreen = true
ActiveLuaUI("Form_Common_toast_spe", Form_Common_toast_spe)
return Form_Common_toast_spe
