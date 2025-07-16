local UISubPanelBase = require("UI/Common/UISubPanelBase")
local HeroLvUpgradeSubPanel = class("HeroLvUpgradeSubPanel", UISubPanelBase)
local DefaultUpLevel = 1
local MaxCostItemNum = 3
local CharacterLevelIns = ConfigManager:GetConfigInsByName("CharacterLevel")
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local GlobalSettingsIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local LvExpItemID = GlobalSettingsIns:GetValue_ByName("CharacterlvEXPitem").m_Value
local LvMoneyItemID = GlobalSettingsIns:GetValue_ByName("CharacterlvCurrencyitem").m_Value
local LvBreakthroughItemID = GlobalSettingsIns:GetValue_ByName("CharacterlvBreakthroughitem").m_Value
local PerLvTriggerTime = tonumber(GlobalSettingsIns:GetValue_ByName("PerLvTriggerTime").m_Value)
local LongDownTriggerTime = tonumber(GlobalSettingsIns:GetValue_ByName("LongDownTriggerTime").m_Value)
local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")
local string_format = string.format
local ipairs = _ENV.ipairs
local LevelUpgradeCfg = {
  LvExp = {
    ItemID = tonumber(LvExpItemID),
    NeedNum = 0,
    ShowCostNum = 0
  },
  LvMoney = {
    ItemID = tonumber(LvMoneyItemID),
    NeedNum = 0,
    ShowCostNum = 0
  },
  LvBreakthrough = {
    ItemID = tonumber(LvBreakthroughItemID),
    NeedNum = 0,
    ShowCostNum = 0
  }
}
local EnterAnimStr = "lv_in"
local OutAnimStr = "lv_out"
local LvUpLoopAnimStr = "arrow_loop"
local LvUpNumAnimStr = "LevelUp_Num"
local ShowLevelUpgrade = {
  LevelUpgradeCfg.LvExp,
  LevelUpgradeCfg.LvMoney,
  LevelUpgradeCfg.LvBreakthrough
}

