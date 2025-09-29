local Form_CirculationResonancePop = class("Form_CirculationResonancePop", require("UI/UIFrames/Form_CirculationResonancePopUI"))
local CareerLevelValueIns = ConfigManager:GetConfigInsByName("CareerLevelValue")
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local MAX_SLOT_NUM = 5
local CareerLevelCharLocationValueIns = ConfigManager:GetConfigInsByName("CareerLevelCharLocationValue")
local TabType = {Level = 1, Equip = 2}

function Form_CirculationResonancePop:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_CirculationCareerUpgrade", handler(self, self.OnUpgradeBack))
  self:addEventListener("eGameEvent_Hero_SetCirculationCareerHero", handler(self, self.OnSetHero))
end

function Form_CirculationResonancePop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CirculationResonancePop:SetInitParam(param)
end

function Form_CirculationResonancePop:OnBtnautoblackClicked()
  if self.m_curHaveItemNum <= 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 12005)
    return
  end
  local afterCirculationCfg = self.m_CareerLevelCfgDic[self.m_afterLv]
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

function Form_CirculationResonancePop:OnBtnemptyClicked()
  self.m_addExpNum = 0
  self.m_afterLv, self.m_afterExpNum = self:GetAfterLvAndExpNum()
  self:FreshLevelShow()
  self:FreshExpBarShow()
  self:FreshAttrShow()
  self:FreshUseItemNum()
end

function Form_CirculationResonancePop:FreshBaseInfo()
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(self.m_curCareerID)
  if not careerCfg:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_camp_icon_Image, careerCfg.m_CirculationCareerIcon, nil, nil, true)
    self.m_txt_campname_Text.text = careerCfg.m_mCareerName
  end
end

function Form_CirculationResonancePop:OnBtnupgraderedClicked()
  if self.m_addExpNum <= 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 12002)
    return
  end
  HeroManager:ReqUpgradeCirculationCareer(self.m_curCareerID, self.m_addExpNum)
end

function Form_CirculationResonancePop:OnBtnBackCirculationClicked()
  self:CloseForm()
  StackFlow:Push(UIDefines.ID_FORM_CIRCULATIONMAIN)
end

function Form_CirculationResonancePop:OnSetHero(circulationItem)
  self:FreshEquipUI()
  StackPopup:Push(UIDefines.ID_FORM_CIRCULATIONLEVELUP, {
    beforeList = self.m_beforeHeroList,
    afterList = self.m_inheritList,
    resonationID = self.m_curCareerID
  })
  self:FreshBeforeHeroList()
end

function Form_CirculationResonancePop:OnUpgradeBack(circulationItem)
  if circulationItem.iCareerType == self.m_curCareerID then
    local lastServerLv = self.m_curServerLv
    local newLv = circulationItem.iLevel
    if lastServerLv ~= newLv then
      StackPopup:Push(UIDefines.ID_FORM_CIRCULATIONRESONATIONUPGRADETIPS, {
        lastLv = lastServerLv,
        newLv = newLv,
        resonationID = self.m_curCareerID
      })
    end
    self:FreshUI()
  end
end

function Form_CirculationResonancePop:AfterInit()
  self.super.AfterInit(self)
  self.TabCfg = {
    [TabType.Level] = {
      selectNode = self.m_pnl_lvup_sel,
      unSelectNode = self.m_pnl_lvup_grey,
      panelNode = self.m_pnl_lvup
    },
    [TabType.Equip] = {
      selectNode = self.m_pnl_fill_sel,
      unSelectNode = self.m_pnl_fill_grey,
      panelNode = self.m_pnl_fill
    }
  }
  self.m_inheritList = {}
  self.m_maxSlotNum = tonumber(MAX_SLOT_NUM)
  self:FreshCirculationLevelList()
  self.m_heroAttr = HeroManager:GetHeroAttr()
  local itemData = {
    itemClkBackFun = handler(self, self.OnHeroItemClk)
  }
  self.m_locationHeroListGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_InfinityGrid, "Circulation/UIICareerItem", itemData)
  self.m_locationHeroListGrid:RegisterButtonCallback("c_btn_empty", handler(self, self.OnEmptyItemClk))
  self.m_locationHeroListGrid:RegisterButtonCallback("c_btn_lock", handler(self, self.OnLockBtnClk))
