local Form_HeroLegacyUpgradeTips = class("Form_HeroLegacyUpgradeTips", require("UI/UIFrames/Form_HeroLegacyUpgradeTipsUI"))
local SkillIns = ConfigManager:GetConfigInsByName("Skill")
local LegacyLevelIns = ConfigManager:GetConfigInsByName("LegacyLevel")
local AttrBaseShowCfg = _ENV.AttrBaseShowCfg
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local MaxLegacySkillNum = LegacyManager.MaxLegacySkillNum

function Form_HeroLegacyUpgradeTips:SetInitParam(param)
end

function Form_HeroLegacyUpgradeTips:AfterInit()
  self.super.AfterInit(self)
  self.m_curLegacyData = nil
  self.m_curLegacyCfg = nil
  self.m_curLegacyID = nil
  self.m_beforeLv = nil
  self.m_afterLv = nil
  self.m_beforeLegacyLvCfg = nil
  self.m_afterLegacyLvCfg = nil
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_attr_base_root_trans = self.m_attr_base_root.transform
  self.m_showAttrBaseCfgList = {}
  self.m_showAttrBaseItems = {}
  self:InitShowAttr()
  self.m_beforeLegacySkillWidgets = {}
  local tempLegacyIcon = self:createLegacySkillIcon(self.m_legacy_skill_item)
  self.m_beforeLegacySkillWidgets[1] = tempLegacyIcon
  self.m_afterLegacySkillWidgets = {}
end

function Form_HeroLegacyUpgradeTips:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_HeroLegacyUpgradeTips:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_HeroLegacyUpgradeTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroLegacyUpgradeTips:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curLegacyData = tParam.legacyData
    self.m_curLegacyID = self.m_curLegacyData.serverData.iLegacyId
    self.m_curLegacyCfg = self.m_curLegacyData.legacyCfg
    self.m_beforeLv = self.m_curLegacyData.serverData.iLevel - 1
    self.m_afterLv = self.m_curLegacyData.serverData.iLevel
    self.m_beforeLegacyLvCfg = LegacyLevelIns:GetValue_ByIDAndLevel(self.m_curLegacyID, self.m_beforeLv)
    self.m_afterLegacyLvCfg = LegacyLevelIns:GetValue_ByIDAndLevel(self.m_curLegacyID, self.m_afterLv)
    self.m_csui.m_param = nil
  end
end

function Form_HeroLegacyUpgradeTips:ClearData()
end

function Form_HeroLegacyUpgradeTips:ClearCacheData()
end

function Form_HeroLegacyUpgradeTips:AddEventListeners()
end

function Form_HeroLegacyUpgradeTips:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroLegacyUpgradeTips:InitShowAttr()
  local propertyAllCfg = PropertyIndexIns:GetAll()
  for _, tempCfg in pairs(propertyAllCfg) do
    if AttrBaseShowCfg[tempCfg.m_PropertyID] == true then
      self.m_showAttrBaseCfgList[tempCfg.m_PropertyID] = tempCfg
    end
  end
  for _, v in ipairs(self.m_showAttrBaseCfgList) do
    local attrItemRoot
    if #self.m_showAttrBaseItems == 0 then
      attrItemRoot = self.m_attributes_item_base.transform
    else
      attrItemRoot = GameObject.Instantiate(self.m_attributes_item_base, self.m_attr_base_root_trans).transform
    end
    UILuaHelper.SetActive(attrItemRoot, true)
    local attrBeforeNumText = attrItemRoot:Find("c_txt_num_before"):GetComponent(T_TextMeshProUGUI)
    local attrAfterNumText = attrItemRoot:Find("c_txt_num_after"):GetComponent(T_TextMeshProUGUI)
    local attrIconImg = attrItemRoot:Find("c_icon"):GetComponent(T_Image)
    local attrNameText = attrItemRoot:Find("c_txt_sx_name"):GetComponent(T_TextMeshProUGUI)
    local attrItem = {
      itemRoot = attrItemRoot,
      attrBeforeNumText = attrBeforeNumText,
      attrAfterNumText = attrAfterNumText,
      attrIconImg = attrIconImg,
      attrNameText = attrNameText,
      propertyCfg = v
    }
    attrNameText.text = v.m_mCNName
    UILuaHelper.SetAtlasSprite(attrIconImg, v.m_PropertyIcon .. "_02")
    self.m_showAttrBaseItems[#self.m_showAttrBaseItems + 1] = attrItem
  end
end

function Form_HeroLegacyUpgradeTips:FreshUI()
  self:FreshLegacyBaseInfo()
  self:FreshLvChange()
  self:FreshPersonNumChange()
  self:FreshLegacyAttrChange()
  self:FreshBeforeSkillStatus()
  self:FreshAfterSkillStatus()
end

function Form_HeroLegacyUpgradeTips:FreshLegacyBaseInfo()
  if not self.m_curLegacyCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_legacy_icon_Image, self.m_curLegacyCfg.m_Icon)
end

