local Form_InheritLevelUpSuccess = class("Form_InheritLevelUpSuccess", require("UI/UIFrames/Form_InheritLevelUpSuccessUI"))

function Form_InheritLevelUpSuccess:SetInitParam(param)
end

function Form_InheritLevelUpSuccess:AfterInit()
  self.super.AfterInit(self)
end

function Form_InheritLevelUpSuccess:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_txt_lv_num_Text.text = tostring(tParam.iOldLevel)
  self.m_txt_lv_num2_Text.text = tostring(tParam.iNewLevel)
end

function Form_InheritLevelUpSuccess:OnInactive()
  self.super.OnInactive(self)
end

function Form_InheritLevelUpSuccess:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_InheritLevelUpSuccess:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_InheritLevelUpSuccess:IsOpenGuassianBlur()
  return true
end

function Form_InheritLevelUpSuccess:IsFullScreen()
  return false
end

local fullscreen = true
ActiveLuaUI("Form_InheritLevelUpSuccess", Form_InheritLevelUpSuccess)
return Form_InheritLevelUpSuccess
