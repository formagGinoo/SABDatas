local Form_HeroLegacyUpgrade = class("Form_HeroLegacyUpgrade", require("UI/UIFrames/Form_HeroLegacyUpgradeUI"))
local SkillIns = ConfigManager:GetConfigInsByName("Skill")
local LegacyLevelIns = ConfigManager:GetConfigInsByName("LegacyLevel")
local AttrBaseShowCfg = _ENV.AttrBaseShowCfg
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local MaxLegacySkillNum = LegacyManager.MaxLegacySkillNum

function Form_HeroLegacyUpgrade:SetInitParam(param)
end

function Form_HeroLegacyUpgrade:AfterInit()
  self.super.AfterInit(self)
  self.m_curLegacyData = nil
  self.m_curLegacyCfg = nil
  self.m_curLegacyID = nil
  self.m_beforeLv = nil
  self.m_afterLv = nil
  self.m_beforeLegacyLvCfg = nil
  self.m_afterLegacyLvCfg = nil
  self.m_legacyLvCfgList = {}
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_attr_base_root_trans = self.m_attr_base_root.transform
  self.m_showAttrBaseCfgList = {}
  self.m_showAttrBaseItems = {}
  self:InitShowAttr()
  self:InitCostItem()
  self.m_beforeLegacySkillWidgets = {}
  local tempLegacyIcon = self:createLegacySkillIcon(self.m_legacy_skill_item)
  self.m_beforeLegacySkillWidgets[1] = tempLegacyIcon
  self.m_afterLegacySkillWidgets = {}
  self.m_isItemEnough = false
end

function Form_HeroLegacyUpgrade:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_HeroLegacyUpgrade:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_HeroLegacyUpgrade:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroLegacyUpgrade:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curLegacyData = tParam.legacyData
    self.m_curLegacyID = self.m_curLegacyData.serverData.iLegacyId
    self.m_curLegacyCfg = self.m_curLegacyData.legacyCfg
    self:FreshLegacyLvList()
    self.m_csui.m_param = nil
  end
end

function Form_HeroLegacyUpgrade:FreshLegacyLvList()
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

function Form_HeroLegacyUpgrade:ClearData()
end

function Form_HeroLegacyUpgrade:ClearCacheData()
end

function Form_HeroLegacyUpgrade:AddEventListeners()
  self:addEventListener("eGameEvent_Legacy_Upgrade", handler(self, self.OnLegacyUpgrade))
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnItemJump))
end

function Form_HeroLegacyUpgrade:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroLegacyUpgrade:OnLegacyUpgrade(param)
  if param.legacyID == self.m_curLegacyID then
    StackPopup:Push(UIDefines.ID_FORM_HEROLEGACYUPGRADETIPS, {
      legacyData = self.m_curLegacyData
    })
    if self.m_afterLv >= #self.m_legacyLvCfgList then
      self:OnBtnCloseClicked()
    else
      self:FreshUI()
    end
  end
end

function Form_HeroLegacyUpgrade:OnItemJump()
  self:CloseForm()
end

function Form_HeroLegacyUpgrade:InitShowAttr()
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

function Form_HeroLegacyUpgrade:FreshUI()
  self.m_beforeLv = self.m_curLegacyData.serverData.iLevel
  self.m_afterLv = self.m_beforeLv >= #self.m_legacyLvCfgList and self.m_beforeLv or self.m_beforeLv + 1
  self.m_beforeLegacyLvCfg = self.m_legacyLvCfgList[self.m_beforeLv]
  self.m_afterLegacyLvCfg = self.m_legacyLvCfgList[self.m_afterLv]
  self:FreshLegacyBaseInfo()
  self:FreshLvChange()
  self:FreshPersonNumChange()
  self:FreshLegacyAttrChange()
  self:FreshCostItems()
  self:FreshBeforeSkillStatus()
  self:FreshAfterSkillStatus()
  self:FreshItemsShow()
  self:FreshUpgradeBtn()
end

function Form_HeroLegacyUpgrade:FreshLegacyBaseInfo()
  if not self.m_curLegacyCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_legacy_icon_Image, self.m_curLegacyCfg.m_Icon)
  self.m_txt_legacy_name_Text.text = self.m_curLegacyCfg.m_mName
end

function Form_HeroLegacyUpgrade:FreshLvChange()
  if not self.m_curLegacyData then
    return
  end
  self.m_txt_num_before_Text.text = self.m_beforeLv
  self.m_txt_num_after_Text.text = self.m_afterLv
end

