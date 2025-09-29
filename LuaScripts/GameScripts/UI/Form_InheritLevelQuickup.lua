local Form_InheritLevelQuickup = class("Form_InheritLevelQuickup", require("UI/UIFrames/Form_InheritLevelQuickupUI"))
local globalSettingsIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local LvExpItemID = tonumber(globalSettingsIns:GetValue_ByName("CharacterlvEXPitem").m_Value)
local LvMoneyItemID = tonumber(globalSettingsIns:GetValue_ByName("CharacterlvCurrencyitem").m_Value)
local LvBreakthroughItemID = tonumber(globalSettingsIns:GetValue_ByName("CharacterlvBreakthroughitem").m_Value)

function Form_InheritLevelQuickup:SetInitParam(param)
end

function Form_InheritLevelQuickup:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_lvup_arrow = self.m_rootTrans:Find("pnl_content/pnl_lv/m_txt_lv_after/img_up").gameObject
  local goBackBtnRoot = self.m_rootTrans:Find("pnl_content/ui_common_top_back").gameObject
  if goBackBtnRoot then
    self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome))
  end
  self.m_RolesListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_pnl_role_list_InfinityGrid, "Inherit/UILevelUpItem")
  self.m_RolesListInfinityGrid:RegisterButtonCallback("m_inheritlevel_item", handler(self, self.OnRoleItemClick))
  self:InitNumStepper(self.m_rootTrans:Find("pnl_content/m_common_stepper"))
  self.m_widgetItem1 = self:createCommonItem(self.m_common_item1)
  self.m_widgetItem2 = self:createCommonItem(self.m_common_item2)
  self.m_widgetItem3 = self:createCommonItem(self.m_common_item3)
  local processItemData1 = ResourceUtil:GetProcessRewardData({iID = LvExpItemID, iNum = 1})
  local processItemData2 = ResourceUtil:GetProcessRewardData({iID = LvMoneyItemID, iNum = 1})
  local processItemData3 = ResourceUtil:GetProcessRewardData({iID = LvBreakthroughItemID, iNum = 1})
  self.m_widgetItem1:SetItemInfo(processItemData1)
  self.m_widgetItem2:SetItemInfo(processItemData2)
  self.m_widgetItem3:SetItemInfo(processItemData3)
  self.m_widgetItem1:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnItemClick(itemID, itemNum, itemCom)
  end)
  self.m_widgetItem2:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnItemClick(itemID, itemNum, itemCom)
  end)
  self.m_widgetItem3:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnItemClick(itemID, itemNum, itemCom)
  end)
  self.curItemConfig = {}
  self.m_toggle:SetActive(false)
  self.m_toggle_Toggle.onValueChanged:AddListener(function()
    self.m_useBagItems = self.m_toggle_Toggle.isOn
    LocalDataManager:SetIntSimple("LevelUpQuickUseBagItems", self.m_useBagItems and 0 or 1)
    self.m_maxBatchLv, self.m_maxNeedItemConfig = self:GetMaxBatchLv()
    self:RefreshDatas()
    self:SetNumStepper()
    self:RefreshUI()
  end)
  self.m_useBagItems = false
end

function Form_InheritLevelQuickup:OnActive()
  self.lstHero = {}
  self.m_afterLv = 0
  for _, v in pairs(InheritManager:GetTopFiveHero()) do
    table.insert(self.lstHero, {
      heroData = v,
      iLevel = self.m_afterLv
    })
  end
  self.m_maxBatchLv, self.m_maxNeedItemConfig = self:GetMaxBatchLv()
  local hasInheritLimit, minBreakthroughLevel, minLevel = self:CheckInheritLimit()
  if hasInheritLimit then
    self.m_afterLv = math.max(minBreakthroughLevel, self.m_maxBatchLv)
  else
    self.m_afterLv = math.max(minLevel, self.m_maxBatchLv)
  end
  self:RefreshDatas()
  self:ResetNumStepper()
  self:RefreshUI()
  self:AddEventListeners()
  self.super.OnActive(self)
end

function Form_InheritLevelQuickup:OnInactive()
  self:RemoveAllEventListeners()
  self.super.OnInactive(self)
end

