local UISubPanelBase = require("UI/Common/UISubPanelBase")
local HeroLegacySubPanel = class("HeroLegacySubPanel", UISubPanelBase)
local SkillIns = ConfigManager:GetConfigInsByName("Skill")
local LegacyLevelIns = ConfigManager:GetConfigInsByName("LegacyLevel")
local AttrBaseShowCfg = _ENV.AttrBaseShowCfg
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local TipsParams = {
  [1] = {
    pivot = {x = 0.5, y = 1},
    offset = {x = 0, y = 0}
  },
  [2] = {
    pivot = {x = 0.5, y = 1},
    offset = {x = 0, y = 0}
  },
  [3] = {
    pivot = {x = 0.5, y = 1},
    offset = {x = 0, y = 0}
  }
}
local PanelInAnimStr = "HeroLegacy_in"

function HeroLegacySubPanel:OnInit()
  self.m_curShowHeroData = nil
  self.m_allHeroList = nil
  self.m_curChooseHeroIndex = nil
  self.m_legacyIconWidgets = {}
  local tempLegacyIcon = self:createLegacySkillIcon(self.m_legacy_skill_item)
  self.m_legacyIconWidgets[1] = tempLegacyIcon
  tempLegacyIcon:SetItemClickBack(function()
    self:OnLegacyIconClk(1)
  end)
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_attr_base_root_trans = self.m_attr_base_root.transform
  self.m_showAttrBaseCfgList = {}
  self.m_showAttrBaseItems = {}
  self:InitShowAttr()
  self:AddEventListeners()
end

function HeroLegacySubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Legacy_UnInstall", handler(self, self.OnLegacyUnInstall))
end

function HeroLegacySubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function HeroLegacySubPanel:OnLegacyUnInstall(param)
  if param.heroID == self.m_curShowHeroData.serverData.iHeroId then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40030)
    self:FreshLegacyData()
    self:FreshUI()
  end
end

function HeroLegacySubPanel:OnFreshData()
  self.m_curShowHeroData = self.m_panelData.heroData
  self.m_allHeroList = self.m_panelData.allHeroList
  self.m_curChooseHeroIndex = self.m_panelData.chooseIndex
  self:FreshLegacyData()
  self:FreshUI()
  self:BindRedDot()
end

function HeroLegacySubPanel:FreshLegacyData()
  self.m_heroServerData = self.m_curShowHeroData.serverData
  self.m_curLegacyID = nil
  self.m_curLegacyData = nil
  self.m_legacySkillDataList = nil
  self.m_legacyLvCfgList = {}
end

function HeroLegacySubPanel:OnActivePanel()
end

function HeroLegacySubPanel:OnHidePanel()
end

function HeroLegacySubPanel:OnDestroy()
  self:RemoveAllEventListeners()
  HeroLegacySubPanel.super.OnDestroy(self)
end

function HeroLegacySubPanel:IsHaveInstallLegacy()
  if not self.m_heroServerData then
    return
  end
  return self.m_heroServerData.stLegacy ~= nil and self.m_heroServerData.stLegacy.iLegacyId ~= 0
end

function HeroLegacySubPanel:FreshLegacyLvList()
  if not self.m_curLegacyID then
    return
  end
  local legacyDic = LegacyLevelIns:GetValue_ByID(self.m_curLegacyID)
  if not legacyDic then
    return
  end
  for _, v in pairs(legacyDic) do
    self.m_legacyLvCfgList[v.m_Level] = v
  end
end

