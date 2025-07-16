local Form_HeroDamageTypeDetail = class("Form_HeroDamageTypeDetail", require("UI/UIFrames/Form_HeroDamageTypeDetailUI"))

function Form_HeroDamageTypeDetail:SetInitParam(param)
end

function Form_HeroDamageTypeDetail:AfterInit()
  self.super.AfterInit(self)
end

function Form_HeroDamageTypeDetail:OnActive()
  self.super.OnActive(self)
  self:FreshUI()
end

function Form_HeroDamageTypeDetail:FreshUI()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_curHeroCfg = tParam.heroCfg
  self:FreshDamage()
end

function Form_HeroDamageTypeDetail:OnInactive()
  self.super.OnInactive(self)
end

function Form_HeroDamageTypeDetail:FreshDamage()
  if self.m_curHeroCfg.m_HeroID == 0 then
    return
  end
  local CharacterDamageTypeIns = ConfigManager:GetConfigInsByName("CharacterDamageType")
  local stItemData = CharacterDamageTypeIns:GetValue_ByDamageType(self.m_curHeroCfg.m_MainAttribute)
  if not stItemData:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_img_damagetype_Image, stItemData.m_DamageTypeIcon)
    self.m_txt_damagetype_title_Text.text = stItemData.m_mDamageTypeName
    self.m_txt_damagetype_content_Text.text = stItemData.m_mDamageTypeDesc
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_content)
end

function Form_HeroDamageTypeDetail:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroDamageTypeDetail:OnBtnclosebgClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_HeroDamageTypeDetail:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroDamageTypeDetail", Form_HeroDamageTypeDetail)
return Form_HeroDamageTypeDetail
