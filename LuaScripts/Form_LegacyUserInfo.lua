local Form_LegacyUserInfo = class("Form_LegacyUserInfo", require("UI/UIFrames/Form_LegacyUserInfoUI"))
local SkillIns = ConfigManager:GetConfigInsByName("Skill")
local LegacyLevelIns = ConfigManager:GetConfigInsByName("LegacyLevel")
local AttrBaseShowCfg = _ENV.AttrBaseShowCfg
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local MaxLegacySkillNum = LegacyManager.MaxLegacySkillNum

function Form_LegacyUserInfo:SetInitParam(param)
end

function Form_LegacyUserInfo:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1169)
  local resourceBarRoot = self.m_rootTrans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self.m_legacyCfgList = nil
  self.m_curShowLegacyIndex = nil
  self.m_curLegacyCfg = nil
  self.m_heroWidgetList = {}
  local firstWidget = self:createHeroIcon(self.m_hero_item)
  self.m_heroWidgetList[#self.m_heroWidgetList + 1] = firstWidget
  self:InitHeroWidgetList()
  self.m_curLegacyData = nil
  self.m_curLegacyID = nil
  self.m_curLegacyLv = nil
  self.m_legacySkillDataList = {}
  self.m_curLegacyLvCfg = nil
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_attr_base_root_trans = self.m_attr_base_root.transform
  self.m_showAttrBaseCfgList = {}
  self.m_showAttrBaseItems = {}
  self:InitShowAttr()
  self.m_legacyIconWidgets = {}
  local tempLegacyIcon = self:createLegacySkillIcon(self.m_legacy_skill_item)
  self.m_legacyIconWidgets[1] = tempLegacyIcon
  tempLegacyIcon:SetItemClickBack(function()
    self:OnLegacySkillIconClk(1)
  end)
  self.m_legacyHeroPosDataList = nil
end

function Form_LegacyUserInfo:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(33)
end

function Form_LegacyUserInfo:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_LegacyUserInfo:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_LegacyUserInfo:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_legacyCfgList = tParam.legacyCfgList
    self.m_curShowLegacyIndex = tParam.legacyIndex
    self.m_csui.m_param = nil
  end
end

function Form_LegacyUserInfo:ClearCacheData()
end

function Form_LegacyUserInfo:FreshChangeLegacyData()
  if not self.m_curShowLegacyIndex then
    return
  end
  local tempLegacyCfg = self.m_legacyCfgList[self.m_curShowLegacyIndex]
  if not tempLegacyCfg then
    return
  end
  self.m_curLegacyCfg = tempLegacyCfg
  self.m_curLegacyID = tempLegacyCfg.m_ID
  self.m_curLegacyData = LegacyManager:GetLegacyDataByID(self.m_curLegacyID)
  if not self.m_curLegacyData then
    return
  end
  self.m_curLegacyLv = self.m_curLegacyData.serverData.iLevel
  self.m_curLegacyLvCfg = LegacyLevelIns:GetValue_ByIDAndLevel(self.m_curLegacyID, self.m_curLegacyLv)
  self:FreshLegacySkillData()
  self:FreshLegacyHeroPosDataList()
  self:CheckSetLegacyEnterStatus()
end

function Form_LegacyUserInfo:FreshLegacySkillData()
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
  local legacyLevelCfg = self.m_curLegacyLvCfg
  for i = 1, MaxLegacySkillNum do
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

function Form_LegacyUserInfo:FreshLegacyHeroPosDataList()
  if not self.m_curLegacyData then
    return
  end
  self.m_legacyHeroPosDataList = {}
  local heroIDList = self.m_curLegacyData.serverData.vEquipBy or {}
  local legacyLvCfgDic = LegacyLevelIns:GetValue_ByID(self.m_curLegacyID)
  if legacyLvCfgDic then
    for _, tempLegacyLvCfg in pairs(legacyLvCfgDic) do
      local wearableNum = tempLegacyLvCfg.m_Wearable
      local heroData = HeroManager:GetHeroDataByID(heroIDList[wearableNum])
      local tempHeroPosData
      if self.m_legacyHeroPosDataList[wearableNum] == nil then
        tempHeroPosData = {
          legacyLvCfg = tempLegacyLvCfg,
          legacyLv = tempLegacyLvCfg.m_Level,
          heroData = heroData,
          isOpen = self.m_curLegacyLv >= tempLegacyLvCfg.m_Level
        }
        self.m_legacyHeroPosDataList[wearableNum] = tempHeroPosData
      else
        tempHeroPosData = self.m_legacyHeroPosDataList[wearableNum]
        if tempLegacyLvCfg.m_Level < tempHeroPosData.legacyLv then
          tempHeroPosData.legacyLvCfg = tempLegacyLvCfg
          tempHeroPosData.legacyLv = tempLegacyLvCfg.m_Level
          tempHeroPosData.isOpen = self.m_curLegacyLv >= tempLegacyLvCfg.m_Level
        end
      end
    end
  end
end

function Form_LegacyUserInfo:CheckSetLegacyEnterStatus()
  if not self.m_curLegacyData then
    return
  end
  LegacyManager:SetLegacyEnter(self.m_curLegacyID)
end

function Form_LegacyUserInfo:AddEventListeners()
  self:addEventListener("eGameEvent_Legacy_Upgrade", handler(self, self.OnLegacyUpgrade))
  self:addEventListener("eGameEvent_Legacy_InstallBatch", handler(self, self.OnInstallBatchBack))
end

function Form_LegacyUserInfo:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_LegacyUserInfo:OnLegacyUpgrade(param)
  if param.legacyID == self.m_curLegacyID then
    self:FreshChangeLegacyData()
    self:FreshShowLegacyShow()
  end
end

function Form_LegacyUserInfo:OnInstallBatchBack(param)
  if not param then
    return
  end
  local legacyID = param.legacyID
  if legacyID == self.m_curLegacyID then
    self:FreshChangeLegacyData()
    self:FreshShowLegacyShow()
  end
end

function Form_LegacyUserInfo:InitHeroWidgetList()
  for i = 2, LegacyManager.MaxLegacyHeroPos do
    local tempHeroNode = GameObject.Instantiate(self.m_hero_item, self["m_hero_pos" .. i].transform).gameObject
    local tempHeroIcon = self:createHeroIcon(tempHeroNode)
    self.m_heroWidgetList[#self.m_heroWidgetList + 1] = tempHeroIcon
  end
end

function Form_LegacyUserInfo:InitShowAttr()
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

function Form_LegacyUserInfo:FreshUI()
  self:FreshChangeLegacyData()
  self:FreshShowLegacyShow()
end

function Form_LegacyUserInfo:FreshShowLegacyShow()
  if not self.m_curLegacyData then
    return
  end
  self:FreshLegacyBaseInfo()
  self:FreshLegacySkillShow()
  self:FreshLegacyAttr()
  self:FreshHeroPosShow()
  self:FreshLegacyUpgradeShow()
end

function Form_LegacyUserInfo:FreshLegacyBaseInfo()
  if not self.m_curLegacyCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_legacy_icon_Image, self.m_curLegacyCfg.m_Icon)
  self.m_txt_legacy_name_Text.text = self.m_curLegacyCfg.m_mName
  self.m_txt_levelnum_Text.text = string.format(ConfigManager:GetCommonTextById(20033), self.m_curLegacyLv)
end

function Form_LegacyUserInfo:FreshLegacySkillShow()
  if not self.m_legacySkillDataList then
    return
  end
  for i = 1, LegacyManager.MaxLegacySkillNum do
    local legacySkillData = self.m_legacySkillDataList[i]
    local legacyIconWidget = self.m_legacyIconWidgets[i]
    UILuaHelper.SetActive(self["m_img_skill_none" .. i], legacySkillData == nil)
    if legacySkillData then
      if legacyIconWidget == nil then
        local newRoot = GameObject.Instantiate(self.m_legacy_skill_item, self["m_legacy_skill" .. i].transform).transform
        legacyIconWidget = self:createLegacySkillIcon(newRoot)
        self.m_legacyIconWidgets[i] = legacyIconWidget
        legacyIconWidget:SetItemClickBack(function()
          self:OnLegacySkillIconClk(i)
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

function Form_LegacyUserInfo:FreshLegacyAttr()
  if not self.m_showAttrBaseItems then
    return
  end
  local legacyAttrTab = self.m_heroAttr:GetLegacyAttr(self.m_curLegacyID, self.m_curLegacyData.serverData.iLevel)
  for _, attrItem in ipairs(self.m_showAttrBaseItems) do
    local serverAttrValue = legacyAttrTab[attrItem.propertyCfg.m_ENName] or 0
    attrItem.attrNumText.text = BigNumFormat(serverAttrValue)
  end
end

function Form_LegacyUserInfo:FreshHeroPosShow()
  if not self.m_legacyHeroPosDataList then
    return
  end
  for i = 1, LegacyManager.MaxLegacyHeroPos do
    local tempHeroPosData = self.m_legacyHeroPosDataList[i]
    UILuaHelper.SetActive(self["m_item" .. i], tempHeroPosData ~= nil)
    if tempHeroPosData then
      local isHaveUser = tempHeroPosData.heroData ~= nil
      local isOpen = tempHeroPosData.isOpen
      UILuaHelper.SetActive(self["m_hero_pos" .. i], isOpen and isHaveUser)
      UILuaHelper.SetActive(self["m_img_add" .. i], isOpen and not isHaveUser)
      UILuaHelper.SetActive(self["m_img_lock" .. i], not isOpen)
      self["m_lock_num" .. i .. "_Text"].text = string.format(ConfigManager:GetCommonTextById(20033), tempHeroPosData.legacyLv)
      if isHaveUser then
        self.m_heroWidgetList[i]:SetHeroData(tempHeroPosData.heroData.serverData)
      end
    end
  end
end

function Form_LegacyUserInfo:FreshLegacyUpgradeShow()
  if not self.m_curLegacyLvCfg then
    return
  end
  local itemCostArray = self.m_curLegacyLvCfg.m_ItemCost
  local isMax = false
  if itemCostArray and itemCostArray.Length == 0 then
    isMax = true
  end
  UILuaHelper.SetActive(self.m_btn_upgrade, not isMax)
  UILuaHelper.SetActive(self.m_node_upgrade_max, isMax)
end

function Form_LegacyUserInfo:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_LegacyUserInfo:OnHeroPosClk(index)
  if not index then
    return
  end
  local legacyPoseHeroData = self.m_legacyHeroPosDataList[index]
  if not legacyPoseHeroData then
    return
  end
  local isOpen = legacyPoseHeroData.isOpen
  if isOpen then
    CS.GlobalManager.Instance:TriggerWwiseBGMState(37)
    StackFlow:Push(UIDefines.ID_FORM_LEGACYCHANGEUSER, {
      legacyData = self.m_curLegacyData
    })
  else
    CS.GlobalManager.Instance:TriggerWwiseBGMState(3)
    local commonTextStr = ConfigManager:GetCommonTextById(100506)
    local showStr = string.CS_Format(commonTextStr, legacyPoseHeroData.legacyLv)
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, showStr)
  end
end

function Form_LegacyUserInfo:OnBtntouchitem1Clicked()
  self:OnHeroPosClk(1)
end

function Form_LegacyUserInfo:OnBtntouchitem2Clicked()
  self:OnHeroPosClk(2)
end

function Form_LegacyUserInfo:OnBtntouchitem3Clicked()
  self:OnHeroPosClk(3)
end

function Form_LegacyUserInfo:OnBtntouchitem4Clicked()
  self:OnHeroPosClk(4)
end

function Form_LegacyUserInfo:OnBtntouchitem5Clicked()
  self:OnHeroPosClk(5)
end

function Form_LegacyUserInfo:OnBtntouchitem6Clicked()
  self:OnHeroPosClk(6)
end

function Form_LegacyUserInfo:OnLegacySkillIconClk(index)
  if not index then
    return
  end
  local legacySkillData = self.m_legacySkillDataList[index]
  if not legacySkillData then
    return
  end
  local skillWid = self.m_legacyIconWidgets[index]
  if not skillWid then
    return
  end
  local rootTrans = skillWid:GetRootTrans()
  utils.openLegacySkillTips(self.m_curLegacyID, self.m_curLegacyLv, legacySkillData.skillID, rootTrans, {x = 0, y = 0.5}, {x = -5, y = 0})
  CS.GlobalManager.Instance:TriggerWwiseBGMState(37)
end

function Form_LegacyUserInfo:OnBtnLastClicked()
  if not self.m_curShowLegacyIndex then
    return
  end
  local tempIndex = self.m_curShowLegacyIndex - 1
  if tempIndex <= 0 then
    tempIndex = #self.m_legacyCfgList
  end
  if tempIndex == self.m_curShowLegacyIndex then
    return
  end
  self.m_curShowLegacyIndex = tempIndex
  self:FreshChangeLegacyData()
  self:FreshShowLegacyShow()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(32)
end

function Form_LegacyUserInfo:OnBtnNextClicked()
  if not self.m_curShowLegacyIndex then
    return
  end
  local tempIndex = self.m_curShowLegacyIndex + 1
  if tempIndex > #self.m_legacyCfgList then
    tempIndex = 1
  end
  if tempIndex == self.m_curShowLegacyIndex then
    return
  end
  self.m_curShowLegacyIndex = tempIndex
  self:FreshChangeLegacyData()
  self:FreshShowLegacyShow()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(32)
end

function Form_LegacyUserInfo:OnBtnupgradeClicked()
  if not self.m_curShowLegacyIndex then
    return
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(36)
  StackFlow:Push(UIDefines.ID_FORM_HEROLEGACYUPGRADE, {
    legacyData = self.m_curLegacyData
  })
end

function Form_LegacyUserInfo:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_LegacyUserInfo", Form_LegacyUserInfo)
return Form_LegacyUserInfo