function HeroLegacySubPanel:FreshLegacySkillData()
  self.m_legacySkillDataList = {}
  if not self.m_curLegacyData then
    return
  end
  local legacyCfg = self.m_curLegacyData.legacyCfg
  if not legacyCfg then
    return
  end
  local lv = self.m_curLegacyData.serverData.iLevel
  if not lv then
    return
  end
  local legacyLevelCfg = self.m_legacyLvCfgList[lv]
  for i = 1, LegacyManager.MaxLegacySkillNum do
    local skillID = legacyCfg["m_Skillgroup" .. i]
    if skillID and skillID ~= 0 then
      local skillCfg = SkillIns:GetValue_BySkillID(skillID)
      if skillCfg:GetError() ~= true then
        local isLock = true
        local skillLevel = 0
        if legacyLevelCfg and legacyLevelCfg:GetError() ~= true then
          skillLevel = legacyLevelCfg["m_SkillLevel" .. i]
          if skillLevel and 0 < skillLevel then
            isLock = false
          end
        end
        local tempSkillItem = {
          skillID = skillID,
          skillCfg = skillCfg,
          isLock = isLock,
          skillLv = skillLevel
        }
        self.m_legacySkillDataList[#self.m_legacySkillDataList + 1] = tempSkillItem
      end
    end
  end
end

function HeroLegacySubPanel:InitShowAttr()
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
    local attrNumText = attrItemRoot:Find("c_txt_num"):GetComponent(T_TextMeshProUGUI)
    local attrIconImg = attrItemRoot:Find("c_icon"):GetComponent(T_Image)
    local attrNameText = attrItemRoot:Find("c_txt_sx_name"):GetComponent(T_TextMeshProUGUI)
    local attrItem = {
      itemRoot = attrItemRoot,
      attrNumText = attrNumText,
      attrIconImg = attrIconImg,
      attrNameText = attrNameText,
      propertyCfg = v
    }
    attrNameText.text = v.m_mCNName
    UILuaHelper.SetAtlasSprite(attrIconImg, v.m_PropertyIcon .. "_02")
    self.m_showAttrBaseItems[#self.m_showAttrBaseItems + 1] = attrItem
  end
end

function HeroLegacySubPanel:FreshUI()
  local isInstallLegacy = self:IsHaveInstallLegacy()
  UILuaHelper.SetActive(self.m_pnl_legacy, isInstallLegacy)
  UILuaHelper.SetActive(self.m_img_listnone, not isInstallLegacy)
  if isInstallLegacy then
    local legacyData = self.m_heroServerData.stLegacy
    if not legacyData then
      return
    end
    self.m_curLegacyID = legacyData.iLegacyId
    self.m_curLegacyData = LegacyManager:GetLegacyDataByID(self.m_curLegacyID)
    self:FreshLegacyLvList()
    self:FreshLegacySkillData()
    self:FreshLegacyUI()
  end
  local legacyCount = table.getn(LegacyManager:GetLegacyDataList())
  self.m_btn_go:SetActive(legacyCount == 0)
  self.m_btn_wear:SetActive(legacyCount ~= 0)
end

function HeroLegacySubPanel:FreshLegacyUI()
  if not self.m_heroServerData then
    return
  end
  if not self.m_curLegacyData then
    return
  end
  local legacyCfg = self.m_curLegacyData.legacyCfg
  if not legacyCfg then
    return
  end
  local iconStr = legacyCfg.m_Icon
  self:FreshLegacyIcon(iconStr)
  self:FreshLegacyName(legacyCfg.m_mName)
  self:FreshLegacyLv(self.m_curLegacyData.serverData.iLevel)
  self:FreshLegacySkillShow()
  self:FreshLegacyAttr()
  self:FreshUpgradeStatus()
  self:FreshLegacyUseHeroName()
end

function HeroLegacySubPanel:FreshLegacyIcon(iconStr)
  if not iconStr then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_legacy_icon_Image, iconStr)
end

function HeroLegacySubPanel:FreshLegacyName(nameStr)
  if not nameStr then
    return
  end
  self.m_txt_legacy_name_Text.text = nameStr
end

function HeroLegacySubPanel:FreshLegacyUseHeroName()
  if not self.m_curShowHeroData then
    return
  end
  local tempTextStr = ConfigManager:GetCommonTextById(20110)
  local heroNameStr = self.m_curShowHeroData.characterCfg.m_mName
  self.m_txt_heroname_Text.text = string.CS_Format(tempTextStr, heroNameStr)
end

function HeroLegacySubPanel:FreshLegacyLv(lv)
  if not lv then
    return
  end
  self.m_txt_levelnum_Text.text = lv
end

function HeroLegacySubPanel:FreshLegacySkillShow()
  if not self.m_legacySkillDataList then
    return
  end
  for i = 1, LegacyManager.MaxLegacySkillNum do
    local legacySkillData = self.m_legacySkillDataList[i]
    local legacyIconWidget = self.m_legacyIconWidgets[i]
    UILuaHelper.SetActive(self["m_img_none" .. i], legacySkillData == nil)
    if legacySkillData then
      if legacyIconWidget == nil then
        local newRoot = GameObject.Instantiate(self.m_legacy_skill_item, self["m_legacy_skill" .. i].transform).transform
        legacyIconWidget = self:createLegacySkillIcon(newRoot)
        self.m_legacyIconWidgets[i] = legacyIconWidget
        legacyIconWidget:SetItemClickBack(function()
          self:OnLegacyIconClk(i)
        end)
      end
      legacyIconWidget:FreshSkillInfo(legacySkillData.skillID, legacySkillData.skillLv)
      legacyIconWidget:FreshSkillIsLock(legacySkillData.isLock)
      legacyIconWidget:SetActive(true)
    elseif legacyIconWidget then
      legacyIconWidget:SetActive(false)
    end
  end
end

function HeroLegacySubPanel:FreshLegacyAttr()
  if not self.m_showAttrBaseItems then
    return
  end
  local legacyAttrTab = self.m_heroAttr:GetLegacyAttr(self.m_curLegacyID, self.m_curLegacyData.serverData.iLevel)
  for _, attrItem in ipairs(self.m_showAttrBaseItems) do
    local serverAttrValue = legacyAttrTab[attrItem.propertyCfg.m_ENName] or 0
    attrItem.attrNumText.text = BigNumFormat(serverAttrValue)
  end
end

function HeroLegacySubPanel:FreshUpgradeStatus()
  local lv = self.m_curLegacyData.serverData.iLevel
  local isMax = lv >= #self.m_legacyLvCfgList
  UILuaHelper.SetActive(self.m_node_max_lv, isMax)
  UILuaHelper.SetActive(self.m_btn_levelup, not isMax)
end

function HeroLegacySubPanel:ShowEnterInAnim()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, PanelInAnimStr)
end