function HeroLvUpgradeSubPanel:OnInit()
  self.m_curShowHeroData = nil
  self.m_allHeroList = nil
  self.m_curChooseHeroIndex = nil
  if self.m_initData then
  end
  self.m_upgrade_BtnEx = self.m_upgrade:GetComponent("ButtonExtensions")
  if self.m_upgrade_BtnEx then
    self.m_upgrade_BtnEx.Down = handler(self, self.OnUpgradeDown)
    self.m_upgrade_BtnEx.Up = handler(self, self.OnUpgradeUp)
  end
  self.m_costItemWidgets = {}
  for i = 1, MaxCostItemNum do
    local itemRootObj = self.m_list_item.transform:Find("c_common_item" .. i).gameObject
    local itemIcon = self:createCommonItem(itemRootObj)
    self.m_costItemWidgets[#self.m_costItemWidgets + 1] = itemIcon
    itemIcon:SetItemIconClickCB(function()
      self:OnItemClk(i)
    end)
  end
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_downTimer = nil
  self.m_perTriggerTimer = nil
  self.m_outAnimTimer = nil
  self.m_unLockMaxLv = 1
  self.m_m_heroCanLvUpMaxLvTips = "???"
  self.m_curHeroMaxLevelNum = nil
  self.m_heroCanUpMaxLv = nil
  self.m_heroBreakCfgList = nil
  self.m_maxBreakNum = nil
  self.m_curHeroBreakNum = nil
  self.m_curBreakMaxLvNum = nil
  self.m_needItemList = {}
  self:InitLvFxStatus()
  self:AddEventListeners()
  self:FreshTipsLayout()
end

function HeroLvUpgradeSubPanel:OnDestroy()
  HeroLvUpgradeSubPanel.super.OnDestroy(self)
  if self.m_perTriggerTimer then
    TimeService:KillTimer(self.m_perTriggerTimer)
    self.m_perTriggerTimer = nil
  end
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  if self.m_outAnimTimer then
    TimeService:KillTimer(self.m_outAnimTimer)
    self.m_outAnimTimer = nil
  end
  self.m_unLockMaxLv = nil
  self.m_m_heroCanLvUpMaxLvTips = nil
  self.m_needItemList = nil
end

function HeroLvUpgradeSubPanel:OnFreshData()
  self.m_needItemList = {}
  self.m_curShowHeroData = self.m_panelData.heroData
  self.m_allHeroList = self.m_panelData.allHeroList
  self.m_curChooseHeroIndex = self.m_panelData.chooseIndex
  self:FreshLevelUpData()
  self:FreshUI()
end

function HeroLvUpgradeSubPanel:FreshLevelUpData()
  if not self.m_curShowHeroData then
    return
  end
  self.m_curServerLv = self.m_curShowHeroData.serverData.iLevel
  self.m_beforeShowLv = self.m_curServerLv
  self.m_afterShowLv = self.m_curServerLv + DefaultUpLevel
  self.m_unLockMaxLv, self.m_m_heroCanLvUpMaxLvTips = HeroManager:GetHeroCanLevelUpMaxLv(self.m_curShowHeroData.serverData.iHeroId)
  self.m_heroBreakCfgList = {}
  self.m_maxBreakNum = 0
  self.m_curHeroBreakNum = self.m_curShowHeroData.serverData.iBreak or 0
  local limitBreakTemplateID = self.m_curShowHeroData.characterCfg.m_Quality
  if limitBreakTemplateID == nil or limitBreakTemplateID == 0 then
    return
  end
  local allCharacterLimitBreaks = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplate(limitBreakTemplateID)
  for _, breakCfg in pairs(allCharacterLimitBreaks) do
    self.m_heroBreakCfgList[breakCfg.m_LimitBreakLevel] = breakCfg
  end
  self.m_curBreakMaxLvNum = self.m_heroBreakCfgList[self.m_curHeroBreakNum].m_MaxLevel
  self.m_curHeroMaxLevelNum = self:GetHeroCanLevelUpMaxLv()
  self.m_heroCanUpMaxLv = self:GetCanUpgradeLvNum()
  self:FreshBreakMaxNum(self.m_curShowHeroData.characterCfg.m_Quality)
end

function HeroLvUpgradeSubPanel:GetHeroCanLevelUpMaxLv()
  local curMaxLv = self.m_unLockMaxLv
  if curMaxLv > self.m_curBreakMaxLvNum then
    curMaxLv = self.m_curBreakMaxLvNum
  end
  return curMaxLv
end

function HeroLvUpgradeSubPanel:FreshCostItemData()
  local beforeShowLv = self.m_beforeShowLv
  local afterShowLv = self.m_afterShowLv
  for _, v in pairs(LevelUpgradeCfg) do
    v.NeedNum = 0
    v.ShowCostNum = 0
  end
  for i = self.m_curServerLv, beforeShowLv - 1 do
    local characterLevelCfg = CharacterLevelIns:GetValue_ByCharacterLv(i)
    for keyStr, _ in pairs(LevelUpgradeCfg) do
      local paramNum = characterLevelCfg["m_" .. keyStr]
      LevelUpgradeCfg[keyStr].ShowCostNum = LevelUpgradeCfg[keyStr].ShowCostNum + paramNum
    end
  end
  for i = beforeShowLv, afterShowLv - 1 do
    local characterLevelCfg = CharacterLevelIns:GetValue_ByCharacterLv(i)
    for keyStr, _ in pairs(LevelUpgradeCfg) do
      local paramNum = characterLevelCfg["m_" .. keyStr]
      LevelUpgradeCfg[keyStr].NeedNum = LevelUpgradeCfg[keyStr].NeedNum + paramNum
    end
  end
  self.m_needItemList = {}
  local characterLevelCfg = CharacterLevelIns:GetValue_ByCharacterLv(self.m_curServerLv)
  for keyStr, v in pairs(LevelUpgradeCfg) do
    local paramNum = characterLevelCfg["m_" .. keyStr]
    if 0 < paramNum then
      self.m_needItemList[#self.m_needItemList + 1] = {
        v.ItemID,
        paramNum
      }
    end
  end
end

function HeroLvUpgradeSubPanel:GetCanUpgradeLvNum()
  local tempAddNum = 0
  local curServerLv = self.m_curServerLv
  local tempCostCfg = {
    LvExp = 0,
    LvMoney = 0,
    LvBreakthrough = 0
  }
  local isStop = false
  repeat
    local testLv = curServerLv + tempAddNum
    if testLv >= self.m_curHeroMaxLevelNum then
      isStop = true
    else
      local characterLevelCfg = CharacterLevelIns:GetValue_ByCharacterLv(testLv)
      for keyStr, v in pairs(LevelUpgradeCfg) do
        local itemID = v.ItemID
        local cfgItemNum = characterLevelCfg["m_" .. keyStr]
        tempCostCfg[keyStr] = tempCostCfg[keyStr] + cfgItemNum
        local curHaveNum = ItemManager:GetItemNum(itemID)
        if curHaveNum < tempCostCfg[keyStr] then
          isStop = true
          break
        end
      end
    end
    tempAddNum = tempAddNum + 1
  until isStop
  return tempAddNum - 1
end

function HeroLvUpgradeSubPanel:IsMin()
  local beforeShowLv = self.m_beforeShowLv
  local afterShowLv = self.m_afterShowLv
  local addLv = afterShowLv - beforeShowLv
  return addLv <= 1
end

function HeroLvUpgradeSubPanel:IsMax()
  local afterShowLv = self.m_afterShowLv
  return afterShowLv >= self.m_curHeroMaxLevelNum
end

function HeroLvUpgradeSubPanel:IsBeforeLvMax()
  return self.m_beforeShowLv >= self.m_curHeroMaxLevelNum
end

function HeroLvUpgradeSubPanel:IsOverUpMax()
  local serverLv = self.m_curServerLv
  local afterShowLv = self.m_afterShowLv
  local addLv = afterShowLv - serverLv
  local canUpLv = self.m_heroCanUpMaxLv
  return addLv > canUpLv
end

function HeroLvUpgradeSubPanel:IsInAddUpMaxLv()
  local canUpLv = self.m_heroCanUpMaxLv
  return self.m_afterShowLv >= self.m_curServerLv + canUpLv
end

function HeroLvUpgradeSubPanel:IsLevelCanUp()
  if self:IsBeforeLvMax() then
    return false
  end
  if self:IsOverUpMax() then
    return false
  end
  return true
end

function HeroLvUpgradeSubPanel:IsCanBreak()
  local isBelowBreakNum = false
  local maxBreakNum = self.m_maxBreakNum
  if maxBreakNum > self.m_curHeroBreakNum then
    isBelowBreakNum = true
  end
  return isBelowBreakNum
end

function HeroLvUpgradeSubPanel:IsBeforeOverBreakMax()
  return self.m_beforeShowLv >= self.m_curBreakMaxLvNum
end

function HeroLvUpgradeSubPanel:IsBeforeOverUnLockMax()
  return self.m_beforeShowLv >= self.m_unLockMaxLv
end

function HeroLvUpgradeSubPanel:FreshBreakMaxNum(heroQuality)
  if not heroQuality then
    return
  end
  local qualityMaxBreakNum = HeroManager.RBreakNum
  if heroQuality == HeroManager.QualityType.R then
    qualityMaxBreakNum = HeroManager.RBreakNum
  elseif heroQuality == HeroManager.QualityType.SR then
    qualityMaxBreakNum = HeroManager.SRBreakNum
  elseif heroQuality == HeroManager.QualityType.SSR then
    qualityMaxBreakNum = HeroManager.SSRBreakNum
  end
  self.m_maxBreakNum = qualityMaxBreakNum
end

function HeroLvUpgradeSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_SetHeroData", handler(self, self.OnSetHeroData))
  self:addEventListener("eGameEvent_Item_Use", handler(self, self.OnUseItemRefreshUI))
end

function HeroLvUpgradeSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function HeroLvUpgradeSubPanel:OnUseItemRefreshUI()
  self:FreshLevelUpData()
  self:FreshLvChange()
end

function HeroLvUpgradeSubPanel:OnSetHeroData(param)
  if not param then
    return
  end
  local heroServerData = param.heroServerData
  if heroServerData.iHeroId == self.m_curShowHeroData.serverData.iHeroId then
    self:ShowLvUpFx()
    self:FreshLevelUpData()
    self:FreshShowBeforeUp()
    self:FreshShowAfterUp()
    self:FreshLvChange()
    GuideManager:ManualGuideClick(self.m_upgrade, true)
  end
end

function HeroLvUpgradeSubPanel:FreshUI()
  if not self.m_curShowHeroData then
    return
  end
  self:FreshShowBeforeUp()
  self:FreshShowAfterUp()
  self:FreshLvChange()
  self:ResetAnimIn()
end

function HeroLvUpgradeSubPanel:FreshTipsLayout()
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_tips)
end