end

function Form_CirculationResonancePop:OnHeroItemClk(index, isLock)
  if not index then
    return
  end
  if not isLock then
    StackPopup:Push(UIDefines.ID_FORM_CIRCULATIONCAREERHEROLIST, {
      pos = index,
      careerID = self.m_curCareerID,
      conflictHeros = self.m_inheritList
    })
  end
end

function Form_CirculationResonancePop:OnEmptyItemClk(index, go)
  local fjItemIndex = index + 1
  StackPopup:Push(UIDefines.ID_FORM_CIRCULATIONCAREERHEROLIST, {
    pos = fjItemIndex,
    careerID = self.m_curCareerID,
    conflictHeros = self.m_inheritList
  })
end

function Form_CirculationResonancePop:OnLockBtnClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local locked, levelID = HeroManager:GetCareerLocationLock(self.m_curCareerID, fjItemIndex)
  local levelName = LevelManager:GetLevelName(LevelManager.LevelType.MainLevel, levelID)
  local lockStr = ConfigManager:GetClientMessageTextById(11902)
  lockStr = string.CS_Format(lockStr, levelName)
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, lockStr)
end

function Form_CirculationResonancePop:refreshInheritLoopScroll()
  self.m_inheritCellList = self:GetInheritCellList()
  self.m_locationHeroListGrid:ShowItemList(self.m_inheritCellList)
end

function Form_CirculationResonancePop:GetInheritCellList()
  local inheritList = {}
  for i = 1, MAX_SLOT_NUM do
    local info = self.m_inheritList and self.m_inheritList[i]
    if info then
      inheritList[i] = {
        iHeroId = info,
        iCdTime = 0,
        isLock = false,
        careerID = self.m_curCareerID
      }
    else
      local isLock = HeroManager:GetCareerLocationLock(self.m_curCareerID, i)
      inheritList[i] = {
        iHeroId = 0,
        iCdTime = 0,
        isLock = isLock,
        careerID = self.m_curCareerID
      }
    end
  end
  return inheritList
end

function Form_CirculationResonancePop:FreshCirculationLevelList()
  if not self.m_curCareerID then
    return
  end
  local CareerCfgDic = CareerLevelValueIns:GetValue_ByCareerType(self.m_curCareerID)
  if not CareerCfgDic then
    return
  end
  local CareerLevelCfgDic = {}
  local tempNum = 0
  for _, tempCfg in pairs(CareerCfgDic) do
    CareerLevelCfgDic[tempCfg.m_Level] = tempCfg
    tempNum = tempNum + 1
  end
  self.m_CareerLevelCfgDic = CareerLevelCfgDic
  self.m_circulationLevelCfgMaxID = tempNum - 1
end

function Form_CirculationResonancePop:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curCareerID = tParam.careerID
    self.m_isShowBack = tParam.isShowBack
    self.m_csui.m_param = nil
  end
  self.m_locationHeroListGrid:ShowItemList({})
  self:AddEventListeners()
  self:RegisterOrUpdateRedDotItem(self.m_btn_fill_redpoint, RedDotDefine.ModuleType.HeroCareerLocationUp, self.m_curCareerID)
  self:FreshBeforeHeroList()
  self:FreshUI()
end

function Form_CirculationResonancePop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:UnRegisterAllRedDotItem()
end

function Form_CirculationResonancePop:OnDestroy()
  if self.m_locationHeroListGrid then
    self.m_locationHeroListGrid:dispose()
    self.m_locationHeroListGrid = nil
  end
  self.super.OnDestroy(self)
end

function Form_CirculationResonancePop:FreshUI()
  self.m_btn_Back_Circulation:SetActive(self.m_isShowBack)
  self:OnBtnlvupClicked()
  self:FreshEquipUI()
end

function Form_CirculationResonancePop:FreshLevelShow()
  local isMax = self.m_curServerLv >= self.m_circulationLevelCfgMaxID
  self.m_txt_lv_before_Text.text = self.m_curServerLv
  UILuaHelper.SetActive(self.m_txt_lv_after_Text, not isMax)
  self.m_txt_lv_after_Text.text = self.m_afterLv