function Form_InheritLevelQuickup:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_InheritLevelQuickup:AddEventListeners()
  self:addEventListener("eGameEvent_Inherit_BatchLevelUp", handler(self, self.OnLevelUpSuccess))
  self:addEventListener("eGameEvent_Item_Use", handler(self, self.OnItemChanged))
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_InheritLevelQuickup:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_InheritLevelQuickup:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_InheritLevelQuickup:OnBackClk()
  self:CloseForm()
  if self.m_closeBackFun then
    self.m_closeBackFun()
  end
end

function Form_InheritLevelQuickup:OnBackHome()
  StackPopup:PopAll()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
end

function Form_InheritLevelQuickup:OnLevelUpSuccess(data)
  log.info("OnLevelUpSuccess data: " .. table.serialize(data))
  StackPopup:Push(UIDefines.ID_FORM_INHERITLEVELQUICKUPRESULT, data)
  self.m_maxBatchLv, self.m_maxNeedItemConfig = self:GetMaxBatchLv()
  local hasInheritLimit, minBreakthroughLevel, minLevel = self:CheckInheritLimit()
  if hasInheritLimit then
    self.m_afterLv = math.max(minBreakthroughLevel, self.m_maxBatchLv)
  else
    self.m_afterLv = math.max(minLevel, self.m_maxBatchLv)
  end
  self:RefreshDatas()
  self:RefreshUI()
  self:ResetNumStepper()
end

function Form_InheritLevelQuickup:OnItemChanged()
  log.info("OnItemChanged")
  self.m_maxBatchLv, self.m_maxNeedItemConfig = self:GetMaxBatchLv()
  local hasInheritLimit, minBreakthroughLevel, minLevel = self:CheckInheritLimit()
  if hasInheritLimit then
    self.m_afterLv = math.max(minBreakthroughLevel, self.m_maxBatchLv)
  else
    self.m_afterLv = math.max(minLevel, self.m_maxBatchLv)
  end
  self:RefreshDatas()
  self:RefreshUI()
  self:ResetNumStepper()
end

function Form_InheritLevelQuickup:RefreshDatas()
  self.curItemConfig = {}
  self.curItemConfig[LvExpItemID] = ItemManager:GetItemNumWithBagItems(LvExpItemID, self.m_useBagItems)
  self.curItemConfig[LvMoneyItemID] = ItemManager:GetItemNumWithBagItems(LvMoneyItemID, self.m_useBagItems)
  self.curItemConfig[LvBreakthroughItemID] = ItemManager:GetItemNumWithBagItems(LvBreakthroughItemID, self.m_useBagItems)
  self.m_beforeLv = InheritManager:GetInheritLevel()
  if self.m_afterLv == self.m_maxBatchLv then
    self.m_needItemConfig = self.m_maxNeedItemConfig
  else
    self.m_needItemConfig = self:GetNeedItemConfig(self.m_beforeLv, self.m_afterLv)
  end
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_closeBackFun = tParam.closeBackFun
  end
end

function Form_InheritLevelQuickup:RefreshUI()
  self.m_txt_lv_before_Text.text = ConfigManager:GetCommonTextById(20386) .. self.m_beforeLv
  self.m_txt_lv_after_Text.text = ConfigManager:GetCommonTextById(20386) .. self.m_afterLv
  self.lstHero = {}
  for _, v in pairs(InheritManager:GetTopFiveHero()) do
    table.insert(self.lstHero, {
      heroData = v,
      iLevel = self.m_afterLv
    })
  end
  self.m_RolesListInfinityGrid:ShowItemList(self.lstHero)
  self.m_widgetItem1:SetNeedNum(self.m_needItemConfig[LvExpItemID], self.curItemConfig[LvExpItemID])
  self.m_widgetItem2:SetNeedNum(self.m_needItemConfig[LvMoneyItemID], self.curItemConfig[LvMoneyItemID])
  self.m_widgetItem3:SetNeedNum(self.m_needItemConfig[LvBreakthroughItemID], self.curItemConfig[LvBreakthroughItemID])
  if self.m_needItemConfig[LvBreakthroughItemID] <= 0 then
    self.m_common_item3:SetActive(false)
  else
    self.m_common_item3:SetActive(true)
  end
  self.m_btn_yes:SetActive(self.m_afterLv > self.m_beforeLv and self.can_level_Up)
  self.m_btn_no:SetActive(self.m_afterLv <= self.m_beforeLv or not self.can_level_Up)
  self.m_lvup_arrow:SetActive(self.m_afterLv > self.m_beforeLv)
  self.m_toggle_Toggle.isOn = self.m_useBagItems
end

