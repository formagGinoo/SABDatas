local Form_HeroSkillLevelUp_Tips = class("Form_HeroSkillLevelUp_Tips", require("UI/UIFrames/Form_HeroSkillLevelUp_TipsUI"))

function Form_HeroSkillLevelUp_Tips:SetInitParam(param)
end

function Form_HeroSkillLevelUp_Tips:AfterInit()
  self.super.AfterInit(self)
end

function Form_HeroSkillLevelUp_Tips:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.m_txt_cur_lv_Text.text = tParam.newLv or 0
  GlobalManagerIns:TriggerWwiseBGMState(25)
end

function Form_HeroSkillLevelUp_Tips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroSkillLevelUp_Tips:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_HeroSkillLevelUp_Tips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroSkillLevelUp_Tips", Form_HeroSkillLevelUp_Tips)
return Form_HeroSkillLevelUp_Tips
