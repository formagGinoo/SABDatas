local Form_CirculationPop = class("Form_CirculationPop", require("UI/UIFrames/Form_CirculationPopUI"))
local CirculationTypeIns = ConfigManager:GetConfigInsByName("CirculationType")
local CirculationLevelIns = ConfigManager:GetConfigInsByName("CirculationLevel")
local EquipTypeCfgIns = ConfigManager:GetConfigInsByName("EquipType")
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
local MaxAttrNum = 2
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")

function Form_CirculationPop:SetInitParam(param)
end

function Form_CirculationPop:AfterInit()
  self.super.AfterInit(self)
  self.m_curCirculationID = nil
  self.m_isNeedBackCirculation = nil
  self.m_curCirculationCfg = nil
  self.m_curCirculationTypeCfg = nil
  self.m_curRootLv = nil
  self.m_circulationLevelCfgDic = {}
  self.m_circulationLevelCfgMaxID = 0
  self.m_curServerLv = 0
  self.m_curServerExpNum = 0
  self.m_canUpMaxLv = 0
  self.m_canAddMaxExpNum = 0
  self.m_conditionUnlockStr = nil
  self.m_afterLv = 0
  self.m_afterExpNum = 0
  self.m_addExpNum = 0
  self.m_costItemID = 0
  self.m_curHaveItemNum = 0
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_costItemWidget = nil
  self.m_isUpUnlock = nil
  self.m_unlockTips = nil
end

function Form_CirculationPop:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_CirculationPop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_CirculationPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CirculationPop:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curCirculationID = tParam.circulationID
    self.m_isNeedBackCirculation = tParam.isNeedBackCirculation
    self.m_csui.m_param = nil
  end
end

function Form_CirculationPop:FreshCirculationLevelList()
  if not self.m_curCirculationID then
    return
  end
  local circulationCfgDic = CirculationLevelIns:GetValue_ByCirculationType(self.m_curCirculationID)
  if not circulationCfgDic then
    return
  end
  local circulationLevelCfgDic = {}
  local tempNum = 0
  for _, tempCfg in pairs(circulationCfgDic) do
    circulationLevelCfgDic[tempCfg.m_Level] = tempCfg
    tempNum = tempNum + 1
  end
  self.m_circulationLevelCfgDic = circulationCfgDic
  self.m_circulationLevelCfgMaxID = tempNum - 1
end

function Form_CirculationPop:GetCanUpMaxLv()
  if not self.m_curCirculationID then
    return
  end
  local conditionNum, unlockMessageStr
  if self.m_curCirculationID == HeroManager.CirculationRootID then
    conditionNum = InheritManager:GetInheritLevel()
    unlockMessageStr = ConfigManager:GetClientMessageTextById(12001)
  else
    conditionNum = self.m_curRootLv
    unlockMessageStr = ConfigManager:GetClientMessageTextById(12003)
  end
  local addExpNum = 0
  local maxLv = 0
  local endIndex = self.m_circulationLevelCfgMaxID
  for i = self.m_curServerLv, endIndex do
    local circulationCfg = self.m_circulationLevelCfgDic[i]
    local isCanUp = true
    if circulationCfg and circulationCfg.m_SynchronizeLevel and 0 < circulationCfg.m_SynchronizeLevel and conditionNum < circulationCfg.m_SynchronizeLevel then
      isCanUp = false
      unlockMessageStr = string.CS_Format(unlockMessageStr, circulationCfg.m_SynchronizeLevel)
    end
    maxLv = i
    if isCanUp ~= true then
      break
    end
    if i == self.m_curServerLv then
      addExpNum = addExpNum + (circulationCfg.m_Exp - self.m_curServerExpNum)
    else
      addExpNum = addExpNum + circulationCfg.m_Exp
    end
    if addExpNum > self.m_curHaveItemNum then
      addExpNum = self.m_curHaveItemNum
      break
    end
  end
  return maxLv, addExpNum, unlockMessageStr
end

