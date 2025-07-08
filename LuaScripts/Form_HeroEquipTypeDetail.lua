local Form_HeroEquipTypeDetail = class("Form_HeroEquipTypeDetail", require("UI/UIFrames/Form_HeroEquipTypeDetailUI"))

function Form_HeroEquipTypeDetail:SetInitParam(param)
end

function Form_HeroEquipTypeDetail:AfterInit()
  self.super.AfterInit(self)
end

function Form_HeroEquipTypeDetail:OnActive()
  self.super.OnActive(self)
  self.m_bg_moon:SetActive(false)
  self.m_img_equip:SetActive(false)
  self:FreshUI()
end

function Form_HeroEquipTypeDetail:OnInactive()
  self.super.OnInactive(self)
end

function Form_HeroEquipTypeDetail:FreshUI()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_curHeroCfg = tParam.heroCfg
  if tParam.isMoonType then
    self:FreshMoonDetail()
    self.m_bg_moon:SetActive(true)
    self.m_img_equip:SetActive(false)
  else
    self.m_bg_moon:SetActive(false)
    self.m_img_equip:SetActive(true)
    self:FreshEquip()
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_content)
end

function Form_HeroEquipTypeDetail:FreshEquip()
  if self.m_curHeroCfg.m_HeroID == 0 then
    return
  end
  local EquipTypeCfgIns = ConfigManager:GetConfigInsByName("EquipType")
  local stItemData = EquipTypeCfgIns:GetValue_ByEquiptypeID(self.m_curHeroCfg.m_Equiptype)
  if not stItemData:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_img_equip_Image, stItemData.m_EquiptypeIcon)
    self.m_txt_equip_title_Text.text = stItemData.m_mEquiptypeName
    self.m_txt_equip_content_Text.text = stItemData.m_mEquiptypeDesc
  end
end

function Form_HeroEquipTypeDetail:FreshMoonDetail()
  if self.m_curHeroCfg.m_HeroID == 0 then
    return
  end
  local MoonTypeCfgIns = ConfigManager:GetConfigInsByName("MoonType")
  local stItemData = MoonTypeCfgIns:GetValue_ByMoontypeID(self.m_curHeroCfg.m_MoonType)
  if not stItemData:GetError() then
    self.m_txt_equip_title_Text.text = stItemData.m_mMoontypeName
    self.m_txt_equip_content_Text.text = stItemData.m_mMoontypeDesc
  end
  self.m_icon_moon1:SetActive(self.m_curHeroCfg.m_MoonType == 1)
  self.m_icon_moon2:SetActive(self.m_curHeroCfg.m_MoonType == 2)
  self.m_icon_moon3:SetActive(self.m_curHeroCfg.m_MoonType == 3)
end

function Form_HeroEquipTypeDetail:OnBtnclosebgClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_HeroEquipTypeDetail:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroEquipTypeDetail:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroEquipTypeDetail", Form_HeroEquipTypeDetail)
return Form_HeroEquipTypeDetail