function HeroLvUpgradeSubPanel:FreshShowBeforeUp()
  local heroID = self.m_curShowHeroData.characterCfg.m_HeroID
  local heroServerData = self.m_curShowHeroData.serverData
  local heroAttrTab = self.m_heroAttr:GetHeroAttrByParam(heroID, {
    iLevel = self.m_beforeShowLv
  }, heroServerData)
  for i, _ in ipairs(AttrBaseShowCfg) do
    local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(i)
    UILuaHelper.SetAtlasSprite(self[string_format("m_before_attr_icon%d_Image", i)], propertyIndexCfg.m_PropertyIcon .. "_02")
    self[string_format("m_before_attr_name%d_Text", i)].text = propertyIndexCfg.m_mCNName
    self[string_format("m_before_attr_num%d_Text", i)].text = BigNumFormat(heroAttrTab[propertyIndexCfg.m_ENName] or 0)
  end
end

function HeroLvUpgradeSubPanel:FreshShowAfterUp()
  local isNoOverMax = self.m_afterShowLv <= self.m_curHeroMaxLevelNum
  local afterLv = isNoOverMax and self.m_afterShowLv or self.m_afterShowLv - DefaultUpLevel
  self.m_txt_lv_after_num_Text.text = afterLv
  local heroID = self.m_curShowHeroData.characterCfg.m_HeroID
  local heroServerData = self.m_curShowHeroData.serverData
  local heroAttrTab = self.m_heroAttr:GetHeroAttrByParam(heroID, {iLevel = afterLv}, heroServerData)
  for i, _ in ipairs(AttrBaseShowCfg) do
    local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(i)
    local afterAttrStr = BigNumFormat(heroAttrTab[propertyIndexCfg.m_ENName] or 0)
    self[string_format("m_after_attr_num%d_Text", i)].text = afterAttrStr
  end