end

function Form_CirculationResonancePop:FreshExpBarShow()
  local nextCirculationCfg = self.m_CareerLevelCfgDic[self.m_afterLv]
  local afterMaxExp = nextCirculationCfg.m_Exp
  local nextPercent = self.m_afterExpNum / afterMaxExp
  self.m_img_bar_preview_Image.fillAmount = nextPercent
  UILuaHelper.SetActive(self.m_img_bar, self.m_curServerLv == self.m_afterLv)
  if self.m_curServerLv == self.m_afterLv then
    local expMaxNum = self.m_curLevelCfg.m_Exp
    local curExp = self.m_curServerExpNum
    local curPercent = curExp / expMaxNum
    self.m_img_bar_Image.fillAmount = curPercent
  end
  self.m_txt_exp_num_Text.text = string.format("%d/%d", self.m_afterExpNum, afterMaxExp)
end

function Form_CirculationResonancePop:GetCanUpMaxLv()
  if not self.m_curCareerID then
    return
  end
  local conditionNum, unlockMessageStr
  conditionNum = InheritManager:GetInheritLevel()
  unlockMessageStr = ConfigManager:GetClientMessageTextById(12001)
  local addExpNum = 0
  local maxLv = 0
  local endIndex = self.m_circulationLevelCfgMaxID
  for i = self.m_curServerLv, endIndex do
    local circulationCfg = self.m_CareerLevelCfgDic[i]
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

function Form_CirculationResonancePop:IsCirculationLock()
  if not self.m_curCirculationID then
    return
  end
  local circulationCfg = self.m_CareerLevelCfgDic[self.m_curServerLv]
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

function Form_CirculationResonancePop:FreshHeroUI()
  if not self.m_curCareerID then
    return
  end
end

function Form_CirculationResonancePop:FreshLevelUI()
  if not self.m_curCareerID then
    return
  end
  self.m_curServerLv = HeroManager:GetCirculationCareerLvByID(self.m_curCareerID)
  self.m_curServerExpNum = HeroManager:GetCirculationCareerExpByID(self.m_curCareerID)
  self:FreshCirculationLevelList()
  self.m_curLevelCfg = self.m_CareerLevelCfgDic[self.m_curServerLv]
  self.m_costItemID = self.m_curLevelCfg.m_ItemID
  self.m_curHaveItemNum = ItemManager:GetItemNum(self.m_costItemID)
  self.m_canUpMaxLv, self.m_canAddMaxExpNum, self.m_conditionUnlockStr = self:GetCanUpMaxLv()
  self.m_afterLv = self.m_curServerLv
  self.m_afterExpNum = self.m_curServerExpNum
  self.m_addExpNum = 0
  self:InitCostItem()
  self:FreshBaseInfo()
  self:FreshLevelShow()
  self:FreshExpBarShow()
  self:FreshAttrShow()
  self:FreshItemCostNum()
  self:FreshUseItemNum()
end

function Form_CirculationResonancePop:InitCostItem()
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

function Form_CirculationResonancePop:FreshItemCostNum()
  if not self.m_costItemWidget then
    return
  end
  self.m_curHaveItemNum = ItemManager:GetItemNum(self.m_costItemID)
  UILuaHelper.SetActive(self.m_txt_num0, self.m_curHaveItemNum == 0)
  self.m_costItemWidget:RefreshNum(self.m_curHaveItemNum)
end

function Form_CirculationResonancePop:FreshUseItemNum123()
  if not self.m_costItemWidget then
    return
  end
  self.m_costItemWidget:SetUpGradeNum(self.m_addExpNum)
end

function Form_CirculationResonancePop:FreshUseItemNum()
  if not self.m_costItemWidget then
    return
  end
  self.m_costItemWidget:SetUpGradeNum(self.m_addExpNum)
end

function Form_CirculationResonancePop:GetAfterLvAndExpNum()
  local addExpNum = self.m_addExpNum + self.m_curServerExpNum
  local endIndex = self.m_circulationLevelCfgMaxID
  local lv, tempExp
  for i = self.m_curServerLv, endIndex do
    local circulationCfg = self.m_CareerLevelCfgDic[i]
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

