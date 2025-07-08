local UISubPanelBase = require("UI/Common/UISubPanelBase")
local HeroBreakSubPanel = class("HeroBreakSubPanel", UISubPanelBase)
local MaxStr = "Max"
local RBreakNum = HeroManager.RBreakNum
local SRBreakNum = HeroManager.SRBreakNum
local SSRBreakNum = HeroManager.SSRBreakNum
local DefaultCostItemNum = 1
local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local string_format = string.format
local ipairs = _ENV.ipairs
local EnterAnimStr = "lv_in"
local OutAnimStr = "lv_out"

function HeroBreakSubPanel:OnInit()
  self.m_curShowHeroData = nil
  self.m_allHeroList = nil
  self.m_curChooseHeroIndex = nil
  self.m_heroBreakCfgList = nil
  self.m_curHeroBreakNum = nil
  if self.m_initData then
  end
  self.m_costItemWidget = self:createCommonItem(self.m_common_item)
  self.m_costItemWidget:SetItemIconClickCB(function()
    self:OnItemClk()
  end)
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_outAnimTimer = nil
  self:AddEventListeners()
end

function HeroBreakSubPanel:OnDestroy()
  HeroBreakSubPanel.super.OnDestroy(self)
  self:RemoveAllEventListeners()
  if self.m_outAnimTimer then
    TimeService:KillTimer(self.m_outAnimTimer)
    self.m_outAnimTimer = nil
  end
end

function HeroBreakSubPanel:OnFreshData()
  self.m_curShowHeroData = self.m_panelData.heroData
  self.m_allHeroList = self.m_panelData.allHeroList
  self.m_curChooseHeroIndex = self.m_panelData.chooseIndex
  self:FreshLevelUpData()
  self:FreshUI()
end

function HeroBreakSubPanel:FreshLevelUpData()
  if not self.m_curShowHeroData then
    return
  end
  self.m_curHeroBreakNum = self.m_curShowHeroData.serverData.iBreak or 0
  self.m_curHeroLv = self.m_curShowHeroData.serverData.iLevel
  self.m_heroBreakCfgList = {}
  self.m_maxBreakNum = 0
  local limitBreakTemplateID = self.m_curShowHeroData.characterCfg.m_Quality
  if limitBreakTemplateID == nil or limitBreakTemplateID == 0 then
    return
  end
  local allCharacterLimitBreaks = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplate(limitBreakTemplateID)
  for _, breakCfg in pairs(allCharacterLimitBreaks) do
    self.m_heroBreakCfgList[breakCfg.m_LimitBreakLevel] = breakCfg
    if breakCfg.m_LimitBreakLevel > self.m_maxBreakNum then
      self.m_maxBreakNum = breakCfg.m_LimitBreakLevel
    end
  end
end

function HeroBreakSubPanel:GetAfterBreakNum()
  local maxBreakNum = self.m_maxBreakNum
  local afterBreakNum = self.m_curHeroBreakNum + 1
  if maxBreakNum < afterBreakNum then
    afterBreakNum = maxBreakNum
  end
  return afterBreakNum
end

function HeroBreakSubPanel:IsCanBreak()
  local isBelowBreakNum = false
  local maxBreakNum = self.m_maxBreakNum
  if maxBreakNum > self.m_curHeroBreakNum then
    isBelowBreakNum = true
  end
  local haveEnough = false
  local costItemID = self.m_curShowHeroData.characterCfg.m_LimitBreakItem
  if costItemID then
    local curHaveNum = ItemManager:GetItemNum(costItemID, true)
    if curHaveNum >= DefaultCostItemNum then
      haveEnough = true
    end
  end
  return isBelowBreakNum and haveEnough
end

function HeroBreakSubPanel:GetCostItemName()
  local costItemID = self.m_curShowHeroData.characterCfg.m_LimitBreakItem
  local itemCfg = ItemManager:GetItemConfigById(costItemID)
  if not itemCfg then
    return
  end
  return itemCfg.m_mItemName
end