function Form_InheritLevelQuickup:ResetNumStepper()
  self:OnNumChangeCB(self.m_afterLv)
end

function Form_InheritLevelQuickup:OnBtnyesClicked()
  local heroIDList = {}
  for _, v in pairs(self.lstHero) do
    heroIDList[v.heroData.serverData.iHeroId] = math.max(0, v.iLevel - v.heroData.serverData.iLevel)
  end
  log.info("heroIDList .. " .. table.serialize(heroIDList))
  InheritManager:ReqInheritBatchLevelUp(heroIDList)
end

function Form_InheritLevelQuickup:OnBtnnoClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(13032))
end

function Form_InheritLevelQuickup:OnBtnbagClicked()
  StackFlow:Push(UIDefines.ID_FORM_BAGNEW)
end

function Form_InheritLevelQuickup:OnItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_InheritLevelQuickup:InitNumStepper(m_goRoot)
  self.m_btnReduce = m_goRoot.transform:Find("btn_reduce").gameObject
  CS.CommonExtensions.AddEventTriggerListener(self.m_btnReduce, CS.UnityEngine.EventSystems.EventTriggerType.PointerDown, handler(self, self.OnBtnreduceClicked))
  self.m_btnIncrease = m_goRoot.transform:Find("btn_increase").gameObject
  CS.CommonExtensions.AddEventTriggerListener(self.m_btnIncrease, CS.UnityEngine.EventSystems.EventTriggerType.PointerDown, handler(self, self.OnBtnincreaseClicked))
  self.m_btnMax = m_goRoot.transform:Find("btn_max"):GetComponent("Button")
  UILuaHelper.BindButtonClickManual(self, self.m_btnMax, handler(self, self.OnBtnmaxClicked))
  self.m_btnMin = m_goRoot.transform:Find("btn_min"):GetComponent("Button")
  UILuaHelper.BindButtonClickManual(self, self.m_btnMin, handler(self, self.OnBtnmminClicked))
  self.m_textNum = m_goRoot.transform:Find("img_grade_bg/c_txt_num"):GetComponent(T_TextMeshProUGUI)
  self.m_btnMaxC = m_goRoot.transform:Find("btn_max_c").gameObject
  self.m_btnReduceC = m_goRoot.transform:Find("btn_reduce_c").gameObject
  self.m_btnIncreaseC = m_goRoot.transform:Find("btn_increase_c").gameObject
  self.m_btnMinC = m_goRoot.transform:Find("btn_min_c").gameObject
end

function Form_InheritLevelQuickup:RefreshNumStepper(num)
  self.m_textNum.text = num
  local hasInheritLimit, minBreakthroughLevel, minLevel = self:CheckInheritLimit()
  self.m_btnIncreaseC:SetActive(num >= self.m_maxBatchLv)
  self.m_btnMinC:SetActive(num <= minLevel)
  self.m_btnReduceC:SetActive(num <= minLevel)
  self.m_btnMaxC:SetActive(num >= self.m_maxBatchLv)
end

function Form_InheritLevelQuickup:OnNumChangeCB(num)
  local num = math.min(num, self.m_maxBatchLv)
  local hasInheritLimit, minBreakthroughLevel, minLevel = self:CheckInheritLimit()
  if num < minLevel then
    self.can_level_Up = false
    num = minLevel
  else
    self.can_level_Up = true
  end
  self.m_afterLv = num
  self:RefreshNumStepper(num)
  self:RefreshDatas()
  self:RefreshUI()
end