function Form_HeroLegacyUpgradeTips:FreshLvChange()
  if not self.m_curLegacyData then
    return
  end
  self.m_txt_num_before_Text.text = self.m_beforeLv
  self.m_txt_num_after_Text.text = self.m_afterLv
end

function Form_HeroLegacyUpgradeTips:FreshPersonNumChange()
  if not self.m_beforeLegacyLvCfg then
    return
  end
  if not self.m_afterLegacyLvCfg then
    return
  end
  self.m_txt_person_before_Text.text = self.m_beforeLegacyLvCfg.m_Wearable
  self.m_txt_person_after_Text.text = self.m_afterLegacyLvCfg.m_Wearable
end

function Form_HeroLegacyUpgradeTips:FreshLegacyAttrChange()
  if not self.m_showAttrBaseItems then
    return
  end
  local legacyBeforeAttrTab = self.m_heroAttr:GetLegacyAttr(self.m_curLegacyID, self.m_beforeLv)
  local legacyAfterAttrTab = self.m_heroAttr:GetLegacyAttr(self.m_curLegacyID, self.m_afterLv)
  for _, attrItem in ipairs(self.m_showAttrBaseItems) do
    local beforeAttrValue = legacyBeforeAttrTab[attrItem.propertyCfg.m_ENName] or 0
    local afterAttrValue = legacyAfterAttrTab[attrItem.propertyCfg.m_ENName] or 0
    attrItem.attrBeforeNumText.text = BigNumFormat(beforeAttrValue)
    attrItem.attrAfterNumText.text = BigNumFormat(afterAttrValue)
  end
end

function Form_HeroLegacyUpgradeTips:FreshBeforeSkillStatus()
  if not self.m_beforeLegacyLvCfg or not self.m_curLegacyCfg then
    return
  end
  for i = 1, MaxLegacySkillNum do
    local skillWidget = self.m_beforeLegacySkillWidgets[i]
    local skillID = self.m_curLegacyCfg["m_Skillgroup" .. i]
    if skillID and skillID ~= 0 then
      UILuaHelper.SetActive(self["m_img_none_before" .. i], false)
      local skillCfg = SkillIns:GetValue_BySkillID(skillID)
      if skillCfg:GetError() ~= true then
        if skillWidget == nil then
          local newRoot = GameObject.Instantiate(self.m_legacy_skill_item, self["m_legacy_skill_before" .. i].transform).transform
          skillWidget = self:createLegacySkillIcon(newRoot)
          self.m_beforeLegacySkillWidgets[i] = skillWidget
        end
        local isLock = true
        local skillLevel = self.m_beforeLegacyLvCfg["m_SkillLevel" .. i]
        if skillLevel and 0 < skillLevel then
          isLock = false
        end
        skillWidget:SetActive(true)
        skillWidget:FreshSkillIsLock(isLock)
        skillWidget:FreshSkillInfo(skillID, skillLevel)
      else
        UILuaHelper.SetActive(self["m_img_none_before" .. i], true)
        if skillWidget then
          skillWidget:SetActive(false)
        end
      end
    else
      UILuaHelper.SetActive(self["m_img_none_before" .. i], true)
      if skillWidget then
        skillWidget:SetActive(false)
      end
    end
  end
end

function Form_HeroLegacyUpgradeTips:FreshAfterSkillStatus()
  if not self.m_afterLegacyLvCfg or not self.m_curLegacyCfg then
    return
  end
  for i = 1, MaxLegacySkillNum do
    local skillWidget = self.m_afterLegacySkillWidgets[i]
    local skillID = self.m_curLegacyCfg["m_Skillgroup" .. i]
    if skillID and skillID ~= 0 then
      UILuaHelper.SetActive(self["m_img_none_after" .. i], false)
      local skillCfg = SkillIns:GetValue_BySkillID(skillID)
      if skillCfg:GetError() ~= true then
        if skillWidget == nil then
          local newRoot = GameObject.Instantiate(self.m_legacy_skill_item, self["m_legacy_skill_after" .. i].transform).transform
          skillWidget = self:createLegacySkillIcon(newRoot)
          self.m_afterLegacySkillWidgets[i] = skillWidget
        end
        local isLock = true
        local skillLevel = self.m_afterLegacyLvCfg["m_SkillLevel" .. i]
        if skillLevel and 0 < skillLevel then
          isLock = false
        end
        skillWidget:SetActive(true)
        skillWidget:FreshSkillIsLock(isLock)
        skillWidget:FreshSkillInfo(skillID, skillLevel)
      else
        UILuaHelper.SetActive(self["m_img_none_after" .. i], true)
        if skillWidget then
          skillWidget:SetActive(false)
        end
      end
    else
      UILuaHelper.SetActive(self["m_img_none_after" .. i], true)
      if skillWidget then
        skillWidget:SetActive(false)
      end
    end
  end
end

function Form_HeroLegacyUpgradeTips:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_HeroLegacyUpgradeTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroLegacyUpgradeTips", Form_HeroLegacyUpgradeTips)
return Form_HeroLegacyUpgradeTips