end

function HeroLvUpgradeSubPanel:FreshCostItem()
  for i = 1, MaxCostItemNum do
    local costItemWidget = self.m_costItemWidgets[i]
    local levelUpgradeCfg = ShowLevelUpgrade[i]
    if levelUpgradeCfg.NeedNum == 0 then
      costItemWidget:SetActive(false)
    else
      costItemWidget:SetActive(true)
      local processData = ResourceUtil:GetProcessRewardData({
        iID = levelUpgradeCfg.ItemID,
        iNum = 0
      })
      costItemWidget:SetItemInfo(processData)
      local curHaveNum = ItemManager:GetItemNum(levelUpgradeCfg.ItemID)
      local showHaveNum = curHaveNum - levelUpgradeCfg.ShowCostNum
      if showHaveNum < 0 then
        showHaveNum = 0
      end
      costItemWidget:SetNeedNum(levelUpgradeCfg.NeedNum, showHaveNum)
    end
  end
end

function HeroLvUpgradeSubPanel:FreshAddLevelNode()
  local afterShowLv = self.m_afterShowLv
  local isMin = self:IsMin()
  local isMax = self:IsMax() or self:IsInAddUpMaxLv()
  self.m_txt_num_Text.text = afterShowLv
  UILuaHelper.SetActive(self.m_node_reduce_light, not isMin)
  UILuaHelper.SetActive(self.m_node_reduce_gray, isMin)
  UILuaHelper.SetActive(self.m_node_min_light, not isMin)
  UILuaHelper.SetActive(self.m_node_min_gray, isMin)
  UILuaHelper.SetActive(self.m_node_add_light, not isMax)
  UILuaHelper.SetActive(self.m_node_add_gray, isMax)
  UILuaHelper.SetActive(self.m_node_max_light, not isMax)
  UILuaHelper.SetActive(self.m_node_max_gray, isMax)
end

function HeroLvUpgradeSubPanel:FreshLvChange()
  self:FreshCostItemData()
  self:FreshCostItem()
  self:FreshAddLevelNode()
  self:FreshUpgrade()
  self:CheckShowLoopArrowAnim()
end

function HeroLvUpgradeSubPanel:FreshUpgrade()
  local isMaxOverBreak = self:IsBeforeOverBreakMax()
  if isMaxOverBreak then
    UILuaHelper.SetActive(self.m_upgrade_node, false)
    UILuaHelper.SetActive(self.m_pnl_stepper, false)
    UILuaHelper.SetActive(self.m_list_item, false)
    UILuaHelper.SetActive(self.m_node_level_up_tips, true)
    local isCanBreak = self:IsCanBreak()
    UILuaHelper.SetActive(self.m_z_txt_tips_max, not isCanBreak)
    UILuaHelper.SetActive(self.m_z_txt_tips_limitbreak, isCanBreak)
  else
    UILuaHelper.SetActive(self.m_upgrade_node, true)
    UILuaHelper.SetActive(self.m_pnl_stepper, true)
    UILuaHelper.SetActive(self.m_list_item, true)
    UILuaHelper.SetActive(self.m_node_level_up_tips, false)
    local isOverUpMax = self:IsOverUpMax()
    UILuaHelper.SetActive(self.m_node_upgrade_gray, isOverUpMax)
    UILuaHelper.SetActive(self.m_node_upgrade_light, not isOverUpMax)
  end