function Form_CirculationResonancePop:OnCostItemClk(itemID, itemNum, itemCom)
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
  self:FreshUseItemNum123()
end

function Form_CirculationResonancePop:OnCostItemDelClk(itemID, itemNum, itemCom)
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

function Form_CirculationResonancePop:FreshLevelShow()
  local isMax = self.m_curServerLv >= self.m_circulationLevelCfgMaxID
  self.m_txt_lv_before_Text.text = self.m_curServerLv
  UILuaHelper.SetActive(self.m_txt_lv_after_Text, not isMax)
  self.m_txt_lv_after_Text.text = self.m_afterLv
end

function Form_CirculationResonancePop:FreshExpBarShow()
  local nextCirculationCfg = self.m_CareerLevelCfgDic[self.m_afterLv]
  local afterMaxExp = nextCirculationCfg.m_Exp
  local nextPercent = self.m_afterExpNum / afterMaxExp
  self.m_img_bar_preview_Image.fillAmount = nextPercent
  UILuaHelper.SetActive(self.m_img_bar, self.m_curServerLv == self.m_afterLv)
  if self.m_curServerLv == self.m_afterLv then
    local expMaxNum = self.m_curLevelCfg.m_Exp
    local curExp = self.m_curServerExpNum
    local curPercent = curExp / expMaxNum
    self.m_img_bar_Image.fillAmount = curPercent
  end
  self.m_txt_exp_num_Text.text = string.format("%d/%d", self.m_afterExpNum, afterMaxExp)
end

function Form_CirculationResonancePop:FreshItemCostNum()
  if not self.m_costItemWidget then
    return
  end
  self.m_curHaveItemNum = ItemManager:GetItemNum(self.m_costItemID)
  UILuaHelper.SetActive(self.m_txt_num0, self.m_curHaveItemNum == 0)
  self.m_costItemWidget:RefreshNum(self.m_curHaveItemNum)
end

function Form_CirculationResonancePop:FreshUseItemNum()
  if not self.m_costItemWidget then
    return
  end
  self.m_costItemWidget:SetUpGradeNum(self.m_addExpNum)
end

function Form_CirculationResonancePop:FreshAttrShow()
  local beforeAttrTab = self.m_heroAttr:GetResonationBaseAttr(self.m_curCareerID, self.m_curServerLv)
  local afterAttrTab
  if self.m_curServerLv ~= self.m_afterLv then
    afterAttrTab = self.m_heroAttr:GetResonationBaseAttr(self.m_curCareerID, self.m_afterLv)
  end
  for i = 1, 4 do
    if i <= 4 then
      UILuaHelper.SetActive(self["m_attr" .. i], true)
      local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(i)
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

function Form_CirculationResonancePop:FreshAttrLocationShow()
  local beforeAttrTab = self.m_heroAttr:GetCareerLocationBaseAttr(self.m_inheritList)
  for i = 1, 4 do
    if i <= 4 then
      UILuaHelper.SetActive(self["m_attr" .. i .. "_fill"], true)
      local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(i)
      self[string.format("m_txt_attr_name%d_fill_Text", i)].text = propertyIndexCfg.m_mCNName
      UILuaHelper.SetAtlasSprite(self[string.format("m_img_icon%d_fill_Image", i)], propertyIndexCfg.m_PropertyIcon .. "_02")
      local paramStr = propertyIndexCfg.m_ENName
      self[string.format("m_txt_attr_before%d_fill_Text", i)].text = BigNumFormat(beforeAttrTab[paramStr])
      UILuaHelper.SetActive(self["m_txt_attr_after" .. i .. "_fill"], false)
    else
      UILuaHelper.SetActive(self["m_attr" .. i .. "_fill"], false)
    end
  end
end