function HeroBreakSubPanel:IsHeroOverQualityBreak()
  if not self.m_curShowHeroData then
    return
  end
  local breakNum = self.m_curShowHeroData.serverData.iBreak or 0
  local heroCfg = self.m_curShowHeroData.characterCfg
  local quality = heroCfg.m_Quality
  local qualityLimitBreakNum = RBreakNum
  if quality == HeroManager.QualityType.R then
    qualityLimitBreakNum = RBreakNum
  elseif quality == HeroManager.QualityType.SR then
    qualityLimitBreakNum = SRBreakNum
  else
    qualityLimitBreakNum = SSRBreakNum
  end
  return breakNum >= qualityLimitBreakNum
end

function HeroBreakSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_Break", handler(self, self.OnHeroBreak))
end

function HeroBreakSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function HeroBreakSubPanel:OnHeroBreak(param)
  if not param then
    return
  end
  local heroID = param.heroID
  local heroBreakNum = param.heroBreak
  if heroID == self.m_curShowHeroData.serverData.iHeroId then
    local beforeBreakNum = self.m_curHeroBreakNum
    self:FreshLevelUpData()
    self:FreshBreakStatus()
    self:FreshShowBeforeUp()
    self:FreshShowAfterUp()
    self:FreshCostItem()
    self:FreshShowBreak()
    local showBreakNum = heroBreakNum <= HeroManager.SSRBreakNum and heroBreakNum or HeroManager.BreakShowMaxNum
    local breakVideoStr = HeroManager.BreakThroughVideoPreStr .. showBreakNum
    GlobalManagerIns:TriggerWwiseBGMState(49)
    UILuaHelper.PlayFromAddRes(breakVideoStr, "", true, function()
      StackPopup:Push(UIDefines.ID_FORM_HEROBREAKTHROUGH, {
        heroData = self.m_curShowHeroData,
        beforeBreakNum = beforeBreakNum,
        afterBreakNum = heroBreakNum
      })
    end, CS.UnityEngine.ScaleMode.ScaleToFit, false)
  end
end

function HeroBreakSubPanel:FreshUI()
  if not self.m_curShowHeroData then
    return
  end
  self:FreshBreakStatus()
  self:FreshShowBeforeUp()
  self:FreshShowAfterUp()
  self:FreshCostItem()
  self:FreshShowBreak()
  self:ResetAnimIn()
end

