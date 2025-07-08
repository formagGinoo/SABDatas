local Form_HeroCampDetail = class("Form_HeroCampDetail", require("UI/UIFrames/Form_HeroCampDetailUI"))
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")

function Form_HeroCampDetail:SetInitParam(param)
end

function Form_HeroCampDetail:AfterInit()
  self.super.AfterInit(self)
end

function Form_HeroCampDetail:OnActive()
  self.super.OnActive(self)
  self:FreshUI()
end

function Form_HeroCampDetail:OnInactive()
  self.super.OnInactive(self)
end

function Form_HeroCampDetail:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroCampDetail:FreshUI()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_curHeroCfg = tParam.heroCfg
  self:FreshShowCamp()
end

function Form_HeroCampDetail:FreshShowCamp()
  if self.m_curHeroCfg.m_HeroID == 0 then
    return
  end
  local campCfg = CampCfgIns:GetValue_ByCampID(self.m_curHeroCfg.m_Camp)
  if not campCfg:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_img_camp_Image, campCfg.m_CampIcon)
    self.m_txt_title_Text.text = campCfg.m_mCampName
    self.m_txt_content_Text.text = campCfg.m_mCampDesc
  end
end

function Form_HeroCampDetail:OnBtnclosebgClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_HeroCampDetail:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroCampDetail", Form_HeroCampDetail)
return Form_HeroCampDetail