function Form_CirculationResonancePop:ChangeTabShow(tabType)
  for tab, curNode in pairs(self.TabCfg) do
    if tab == tabType then
      UILuaHelper.SetActive(curNode.selectNode, true)
      UILuaHelper.SetActive(curNode.unSelectNode, false)
      UILuaHelper.SetActive(curNode.panelNode, true)
    else
      UILuaHelper.SetActive(curNode.selectNode, false)
      UILuaHelper.SetActive(curNode.unSelectNode, true)
      UILuaHelper.SetActive(curNode.panelNode, false)
    end
  end
  self.m_curTabType = tabType
end

function Form_CirculationResonancePop:OnBtnlvupClicked()
  self:OnTabClk(TabType.Level)
  self:FreshLevelUI()
end

function Form_CirculationResonancePop:OnBtnfillClicked()
  self:OnTabClk(TabType.Equip)
end

function Form_CirculationResonancePop:GetCommondHeros()
  local heroDic = {}
  local totalScore = 0
  for pos, heroID in pairs(self.m_inheritList) do
    heroDic[heroID] = pos
  end
  local list = {}
  local heroList = HeroManager:GetHeroList()
  for i, v in ipairs(heroList) do
    if v.characterCfg.m_Career == self.m_curCareerID then
      info = {}
      local iQuality = v.characterCfg.m_Quality
      local iBreak = v.serverData.iBreak or 0
      local heroID = v.serverData.iHeroId
      local locationCfg = CareerLevelCharLocationValueIns:GetValue_ByLimitBreakLevelAndQuality(iBreak, iQuality)
      info.sorting = locationCfg.m_Sorting
      info.iHeroId = heroID
      info.sortSave = 0
      if heroDic[heroID] then
        info.sortSave = 0.5
        totalScore = totalScore + info.sorting
      end
      info.pos = heroDic[heroID] or 0
      table.insert(list, info)
    end
  end
  
  local function sortFun(data1, data2)
    return data1.sorting + data1.sortSave > data2.sorting + data2.sortSave
  end
  
  table.sort(list, sortFun)
  local filterList = {}
  local savedIndex = {}
  local afterScore = 0
  for i = 1, MAX_SLOT_NUM do
    local lock, _ = HeroManager:GetCareerLocationLock(self.m_curCareerID, i)
    if list[i] ~= nil and not lock then
      afterScore = afterScore + list[i].sorting
      savedIndex[list[i].pos] = list[i].iHeroId
      table.insert(filterList, list[i])
    end
  end
  if totalScore >= afterScore then
    return nil
  end
  for i = 1, MAX_SLOT_NUM do
    local lock, _ = HeroManager:GetCareerLocationLock(self.m_curCareerID, i)
    if not savedIndex[i] and not lock then
      for j = 1, #filterList do
        if filterList[j].pos == 0 then
          filterList[j].pos = i
        end
      end
    end
  end
  return filterList
end

function Form_CirculationResonancePop:OnBtnfillinClicked()
  local vSetList = {}
  local filterHeros = self:GetCommondHeros()
  if not filterHeros then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 11903)
  else
    for i = 1, MAX_SLOT_NUM do
      local info = {}
      if filterHeros[i] then
        info.iCareerType = self.m_curCareerID
        info.iLocation = i
        info.iHeroID = filterHeros[i].iHeroId
        table.insert(vSetList, info)
      end
    end
    HeroManager:ReqSetCirculationCareerHero(vSetList)
  end
end

function Form_CirculationResonancePop:FreshBeforeHeroList()
  self.m_beforeHeroList = {}
  local heros = HeroManager:GetLocationHeroByCareerID(self.m_curCareerID)
  for _, heroId in pairs(heros) do
    table.insert(self.m_beforeHeroList, heroId)
  end
end

function Form_CirculationResonancePop:FreshEquipUI()
  self.m_inheritList = HeroManager:GetLocationHeroByCareerID(self.m_curCareerID)
  self:refreshInheritLoopScroll()
  self:FreshAttrLocationShow()
end

function Form_CirculationResonancePop:OnTabClk(tabType)
  if not TabType then
    return
  end
  if self.m_curTabType == tabType then
    return
  end
  self:ChangeTabShow(tabType)
end

local fullscreen = true
ActiveLuaUI("Form_CirculationResonancePop", Form_CirculationResonancePop)
return Form_CirculationResonancePop