function Form_CirculationPop:IsCirculationLock()
  if not self.m_curCirculationID then
    return
  end
  local circulationCfg = self.m_circulationLevelCfgDic[self.m_curServerLv]
  if not circulationCfg then
    return
  end
  if circulationCfg.m_SynchronizeLevel <= 0 then
    return
  end
  local conditionNum
  if self.m_curCirculationID == HeroManager.CirculationRootID then
    conditionNum = InheritManager:GetInheritLevel()
  else
    conditionNum = self.m_curRootLv
  end
  if conditionNum < circulationCfg.m_SynchronizeLevel then
    local conditionTips
    if self.m_curCirculationID == HeroManager.CirculationRootID then
      conditionTips = string.CS_Format(ConfigManager:GetCommonTextById(100047), circulationCfg.m_SynchronizeLevel)
    else
      conditionTips = string.CS_Format(ConfigManager:GetCommonTextById(100046), circulationCfg.m_SynchronizeLevel)
    end
    return true, conditionTips
  end
end

function Form_CirculationPop:GetAfterLvAndExpNum()
  local addExpNum = self.m_addExpNum + self.m_curServerExpNum
  local endIndex = self.m_circulationLevelCfgMaxID
  local lv, tempExp
  for i = self.m_curServerLv, endIndex do
    local circulationCfg = self.m_circulationLevelCfgDic[i]
    tempExp = addExpNum
    addExpNum = addExpNum - circulationCfg.m_Exp
    lv = i
    if addExpNum < 0 then
      break
    end
  end
  if lv == endIndex then
    tempExp = 0
  end
  return lv, tempExp
end

function Form_CirculationPop:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_CirculationUpgrade", handler(self, self.OnUpgradeBack))
end

function Form_CirculationPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CirculationPop:OnUpgradeBack(circulationItem)
  if circulationItem.iTypeID == self.m_curCirculationID then
    local lastServerLv = self.m_curServerLv
    local newLv = circulationItem.iLevel
    if lastServerLv ~= newLv then
      StackPopup:Push(UIDefines.ID_FORM_CIRCULATIONUPGRADETIPS, {
        lastLv = lastServerLv,
        newLv = newLv,
        circulationID = self.m_curCirculationID
      })
    end
    self:FreshUI()
  end
end

function Form_CirculationPop:FreshUI()
  if not self.m_curCirculationID then
    return
  end
  local circulationTypeCfg = CirculationTypeIns:GetValue_ByCirculationTypeID(self.m_curCirculationID)
  if circulationTypeCfg:GetError() then
    return
  end
  self.m_curCirculationTypeCfg = circulationTypeCfg
  self.m_curRootLv = HeroManager:GetCirculationLvByID(HeroManager.CirculationRootID)
  self.m_curServerLv = HeroManager:GetCirculationLvByID(self.m_curCirculationID)
  self.m_curServerExpNum = HeroManager:GetCirculationExpByID(self.m_curCirculationID)
  self:FreshCirculationLevelList()
  self.m_curCirculationCfg = self.m_circulationLevelCfgDic[self.m_curServerLv]
  self.m_costItemID = self.m_curCirculationCfg.m_ItemID
  self.m_curHaveItemNum = ItemManager:GetItemNum(self.m_costItemID)
  self.m_canUpMaxLv, self.m_canAddMaxExpNum, self.m_conditionUnlockStr = self:GetCanUpMaxLv()
  self.m_afterLv = self.m_curServerLv
  self.m_afterExpNum = self.m_curServerExpNum
  self.m_addExpNum = 0
  self.m_isUpUnlock, self.m_unlockTips = self:IsCirculationLock()
  self:InitCostItem()
  self:FreshBaseInfo()
  self:FreshLevelShow()
  self:FreshExpBarShow()
  self:FreshAttrShow()
  self:FreshItemCostNum()
  self:FreshUseItemNum()
  self:FreshButtonShow()
end

function Form_CirculationPop:InitCostItem()
  local itemWidget = self:createCommonItem(self.m_common_item)
  local processItemData = ResourceUtil:GetProcessRewardData({
    iID = self.m_costItemID,
    iNum = self.m_curHaveItemNum
  })
  itemWidget:SetItemInfo(processItemData)
  itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnCostItemClk(itemID, itemNum, itemCom)
  end)
  itemWidget:SetItemDelClickCB(function(itemID, itemNum, itemCom)
    self:OnCostItemDelClk(itemID, itemNum, itemCom)
  end)
  self.m_costItemWidget = itemWidget
end