end

function HeroLvUpgradeSubPanel:CheckAutoUpLv()
  self.m_afterShowLv = self.m_afterShowLv + 1
  local isLvCanUp = self:IsLevelCanUp()
  if isLvCanUp == false or self.m_afterShowLv > self.m_curHeroMaxLevelNum then
    self.m_afterShowLv = self.m_afterShowLv - 1
    self:StopAutoUp()
    self:CheckReqLvUp()
    return
  end
  self.m_beforeShowLv = self.m_beforeShowLv + 1
  self:FreshShowBeforeUp()
  self:FreshShowAfterUp()
  self:FreshLvChange()
  self:ShowLvUpFx()
end

function HeroLvUpgradeSubPanel:CheckShowLoopArrowAnim()
  local isLevelCanUp = self:IsLevelCanUp()
  if isLevelCanUp then
    UILuaHelper.PlayAnimationByName(self.m_after_attr, LvUpLoopAnimStr)
  else
    UILuaHelper.StopAnimation(self.m_after_attr)
  end
end

function HeroLvUpgradeSubPanel:ShowEnterInAnim()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, EnterAnimStr)
end

function HeroLvUpgradeSubPanel:ShowTabInAnim()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, EnterAnimStr)
end

function HeroLvUpgradeSubPanel:ShowOutAnim(backFun)
  if not self.m_rootObj then
    return
  end
  if self.m_outAnimTimer then
    return
  end
  local animLen = UILuaHelper.GetAnimationLengthByName(self.m_rootObj, OutAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_rootObj, OutAnimStr)
  if self.m_outAnimTimer then
    TimeService:KillTimer(self.m_outAnimTimer)
    self.m_outAnimTimer = nil
  end
  self.m_outAnimTimer = TimeService:SetTimer(animLen, 1, function()
    if backFun then
      backFun()
    end
    self.m_outAnimTimer = nil
  end)
end

function HeroLvUpgradeSubPanel:ResetAnimIn()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.ResetAnimationByName(self.m_rootObj, EnterAnimStr, -1)
  self:CloseLvUpFx()
end

function HeroLvUpgradeSubPanel:InitLvFxStatus()
  UILuaHelper.SetActive(self.m_attr_fx1, false)
  UILuaHelper.SetActive(self.m_fx_lv_up, false)
  UILuaHelper.SetActive(self.m_FX_LevelUp_more, false)
end

function HeroLvUpgradeSubPanel:CloseLvUpFx()
  UILuaHelper.SetActive(self.m_attr_fx1, false)
  UILuaHelper.SetActive(self.m_fx_lv_up, false)
  UILuaHelper.SetActive(self.m_FX_LevelUp_more, false)
end

function HeroLvUpgradeSubPanel:ShowLvUpFx()
  UILuaHelper.SetActive(self.m_attr_fx1, false)
  UILuaHelper.SetActive(self.m_attr_fx1, true)
  if self.m_beforeShowLv and self.m_afterShowLv and self.m_afterShowLv - self.m_beforeShowLv > 1 then
    UILuaHelper.SetActive(self.m_FX_LevelUp_more, false)
    UILuaHelper.SetActive(self.m_FX_LevelUp_more, true)
  else
    UILuaHelper.SetActive(self.m_fx_lv_up, false)
    UILuaHelper.SetActive(self.m_fx_lv_up, true)
  end
  GlobalManagerIns:TriggerWwiseBGMState(28)
  UILuaHelper.PlayAnimationByName(self.m_txt_lv_after_num, LvUpNumAnimStr)
end

function HeroLvUpgradeSubPanel:OnUpgradeDown(pointerEventData)
  if not pointerEventData then
    return
  end
  if self.m_afterShowLv > self.m_unLockMaxLv then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, self.m_m_heroCanLvUpMaxLvTips)
    return
  end
  if self:IsOverUpMax() then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 10006)
    return
  end
  if self:IsLevelCanUp() == false then
    return
  end
  self.m_isDown = true
  if GuideManager:GuideIsActive() then
    return
  end
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self.m_downTimer = TimeService:SetTimer(LongDownTriggerTime, 1, function()
    self:StartAutoUp()
    self.m_downTimer = nil
  end)