function HeroBreakSubPanel:FreshBreakStatus()
  local breakNum = self.m_curShowHeroData.serverData.iBreak or 0
  local afterBreakNum = self:GetAfterBreakNum()
  local heroCfg = self.m_curShowHeroData.characterCfg
  local quality = heroCfg.m_Quality
  if quality == HeroManager.QualityType.R then
    UILuaHelper.SetActive(self.m_breakthrough_progress_SR, false)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SSR, false)
    UILuaHelper.SetActive(self.m_breakthrough_afterprogress_SR, false)
    UILuaHelper.SetActive(self.m_breakthrough_afterprogress_SSR, false)
    UILuaHelper.SetActive(self.m_img_break_SSR4, false)
    UILuaHelper.SetActive(self.m_img_afterbreak_SSR4, false)
    UILuaHelper.SetActive(self.m_img_bg_afterprogress, true)
    UILuaHelper.SetActive(self.m_img_bg_progress, true)
  elseif quality == HeroManager.QualityType.SR then
    UILuaHelper.SetActive(self.m_breakthrough_progress_SR, true)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SSR, false)
    UILuaHelper.SetActive(self.m_breakthrough_afterprogress_SR, true)
    UILuaHelper.SetActive(self.m_breakthrough_afterprogress_SSR, false)
    UILuaHelper.SetActive(self.m_img_break_SSR4, false)
    UILuaHelper.SetActive(self.m_img_afterbreak_SSR4, false)
    UILuaHelper.SetActive(self.m_img_bg_afterprogress, true)
    UILuaHelper.SetActive(self.m_img_bg_progress, true)
    for i = 1, SRBreakNum do
      UILuaHelper.SetActive(self["m_img_break_SR" .. i], i <= breakNum)
      UILuaHelper.SetActive(self["m_img_afterbreak_SR" .. i], i <= afterBreakNum)
    end
  else
    UILuaHelper.SetActive(self.m_breakthrough_progress_SR, false)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SSR, breakNum <= SSRBreakNum)
    UILuaHelper.SetActive(self.m_breakthrough_afterprogress_SR, false)
    UILuaHelper.SetActive(self.m_breakthrough_afterprogress_SSR, breakNum < SSRBreakNum)
    for i = 1, SSRBreakNum do
      UILuaHelper.SetActive(self["m_img_break_SSR" .. i], i <= breakNum)
      UILuaHelper.SetActive(self["m_img_afterbreak_SSR" .. i], i <= afterBreakNum)
    end
    if breakNum > SSRBreakNum then
      UILuaHelper.SetActive(self.m_img_break_SSR4, true)
      local overBreakNum = breakNum - SSRBreakNum
      self.m_txt_break_num_Text.text = UIUtil:ArabToRomaNum(overBreakNum)
      local maxNum = self.m_maxBreakNum - SSRBreakNum
      for i = 1, maxNum do
        if not utils.isNull(self["m_pnl_break_light" .. i]) then
          UILuaHelper.SetActive(self["m_pnl_break_light" .. i], i <= breakNum - SSRBreakNum)
        end
      end
    else
      UILuaHelper.SetActive(self.m_img_break_SSR4, false)
    end
    if afterBreakNum > SSRBreakNum then
      UILuaHelper.SetActive(self.m_img_afterbreak_SSR4, true)
      UILuaHelper.SetActive(self.m_img_bg_afterprogress, false)
      UILuaHelper.SetActive(self.m_img_bg_progress, afterBreakNum <= SSRBreakNum + 1)
      local overAfterBreakNum = afterBreakNum - SSRBreakNum
      self.m_txt_afterbreak_num_Text.text = UIUtil:ArabToRomaNum(overAfterBreakNum)
      local maxNum = self.m_maxBreakNum - SSRBreakNum
      for i = 1, maxNum do
        if not utils.isNull(self["m_pnl_afterbreak_light" .. i]) then
          UILuaHelper.SetActive(self["m_pnl_afterbreak_light" .. i], i <= breakNum + 1 - SSRBreakNum)
        end
      end
    else
      UILuaHelper.SetActive(self.m_img_afterbreak_SSR4, false)
      UILuaHelper.SetActive(self.m_img_bg_afterprogress, true)
      UILuaHelper.SetActive(self.m_img_bg_progress, true)
    end
  end
end

function HeroBreakSubPanel:FreshShowBeforeUp()
  local breakNum = self.m_curHeroBreakNum
  local curBreakCfg = self.m_heroBreakCfgList[breakNum]
  if not curBreakCfg then
    return
  end
  local curBreakMaxLv = curBreakCfg.m_MaxLevel
  self.m_txt_break_before_num_Text.text = curBreakMaxLv
  local heroID = self.m_curShowHeroData.characterCfg.m_HeroID
  local heroServerData = self.m_curShowHeroData.serverData
  local heroAttrTab = self.m_heroAttr:GetHeroAttrByParam(heroID, {
    iBreak = self.m_curHeroBreakNum,
    iLevel = self.m_curHeroLv
  }, heroServerData)
  for i, _ in ipairs(AttrBaseShowCfg) do
    local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(i)
    UILuaHelper.SetAtlasSprite(self[string_format("m_before_attr_icon%d_Image", i)], propertyIndexCfg.m_PropertyIcon .. "_02")
    self[string_format("m_before_attr_name%d_Text", i)].text = propertyIndexCfg.m_mCNName
    self[string_format("m_before_attr_num%d_Text", i)].text = BigNumFormat(heroAttrTab[propertyIndexCfg.m_ENName] or 0)
  end
  local isOverQualityBreak = self:IsHeroOverQualityBreak()
  UILuaHelper.SetActive(self.m_pnl_breakthrough_lv_upgrade, not isOverQualityBreak)
  UILuaHelper.SetActive(self.m_pnl_breakthrough_lv_top, isOverQualityBreak)
  if isOverQualityBreak then
    self.m_txt_top_num_Text.text = curBreakMaxLv
  end