function Form_HeroLegacyUpgrade:FreshPersonNumChange()
  if not self.m_beforeLegacyLvCfg then
    return
  end
  if not self.m_afterLegacyLvCfg then
    return
  end
  self.m_txt_person_before_Text.text = self.m_beforeLegacyLvCfg.m_Wearable
  self.m_txt_person_after_Text.text = self.m_afterLegacyLvCfg.m_Wearable
end

function Form_HeroLegacyUpgrade:FreshLegacyAttrChange()
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

function Form_HeroLegacyUpgrade:InitCostItem()
  self.m_ItemWidgetList = {}
  self.m_cost_item_root_trans = self.m_cost_item_root.transform
  self.m_rewardItemBase = self.m_cost_item_root_trans:Find("c_common_item")
  self.m_rewardItemBase.name = self.m_rewardItemBase.name .. 1
  local itemWidget = self:createCommonItem(self.m_rewardItemBase.gameObject)
  self.m_ItemWidgetList[#self.m_ItemWidgetList + 1] = itemWidget
  itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnCosetItemClk(itemID, itemNum, itemCom)
  end)
end

function Form_HeroLegacyUpgrade:FreshCostItems()
  if not self.m_beforeLegacyLvCfg then
    return
  end
  self:FreshItemsShow(self.m_beforeLegacyLvCfg.m_ItemCost)
end

function Form_HeroLegacyUpgrade:FreshItemsShow(rewardArray)
  if not rewardArray then
    return
  end
  if not rewardArray or rewardArray.Length <= 0 then
    UILuaHelper.SetActive(self.m_cost_node, false)
    return
  end
  UILuaHelper.SetActive(self.m_cost_node, true)
  local itemWidgets = self.m_ItemWidgetList
  local dataLen = rewardArray.Length
  local parentTrans = self.m_cost_item_root_trans
  local isEnough = true
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemWidget = itemWidgets[i]
      local itemArray = rewardArray[i - 1]
      local itemID = tonumber(itemArray[0])
      local needNum = tonumber(itemArray[1])
      local processItemData = ResourceUtil:GetProcessRewardData({iID = itemID, iNum = 0})
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetActive(true)
      local curHaveNum = ItemManager:GetItemNum(itemID, true) or 0
      itemWidget:SetNeedNum(needNum, curHaveNum)
      if needNum > curHaveNum then
        isEnough = false
      end
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_rewardItemBase, parentTrans).gameObject
      itemObj.name = self.m_rewardItemBase.name .. i
      local itemWidget = self:createCommonItem(itemObj)
      local itemArray = rewardArray[i - 1]
      local itemID = tonumber(itemArray[0])
      local needNum = tonumber(itemArray[1])
      local processItemData = ResourceUtil:GetProcessRewardData({iID = itemID, iNum = 0})
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetItemIconClickCB(function(paramItemID, itemNum, itemCom)
        self:OnCosetItemClk(paramItemID, itemNum, itemCom)
      end)
      itemWidgets[#itemWidgets + 1] = itemWidget
      itemWidget:SetActive(true)
      local curHaveNum = ItemManager:GetItemNum(itemID, true) or 0
      itemWidget:SetNeedNum(needNum, curHaveNum)
      if needNum > curHaveNum then
        isEnough = false
      end
    elseif i <= childCount and i > dataLen then
      itemWidgets[i]:SetActive(false)
    end
  end
  self.m_isItemEnough = isEnough
end

function Form_HeroLegacyUpgrade:FreshBeforeSkillStatus()
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

function Form_HeroLegacyUpgrade:FreshAfterSkillStatus()
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

function Form_HeroLegacyUpgrade:FreshUpgradeBtn()
  UILuaHelper.SetActive(self.m_btn_Upgrade, self.m_isItemEnough)
  UILuaHelper.SetActive(self.m_btn_UpgradeGray, not self.m_isItemEnough)
end

function Form_HeroLegacyUpgrade:OnCosetItemClk(itemID, itemNum, itemCom)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_HeroLegacyUpgrade:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_HeroLegacyUpgrade:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_HeroLegacyUpgrade:OnBtnUpgradeClicked()
  if self.m_beforeLv >= #self.m_legacyLvCfgList then
    return
  end
  if not self.m_isItemEnough then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30004)
    return
  end
  LegacyManager:ReqLegacyUpgrade(self.m_curLegacyID)
end

function Form_HeroLegacyUpgrade:OnBtnUpgradeGrayClicked()
  if not self.m_isItemEnough then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30004)
  end
end

function Form_HeroLegacyUpgrade:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroLegacyUpgrade", Form_HeroLegacyUpgrade)
return Form_HeroLegacyUpgrade
