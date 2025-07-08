local Form_HeroCareerDetail = class("Form_HeroCareerDetail", require("UI/UIFrames/Form_HeroCareerDetailUI"))
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")

function Form_HeroCareerDetail:SetInitParam(param)
end

function Form_HeroCareerDetail:AfterInit()
  self.super.AfterInit(self)
end

function Form_HeroCareerDetail:OnActive()
  self.super.OnActive(self)
  self:FreshUI()
end

function Form_HeroCareerDetail:OnInactive()
  self.super.OnInactive(self)
end

function Form_HeroCareerDetail:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroCareerDetail:FreshUI()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_curHeroCfg = tParam.heroCfg
  self:FreshCareer()
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_content)
end

function Form_HeroCareerDetail:FreshCareer()
  if self.m_curHeroCfg.m_HeroID == 0 then
    return
  end
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(self.m_curHeroCfg.m_Career)
  if not careerCfg:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_img_career_Image, careerCfg.m_CareerIcon)
    self.m_txt_career_title_Text.text = careerCfg.m_mCareerName
    self.m_txt_career_content_Text.text = careerCfg.m_mCareerDesc
  end
end

function Form_HeroCareerDetail:OnBtnclosebgClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_HeroCareerDetail:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroCareerDetail", Form_HeroCareerDetail)
return Form_HeroCareerDetail