function Form_CirculationPop:FreshBaseInfo()
  if not self.m_curCirculationTypeCfg then
    return
  end
  self.m_txt_campname_Text.text = self.m_curCirculationTypeCfg.m_mCirculationName
  self.m_txt_longdesc_Text.text = self.m_curCirculationTypeCfg.m_mValueDesc
  local type = self.m_curCirculationTypeCfg.m_CirculationType
  local iconPath
  if type == HeroManager.CirculationType.Root then
    iconPath = ConfigManager:GetGlobalSettingsByKey("CirculationOriginIcon")
  elseif type == HeroManager.CirculationType.Equip then
    local stItemData = EquipTypeCfgIns:GetValue_ByEquiptypeID(self.m_curCirculationTypeCfg.m_EquipTypeID)
    if not stItemData:GetError() then
      iconPath = stItemData.m_CirculationIcon
    end
  elseif type == HeroManager.CirculationType.Camp then
    local campCfg = CampCfgIns:GetValue_ByCampID(self.m_curCirculationTypeCfg.m_CharacterCampID)
    if not campCfg:GetError() then
      iconPath = campCfg.m_CirculationIcon
    end
  end
  if iconPath then
    UILuaHelper.SetAtlasSprite(self.m_camp_icon_Image, iconPath, nil, nil, true)
  end
end

function Form_CirculationPop:FreshLevelShow()
  local isMax = self.m_curServerLv >= self.m_circulationLevelCfgMaxID
  self.m_txt_lv_before_Text.text = self.m_curServerLv
  UILuaHelper.SetActive(self.m_txt_lv_after_Text, not isMax)
  self.m_txt_lv_after_Text.text = self.m_afterLv
end

function Form_CirculationPop:FreshExpBarShow()
  local nextCirculationCfg = self.m_circulationLevelCfgDic[self.m_afterLv]
  local afterMaxExp = nextCirculationCfg.m_Exp
  local nextPercent = self.m_afterExpNum / afterMaxExp
  self.m_img_bar_preview_Image.fillAmount = nextPercent
  UILuaHelper.SetActive(self.m_img_bar, self.m_curServerLv == self.m_afterLv)
  if self.m_curServerLv == self.m_afterLv then
    local expMaxNum = self.m_curCirculationCfg.m_Exp
    local curExp = self.m_curServerExpNum
    local curPercent = curExp / expMaxNum
    self.m_img_bar_Image.fillAmount = curPercent
  end
  self.m_txt_exp_num_Text.text = string.format("%d/%d", self.m_afterExpNum, afterMaxExp)
end

function Form_CirculationPop:FreshItemCostNum()
  if not self.m_costItemWidget then
    return
  end
  self.m_curHaveItemNum = ItemManager:GetItemNum(self.m_costItemID)
  UILuaHelper.SetActive(self.m_txt_num0, self.m_curHaveItemNum == 0)
  self.m_costItemWidget:RefreshNum(self.m_curHaveItemNum)
end

function Form_CirculationPop:FreshUseItemNum()
  if not self.m_costItemWidget then
    return
  end
  self.m_costItemWidget:SetUpGradeNum(self.m_addExpNum)
end

function Form_CirculationPop:FreshAttrShow()
  local beforeAttrTab = self.m_heroAttr:GetCirculationBaseAttr(self.m_curCirculationID, self.m_curServerLv)
  local afterAttrTab
  if self.m_curServerLv ~= self.m_afterLv then
    afterAttrTab = self.m_heroAttr:GetCirculationBaseAttr(self.m_curCirculationID, self.m_afterLv)
  end
  local propertyIDArray = self.m_curCirculationTypeCfg.m_PropertyIndexID
  local propertyIDLen = propertyIDArray.Length
  for i = 1, MaxAttrNum do
    if i <= propertyIDLen then
      UILuaHelper.SetActive(self["m_attr" .. i], true)
      local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(propertyIDArray[i - 1])
      self[string.format("m_txt_attr_name%d_Text", i)].text = propertyIndexCfg.m_mCNName
      UILuaHelper.SetAtlasSprite(self[string.format("m_img_icon%d_Image", i)], propertyIndexCfg.m_PropertyIcon .. "_02")
      local paramStr = propertyIndexCfg.m_ENName
      self[string.format("m_txt_attr_before%d_Text", i)].text = BigNumFormat(beforeAttrTab[paramStr])
      UILuaHelper.SetActive(self["m_txt_attr_after" .. i], self.m_curServerLv ~= self.m_afterLv)
      if self.m_curServerLv ~= self.m_afterLv then
        self[string.format("m_txt_attr_after%d_Text", i)].text = BigNumFormat(afterAttrTab[paramStr])
      end
    else
      UILuaHelper.SetActive(self["m_attr" .. i], false)
    end
  end