function HeroLegacySubPanel:ShowTabInAnim()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, PanelInAnimStr)
end

function HeroLegacySubPanel:BindRedDot()
  if not self.m_curShowHeroData then
    return
  end
  if self.m_curLegacyData then
    self:RegisterOrUpdateRedDotItem(self.m_legacy_upgrade_redpoint, RedDotDefine.ModuleType.LegacyUp, self.m_curLegacyID)
  else
    self:RegisterOrUpdateRedDotItem(self.m_wear_red_dot, RedDotDefine.ModuleType.HeroLegacyWare)
  end
end

function HeroLegacySubPanel:OnLegacyIconClk(skillIndex)
  if not skillIndex then
    return
  end
  local legacySkillData = self.m_legacySkillDataList[skillIndex]
  if not legacySkillData then
    return
  end
  local skillWid = self.m_legacyIconWidgets[skillIndex]
  if not skillWid then
    return
  end
  local showParam = TipsParams[skillIndex]
  local rootTrans = skillWid:GetRootTrans()
  utils.openLegacySkillTips(self.m_curLegacyID, self.m_curLegacyData.serverData.iLevel, legacySkillData.skillID, rootTrans, showParam.pivot, showParam.offset)
end

function HeroLegacySubPanel:OnBtnlevelupClicked()
  if not self.m_curLegacyData then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_HEROLEGACYUPGRADE, {
    legacyData = self.m_curLegacyData
  })
end

function HeroLegacySubPanel:OnBtnchangeClicked()
  if not self.m_curLegacyData then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_HEROLEGACYMANAGE, {
    heroData = self.m_curShowHeroData,
    legacyData = self.m_curLegacyData
  })
end

function HeroLegacySubPanel:OnBtnrelieveClicked()
  if not self.m_curLegacyData then
    return
  end
  LegacyManager:ReqLegacyUninstall(self.m_curShowHeroData.serverData.iHeroId)
end

function HeroLegacySubPanel:OnBtnwearClicked()
  if self.m_curLegacyData then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_HEROLEGACYMANAGE, {
    heroData = self.m_curShowHeroData
  })
end

function HeroLegacySubPanel:OnBtngoClicked()
  QuickOpenFuncUtil:OpenFunc(1903)
  self:broadcastEvent("eGameEvent_Hero_Jump")
end

function HeroLegacySubPanel:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  return vPackage, vResourceExtra
end

return HeroLegacySubPanel