end

function HeroLvUpgradeSubPanel:OnUpgradeUp(pointerEventData)
  if not pointerEventData then
    return
  end
  if not self.m_isDown then
    return
  end
  if self.m_afterShowLv <= self.m_curServerLv then
    return
  end
  if self.m_afterShowLv > self.m_curHeroMaxLevelNum then
    return
  end
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self:StopAutoUp()
  self:CheckReqLvUp()
end

function HeroLvUpgradeSubPanel:StartAutoUp()
  if self.m_perTriggerTimer then
    TimeService:KillTimer(self.m_perTriggerTimer)
    self.m_perTriggerTimer = nil
  end
  self.m_perTriggerTimer = TimeService:SetTimer(PerLvTriggerTime, -1, function()
    self:CheckAutoUpLv()
  end)
end

function HeroLvUpgradeSubPanel:StopAutoUp()
  if self.m_perTriggerTimer then
    TimeService:KillTimer(self.m_perTriggerTimer)
    self.m_perTriggerTimer = nil
  end
  self.m_isDown = false
end

function HeroLvUpgradeSubPanel:CheckReqLvUp(lv)
  lv = lv or self.m_afterShowLv
  if lv <= self.m_curServerLv then
    return
  end
  if lv > self.m_curHeroMaxLevelNum then
    return
  end
  local addLv = lv - self.m_curServerLv
  local guideBlocked = GuideManager:ManualGuideClick(self.m_upgrade)
  if guideBlocked then
    return
  end
  HeroManager:ReqHeroLevelUp(self.m_curShowHeroData.serverData.iHeroId, addLv)
end

function HeroLvUpgradeSubPanel:OnBtnreduceClicked()
  local isMin = self:IsMin()
  if isMin then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 10004)
    return
  end
  self.m_afterShowLv = self.m_afterShowLv - 1
  self:FreshShowAfterUp()
  self:FreshLvChange()
end

function HeroLvUpgradeSubPanel:OnBtnaddClicked()
  if self.m_afterShowLv >= self.m_unLockMaxLv then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, self.m_m_heroCanLvUpMaxLvTips)
    return
  end
  local isMax = self:IsMax()
  local isInAddMax = self:IsInAddUpMaxLv()
  if isMax or isInAddMax then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 10005)
    return
  end
  self.m_afterShowLv = self.m_afterShowLv + 1
  self:FreshShowAfterUp()
  self:FreshLvChange()
end

function HeroLvUpgradeSubPanel:OnBtnmaxClicked()
  local canUpMaxLv = self.m_heroCanUpMaxLv
  if self.m_afterShowLv >= self.m_unLockMaxLv then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, self.m_m_heroCanLvUpMaxLvTips)
    return
  end
  if canUpMaxLv <= 0 then
    canUpMaxLv = 1
  end
  local tempAfterShowLv = math.min(self.m_curServerLv + canUpMaxLv, self.m_curHeroMaxLevelNum)
  if tempAfterShowLv == self.m_afterShowLv then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 10005)
    return
  end
  self.m_afterShowLv = tempAfterShowLv
  self:FreshShowAfterUp()
  self:FreshLvChange()
end

function HeroLvUpgradeSubPanel:OnBtnminClicked()
  local tempAfterShowLv = self.m_beforeShowLv + DefaultUpLevel
  if tempAfterShowLv == self.m_afterShowLv then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 10004)
    return
  end
  self.m_afterShowLv = self.m_beforeShowLv + DefaultUpLevel
  self:FreshShowAfterUp()
  self:FreshLvChange()
end

function HeroLvUpgradeSubPanel:OnItemClk(index)
  if not index then
    return
  end
  local itemID = ShowLevelUpgrade[index].ItemID
  local haveNum = ItemManager:GetItemNum(itemID) or 0
  if itemID then
    utils.openItemDetailPop({iID = itemID, iNum = haveNum})
  end
end

function HeroLvUpgradeSubPanel:OnBtnbagquickClicked()
  if #self.m_needItemList > 0 then
    StackPopup:Push(UIDefines.ID_FORM_POPUPQUICKBAG, {
      quickBagType = ItemManager.ItemQuickUseType.HeroLevelUp,
      costList = self.m_needItemList
    })
  end
end

return HeroLvUpgradeSubPanel