end

function Form_CirculationPop:FreshButtonShow()
  local isMax = self.m_curServerLv >= self.m_circulationLevelCfgMaxID
  UILuaHelper.SetActive(self.m_unlock_tips, isMax or self.m_isUpUnlock == true)
  UILuaHelper.SetActive(self.m_button_root, not isMax and self.m_isUpUnlock ~= true)
  if isMax then
    self.m_txt_unlock_tips_Text.text = ConfigManager:GetCommonTextById(100048)
  elseif self.m_isUpUnlock == true then
    self.m_txt_unlock_tips_Text.text = self.m_unlockTips
  end
  UILuaHelper.SetActive(self.m_btn_Back_Circulation, self.m_isNeedBackCirculation == true)
  UILuaHelper.SetActive(self.m_cost_node, not isMax)
end

function Form_CirculationPop:OnCostItemClk(itemID, itemNum, itemCom)
  if self.m_isUpUnlock == true then
    return
  end
  if self.m_curHaveItemNum <= 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 12005)
    return
  end
  local tempAdd = self.m_addExpNum + 1
  if tempAdd > self.m_curHaveItemNum then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 12005)
    return
  end
  if tempAdd > self.m_canAddMaxExpNum then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, self.m_conditionUnlockStr)
    return
  end
  self.m_addExpNum = tempAdd
  self.m_afterLv, self.m_afterExpNum = self:GetAfterLvAndExpNum()
  self:FreshLevelShow()
  self:FreshExpBarShow()
  self:FreshAttrShow()
  self:FreshUseItemNum()
end

function Form_CirculationPop:OnCostItemDelClk(itemID, itemNum, itemCom)
  if self.m_addExpNum <= 0 then
    return
  end
  self.m_addExpNum = self.m_addExpNum - 1
  self.m_afterLv, self.m_afterExpNum = self:GetAfterLvAndExpNum()
  self:FreshLevelShow()
  self:FreshExpBarShow()
  self:FreshAttrShow()
  self:FreshUseItemNum()
end

function Form_CirculationPop:OnBtnupgraderedClicked()
  if self.m_addExpNum <= 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 12002)
    return
  end
  HeroManager:ReqUpgradeCirculation(self.m_curCirculationID, self.m_addExpNum)
end

function Form_CirculationPop:OnBtnautoblackClicked()
  if self.m_curHaveItemNum <= 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 12005)
    return
  end
  local afterCirculationCfg = self.m_circulationLevelCfgDic[self.m_afterLv]
  local curMaxExpNum = afterCirculationCfg.m_Exp
  local oneLvAddExp = curMaxExpNum - self.m_afterExpNum
  local tempAddExpNum = oneLvAddExp + self.m_addExpNum
  if tempAddExpNum > self.m_curHaveItemNum then
    tempAddExpNum = self.m_curHaveItemNum
    if self.m_addExpNum == self.m_curHaveItemNum then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 12005)
      return
    end
  end
  if self.m_afterLv >= self.m_circulationLevelCfgMaxID then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 12004)
    return
  end
  if tempAddExpNum > self.m_canAddMaxExpNum then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, self.m_conditionUnlockStr)
    return
  end
  self.m_addExpNum = tempAddExpNum
  self.m_afterLv, self.m_afterExpNum = self:GetAfterLvAndExpNum()
  self:FreshLevelShow()
  self:FreshExpBarShow()
  self:FreshAttrShow()
  self:FreshUseItemNum()
end

function Form_CirculationPop:OnBtnemptyClicked()
  self.m_addExpNum = 0
  self.m_afterLv, self.m_afterExpNum = self:GetAfterLvAndExpNum()
  self:FreshLevelShow()
  self:FreshExpBarShow()
  self:FreshAttrShow()
  self:FreshUseItemNum()
end

function Form_CirculationPop:OnBtnBackCirculationClicked()
  self:CloseForm()
  StackFlow:Push(UIDefines.ID_FORM_CIRCULATIONMAIN)
end

function Form_CirculationPop:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_CirculationPop:OnBtnReturnClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_CirculationPop", Form_CirculationPop)
return Form_CirculationPop