function Form_InheritLevelQuickup:GetMaxBatchLv()
  local curInheritLevel = InheritManager:GetInheritLevel()
  local maxBatchLv = curInheritLevel
  local needItemConfig = {}
  needItemConfig[LvExpItemID] = 0
  needItemConfig[LvMoneyItemID] = 0
  needItemConfig[LvBreakthroughItemID] = 0
  self.curItemConfig[LvExpItemID] = ItemManager:GetItemNumWithBagItems(LvExpItemID, self.m_useBagItems)
  self.curItemConfig[LvMoneyItemID] = ItemManager:GetItemNumWithBagItems(LvMoneyItemID, self.m_useBagItems)
  self.curItemConfig[LvBreakthroughItemID] = ItemManager:GetItemNumWithBagItems(LvBreakthroughItemID, self.m_useBagItems)
  local heroMaxLevel = 200
  for _, v in pairs(self.lstHero) do
    heroMaxLevel = math.min(heroMaxLevel, HeroManager:GetHeroMaxLevel(v.heroData.serverData.iHeroId))
  end
  while maxBatchLv < heroMaxLevel do
    local data = InheritManager:GetInheritBatchLevelUpNeedItem(maxBatchLv + 1)
    local canLevelUp = true
    for _, v in pairs(data) do
      if v.NeedNum > self.curItemConfig[v.ItemID] then
        log.info("GetMaxBatchLv v.NeedNum: " .. v.NeedNum .. " self.curItemConfig[v.ItemID]: " .. self.curItemConfig[v.ItemID])
        canLevelUp = false
        break
      end
      needItemConfig[v.ItemID] = v.NeedNum
    end
    if not canLevelUp then
      break
    end
    maxBatchLv = maxBatchLv + 1
  end
  local hasInheritLimit, minBreakthroughLevel, minLevel = self:CheckInheritLimit()
  if hasInheritLimit then
    maxBatchLv = math.min(maxBatchLv, curInheritLevel)
  end
  log.info("GetMaxBatchLv maxBatchLv: " .. maxBatchLv .. " hasInheritLimit: " .. tostring(hasInheritLimit))
  return maxBatchLv, needItemConfig
end

function Form_InheritLevelQuickup:GetNeedItemConfig(beforeLv, afterLv)
  local needItemConfig = {}
  needItemConfig[LvExpItemID] = 0
  needItemConfig[LvMoneyItemID] = 0
  needItemConfig[LvBreakthroughItemID] = 0
  local data = InheritManager:GetInheritBatchLevelUpNeedItem(afterLv)
  for _, v in pairs(data) do
    needItemConfig[v.ItemID] = needItemConfig[v.ItemID] + v.NeedNum
  end
  return needItemConfig
end

function Form_InheritLevelQuickup:OnRoleItemClick(index, obj)
end

function Form_InheritLevelQuickup:OnBtnbagquickClicked()
  local costList = {}
  for k, v in pairs(self.m_needItemConfig) do
    if 0 < v then
      table.insert(costList, {k, v})
    end
  end
  StackPopup:Push(UIDefines.ID_FORM_POPUPQUICKBAG, {
    quickBagType = ItemManager.ItemQuickUseType.HeroLevelUp,
    costList = costList
  })
end

function Form_InheritLevelQuickup:OnBtnreduceClicked()
  log.info("OnBtnreduceClicked")
  self:OnNumStepperChange(true, false, false)
end

function Form_InheritLevelQuickup:OnBtnincreaseClicked()
  self:OnNumStepperChange(false, false, false)
end

function Form_InheritLevelQuickup:OnBtnmaxClicked()
  self:OnNumStepperChange(false, true, false)
end

function Form_InheritLevelQuickup:OnBtnmminClicked()
  self:OnNumStepperChange(false, false, true)
end

function Form_InheritLevelQuickup:OnNumStepperChange(reduce, isMax, isMin)
  local hasInheritLimit, minBreakthroughLevel, minLevel = self:CheckInheritLimit()
  if isMax then
    self:OnNumChangeCB(self.m_maxBatchLv)
  elseif isMin then
    self:OnNumChangeCB(minLevel)
  elseif reduce then
    if minLevel > self.m_afterLv - 1 then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20014)
      return
    end
    self:OnNumChangeCB(self.m_afterLv - 1)
  else
    if self.m_afterLv + 1 > self.m_maxBatchLv then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20013)
      return
    end
    self:OnNumChangeCB(self.m_afterLv + 1)
  end
end

function Form_InheritLevelQuickup:CheckInheritLimit()
  local curInheritLevel = InheritManager:GetInheritLevel()
  local hasInheritLimit = false
  local minBreakthroughLevel = 999999
  for _, v in pairs(self.lstHero) do
    local heroMaxLevel = HeroManager:GetHeroMaxLevel(v.heroData.serverData.iHeroId)
    if curInheritLevel >= heroMaxLevel then
      hasInheritLimit = true
      minBreakthroughLevel = math.min(minBreakthroughLevel, heroMaxLevel)
    end
  end
  local minLevel = curInheritLevel + 1
  if hasInheritLimit then
    minLevel = minBreakthroughLevel
  end
  return hasInheritLimit, minBreakthroughLevel, minLevel
end

function Form_InheritLevelQuickup:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_InheritLevelQuickup", Form_InheritLevelQuickup)
return Form_InheritLevelQuickup