end

function HeroBreakSubPanel:FreshShowAfterUp()
  local afterBreakNum = self:GetAfterBreakNum()
  local afterBreakCfg = self.m_heroBreakCfgList[afterBreakNum]
  if not afterBreakCfg then
    return
  end
  local afterBreakMaxLvNum = afterBreakCfg.m_MaxLevel
  self.m_txt_break_after_num_Text.text = afterBreakMaxLvNum
  local heroID = self.m_curShowHeroData.characterCfg.m_HeroID
  local heroAttrTab = self.m_heroAttr:GetHeroAttrByParam(heroID, {
    iBreak = afterBreakNum,
    iLevel = self.m_curHeroLv
  }, self.m_curShowHeroData.serverData)
  for i, _ in ipairs(AttrBaseShowCfg) do
    local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(i)
    local afterAttrStr = BigNumFormat(heroAttrTab[propertyIndexCfg.m_ENName] or 0) or MaxStr
    self[string_format("m_after_attr_num%d_Text", i)].text = afterAttrStr
  end
end

function HeroBreakSubPanel:FreshCostItem()
  if not self.m_curShowHeroData then
    return
  end
  local costItemID = self.m_curShowHeroData.characterCfg.m_LimitBreakItem
  if not costItemID then
    return
  end
  if self.m_curHeroBreakNum >= self.m_maxBreakNum then
    self.m_costItemWidget:SetActive(false)
    UILuaHelper.SetActive(self.m_pnl_slider, false)
  else
    self.m_costItemWidget:SetActive(true)
    local processData = ResourceUtil:GetProcessRewardData({iID = costItemID, iNum = 0})
    self.m_costItemWidget:SetItemInfo(processData)
    local curHaveNum = ItemManager:GetItemNum(costItemID)
    UILuaHelper.SetActive(self.m_pnl_slider, true)
    local progressNum = curHaveNum / DefaultCostItemNum
    if 1 < progressNum then
      progressNum = 1
    end
    self.m_img_slider_Image.fillAmount = progressNum
    self.m_txt_break_Text.text = string_format("%s/%s", curHaveNum, DefaultCostItemNum)
  end
end

function HeroBreakSubPanel:FreshShowBreak()
  local isCanBreak = self:IsCanBreak()
  UILuaHelper.SetActive(self.m_btn_Break, isCanBreak)
  UILuaHelper.SetActive(self.m_btn_Cannot_Break, not isCanBreak)
end

function HeroBreakSubPanel:ShowEnterInAnim()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, EnterAnimStr)
end

function HeroBreakSubPanel:ShowTabInAnim()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, EnterAnimStr)
end

function HeroBreakSubPanel:ShowOutAnim(backFun)
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

function HeroBreakSubPanel:ResetAnimIn()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.ResetAnimationByName(self.m_rootObj, EnterAnimStr, -1)
end

function HeroBreakSubPanel:OnItemClk()
  if not self.m_curShowHeroData then
    return
  end
  local itemID = self.m_curShowHeroData.characterCfg.m_LimitBreakItem
  if not itemID then
    return
  end
  local haveNum = ItemManager:GetItemNum(itemID) or 0
  utils.openItemDetailPop({iID = itemID, iNum = haveNum})
end

function HeroBreakSubPanel:OnBtnBreakClicked()
  if not self.m_curShowHeroData then
    return
  end
  local heroID = self.m_curShowHeroData.serverData.iHeroId
  HeroManager:ReqHeroBreak(heroID)
end

function HeroBreakSubPanel:OnBtnCannotBreakClicked()
  StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, 40027)
end

return HeroBreakSubPanel
