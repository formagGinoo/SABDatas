local Form_GuideAllSkipPop = class("Form_GuideAllSkipPop", require("UI/UIFrames/Form_GuideAllSkipPopUI"))

function Form_GuideAllSkipPop:SetInitParam(param)
end

function Form_GuideAllSkipPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_GuideAllSkipPop:OnActive()
  self.super.OnActive(self)
  self.m_BtnYesBack = self.m_csui.m_param.func1
  local CommonTextIns = ConfigManager:GetConfigInsByName("ConfirmCommonTips")
  local showMessageCfg = CommonTextIns:GetValue_ByID(1248)
  self.m_word_Text.text = showMessageCfg.m_mcontent
  self.m_toggle_txt_Text.text = ConfigManager:GetCommonTextById(2034)
  self.m_Toggle_Toggle.isOn = false
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_Toggle)
  self:ResetTimer()
  self.timer = TimeService:SetTimer(0.3, 1, function()
    BattleGlobalManager:RealSetSetPause(true)
  end)
  self.m_txt_yes_Text.text = showMessageCfg.m_mbutton1text
  self.m_txt_no_Text.text = showMessageCfg.m_mbutton2text
end

function Form_GuideAllSkipPop:OnInactive()
  self.super.OnInactive(self)
  self:ResetTimer()
end

function Form_GuideAllSkipPop:OnDestroy()
  self.super.OnDestroy(self)
  self:ResetTimer()
end

function Form_GuideAllSkipPop:ResetTimer()
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function Form_GuideAllSkipPop:CloseUI()
  CS.UI.UILuaHelper.StartPlaySFX("Play_ui_button_confirm")
  StackTop:RemoveUIFromStack(UIDefines.ID_FORM_GUIDEALLSKIPPOP)
  BattleGlobalManager:RealSetSetPause(false)
end

function Form_GuideAllSkipPop:OnBtnyesClicked()
  if self.m_BtnYesBack then
    self.m_BtnYesBack()
  end
  self:SaveToggleYes()
  self:CloseUI()
end

function Form_GuideAllSkipPop:OnBtnnoClicked()
  self:CloseUI()
end

function Form_GuideAllSkipPop:OnBtnCloseClicked()
  self:CloseUI()
end

function Form_GuideAllSkipPop:SaveToggleYes()
  if self.m_Toggle_Toggle.isOn then
    LocalDataManager:SetIntSimple("DialogueAllSkip", 1)
  end
end

function Form_GuideAllSkipPop:IsOpenGuassianBlur()
  return true
end

function Form_GuideAllSkipPop:GetRootTransformType()
  return UIRootTransformType.Story
end

local fullscreen = true
ActiveLuaUI("Form_GuideAllSkipPop", Form_GuideAllSkipPop)
return Form_GuideAllSkipPop
