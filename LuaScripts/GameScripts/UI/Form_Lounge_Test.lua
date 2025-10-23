local Form_Lounge_Test = class("Form_Lounge_Test", require("UI/UIFrames/Form_Lounge_TestUI"))

function Form_Lounge_Test:SetInitParam(param)
end

function Form_Lounge_Test:AfterInit()
  self.super.AfterInit(self)
  UILuaHelper.SetActive(self.m_common_top_back, true)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1259)
  local InitData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_loungeChangeInfinityGrid = self:CreateInfinityGrid(self.m_item_list_InfinityGrid, "Lounge/UILoungeChangeHeroItem", InitData)
end

function Form_Lounge_Test:OnActive()
  self.super.OnActive(self)
  self.m_characterSubPanel = nil
  self.m_playSFXStr = ""
  local tParam = self.m_csui.m_param
  self.m_unlockHeroList = {}
  self:KillTimer()
  local heroId
  if not tParam or not tParam.heroId then
    if LoungeManager.m_curLoungeHeroId and LoungeManager.m_curLoungeHeroId ~= 0 then
      heroId = LoungeManager.m_curLoungeHeroId
    else
      heroId = self:GetOneUnlockHeroId()
    end
  else
    local isUnlock = LoungeManager:CheckHeroLoungeUnlockById(tParam.heroId)
    if isUnlock then
      heroId = tParam.heroId
    else
      heroId = self:GetOneUnlockHeroId()
    end
  end
  LoungeManager.m_curLoungeHeroId = heroId
  LocalDataManager:SetIntSimple("Lounge_CurHeroId", heroId)
  self:AddEventListeners()
  local isOpen = LoungeManager:CheckLoungeUnlock()
  if not isOpen or not heroId then
    self:RefreshUnlockUI(true)
    self.bIsCheckTips = false
    return
  end
  self:RefreshUnlockUI(false)
  self:ChangeHero(heroId)
end

function Form_Lounge_Test:GetOneUnlockHeroId()
  local cfg = LoungeManager:GetOneLoungeHeroCfg()
  if not cfg then
    return
  end
  return cfg.m_ID
end

function Form_Lounge_Test:OnInactive()
  self.super.OnInactive(self)
  if self.m_characterSubPanel then
    self.m_characterSubPanel:OnInactive()
  end
  self:KillTimer()
  self:RemoveAllEventListeners()
  self:ReportClientMessage()
  self:DestroyForm()
end

function Form_Lounge_Test:RefreshUnlockUI(showLock)
  UILuaHelper.SetActive(self.m_pnl_btn, not showLock)
  UILuaHelper.SetActive(self.m_pnl_choose, showLock)
  UILuaHelper.SetActive(self.m_pnl_dialogue, not showLock)
  UILuaHelper.SetActive(self.m_img_bg, showLock)
  UILuaHelper.SetActive(self.m_btnShowUI, not showLock)
  UILuaHelper.SetActive(self.m_menupop, false)
  UILuaHelper.SetActive(self.m_ui_panel, true)
  local list = {}
  local heroList = LoungeManager:GetHeroChangeList()
  for i, v in ipairs(heroList) do
    local tab = {
      heroId = v.m_ID,
      unlockLimitBreakLevel = v.m_UnlockLimitBreakLevel,
      name = v.m_mCharName,
      isUnlock = false,
      sortId = v.m_Sort
    }
    list[#list + 1] = tab
  end
  table.sort(list, function(a, b)
    return a.sortId < b.sortId
  end)
  self.m_unlockHeroList = list
  self.m_loungeChangeInfinityGrid:ShowItemList(list)
end

function Form_Lounge_Test:ChangeHero(heroId)
  if self.m_curLoungeHeroId ~= heroId then
    self.m_curLoungeHeroId = heroId
    self:CreateHeroSubPanel(self.m_curLoungeHeroId)
  end
  self:HidePlotPanel()
end

function Form_Lounge_Test:CreateHeroSubPanel(heroId)
  if self.m_characterSubPanel ~= nil then
    self.m_characterSubPanel:OnInactive()
    self:RemoveSubPanel(self.m_characterSubPanel)
    self.m_characterSubPanel = nil
  end
  local cfg = LoungeManager:GetLoungeCharCfgById(heroId)
  if not cfg and cfg.m_UIPrefab ~= "" then
    return
  end
  self:CreateSubPanel(cfg.m_UIPrefab, self.m_subpanel, self, nil, nil, function(panel)
    self.m_characterSubPanel = panel
    panel:OnActive()
    self:ReqLoungeBond()
  end)
end

function Form_Lounge_Test:ReqLoungeBond()
  local isUnlock = LoungeManager:CheckHeroLoungeUnlockById(self.m_curLoungeHeroId)
  if isUnlock then
    local open = LocalDataManager:GetIntSimple("Lounge_FirstOpen", 0)
    if open == 0 then
      LocalDataManager:SetIntSimple("Lounge_FirstOpen", 1)
      StackPopup:Push(UIDefines.ID_FORM_LOUNGEGUIDEPOP)
    else
      self:CheckReqAttractLoungeBond()
    end
  end
end

function Form_Lounge_Test:CheckReqAttractLoungeBond()
  if LoungeManager:GetLoungeHeroRealStatus(self.m_curLoungeHeroId) ~= LoungeManager.LoungeBondStatus.Bond then
    LoungeManager:ReqAttractLoungeBondCS(self.m_curLoungeHeroId)
  end
  self:SetCheckTipsFlag(true)
end

function Form_Lounge_Test:OnUpdate(dt)
  if self.m_characterSubPanel and self.m_characterSubPanel.OnUpdate then
    self.m_characterSubPanel:OnUpdate(dt)
  end
end

function Form_Lounge_Test:ShowPlotPanel()
  if utils.isNull(self.m_pnl_dialogue) then
    return
  end
  if self.m_showPlotTimer then
    TimeService:KillTimer(self.m_showPlotTimer)
    self.m_showPlotTimer = nil
  end
  self.m_showPlotTimer = TimeService:SetTimer(0.1, 1, function()
    self.m_showPlotTimer = nil
    if self and not utils.isNull(self.m_pnl_dialogue) then
      UILuaHelper.SetActive(self.m_pnl_dialogue, true)
    end
  end)
end

function Form_Lounge_Test:HidePlotPanel()
  if utils.isNull(self.m_pnl_dialogue) then
    return
  end
  if not utils.isNull(self.m_pnl_dialogue) then
    UILuaHelper.SetActive(self.m_pnl_dialogue, false)
  end
  self:StopVoice()
end

function Form_Lounge_Test:ShowPlotTextByStr(str, voice)
  if str and str ~= "" then
    self:ShowPlotPanel()
    self.m_txt_dialogue_Text.text = CS.MultiLanguageManager.Instance:GetPlotText(str .. "_" .. tostring(self.m_curLoungeHeroId))
  else
    UILuaHelper.SetActive(self.m_pnl_dialogue, false)
  end
  if voice and voice ~= "" then
    self.m_playSFXStr = voice
    UILuaHelper.StartPlaySFX(voice, nil, nil, function()
      if self and not utils.isNull(self.m_pnl_dialogue) then
        UILuaHelper.SetActive(self.m_pnl_dialogue, false)
      end
    end)
  end
end

function Form_Lounge_Test:StopVoice()
  if self.m_playSFXStr and self.m_playSFXStr ~= "" then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playSFXStr)
    self.m_playSFXStr = nil
  end
end

function Form_Lounge_Test:KillTimer()
  if self.m_showPlotTimer then
    TimeService:KillTimer(self.m_showPlotTimer)
    self.m_showPlotTimer = nil
  end
  if self.m_showTargetTimer then
    TimeService:KillTimer(self.m_showTargetTimer)
    self.m_showTargetTimer = nil
  end
end

function Form_Lounge_Test:OnDestroy()
  self.super.OnDestroy(self)
  self:StopVoice()
end

function Form_Lounge_Test:OnBackClk()
  self:CloseForm()
end

function Form_Lounge_Test:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_Lounge_Test:IsFullScreen()
  return true
end

function Form_Lounge_Test:AddEventListeners()
  self:addEventListener("eGameEvent_Lounge_ChangeHero", handler(self, self.OnHeroChanged))
  self:addEventListener("eGameEvent_Lounge_GuidePop_Inactive", handler(self, self.CheckReqAttractLoungeBond))
  self:addEventListener("eGameEvent_Lounge_Mark", handler(self, self.OnCompleteStampMark))
  self:addEventListener("eGameEvent_Lounge_LoungeHeroChange_close", handler(self, self.OnLoungeHeroChangeClose))
end

function Form_Lounge_Test:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Lounge_Test:OnHeroChanged()
  local heroId = LoungeManager.m_curLoungeHeroId
  self:ChangeHero(heroId)
end

function Form_Lounge_Test:OnCompleteStampMark(realMark)
  if realMark then
    local oldAttrIdList = LoungeManager:GetBefLvUpAttrsById(self.m_curLoungeHeroId)
    local newAttrIdList, newLv = LoungeManager:GetLoungeAllAttrsId()
    StackPopup:Push(UIDefines.ID_FORM_LOUNGEUPGRADE, {
      level = newLv,
      newPropertyIDList = newAttrIdList,
      propertyIDList = oldAttrIdList
    })
    self:ShowALlUI(true)
    self:ShowMenuPop(false)
  end
end

function Form_Lounge_Test:OnLoungeHeroChangeClose()
  self:SetCheckTipsFlag(true)
end

function Form_Lounge_Test:SetCheckTipsFlag(flag)
  if self.m_characterSubPanel and self.m_characterSubPanel.SetCheckTipsFlag then
    self.m_characterSubPanel:SetCheckTipsFlag(flag)
  end
end

function Form_Lounge_Test:OnBtnhideClicked()
  self:ShowALlUI(false)
end

function Form_Lounge_Test:OnBtnShowUIClicked()
  self:ShowALlUI(true)
end

function Form_Lounge_Test:OnBtnCannothideClicked()
  self:ShowALlUI(true)
end

function Form_Lounge_Test:OnBtnadditionClicked()
  self:SetCheckTipsFlag(false)
  local propertyIDList, lv = LoungeManager:GetLoungeAllAttrsId()
  local params = {level = lv, propertyIDList = propertyIDList}
  StackPopup:Push(UIDefines.ID_FORM_LOUNGEUPGRADEPOP, params)
  self:ShowMenuPop(false)
end

function Form_Lounge_Test:OnBtnswitchClicked()
  self:SetCheckTipsFlag(false)
  StackPopup:Push(UIDefines.ID_FORM_LOUNGEHEROCHANGE)
  self:ShowMenuPop(false)
end

function Form_Lounge_Test:OnBtnhelpClicked()
  if self.m_characterSubPanel ~= nil then
    if self.m_characterSubPanel.ShowGuide then
      self.m_characterSubPanel:ShowGuide()
    else
      StackPopup:Push(UIDefines.ID_FORM_LOUNGEGUIDEPOP2, {
        heroId = self.m_curLoungeHeroId
      })
    end
  end
  self:ShowMenuPop(false)
end

function Form_Lounge_Test:OnBtnguideClicked()
  self:SetCheckTipsFlag(false)
  StackPopup:Push(UIDefines.ID_FORM_LOUNGEGUIDEPOP)
  self:ShowMenuPop(false)
end

function Form_Lounge_Test:OnMenulightClicked()
  self:ShowMenuPop(false)
end

function Form_Lounge_Test:OnMenuClicked()
  self:ShowMenuPop(true)
end

function Form_Lounge_Test:OnBtnresetClicked()
  utils.CheckAndPushCommonTips({
    tipsID = 1265,
    func1 = function()
      self.m_characterSubPanel:ResetGame()
    end
  })
  self:ShowMenuPop(false)
end

function Form_Lounge_Test:ShowMenuPop(flag)
  UILuaHelper.SetActive(self.m_menupop, flag)
  UILuaHelper.SetActive(self.m_menu_light, flag)
  UILuaHelper.SetActive(self.m_menu, not flag)
  local isAllBoned = LoungeManager:CheckAllLoungeHeroIsBoned()
  UILuaHelper.SetActive(self.m_switch_redpoint, not isAllBoned)
end

function Form_Lounge_Test:OnBtnclosemenuClicked()
  self:ShowMenuPop(false)
end

function Form_Lounge_Test:ShowALlUI(flag)
  UILuaHelper.SetActive(self.m_ui_panel, true)
  UILuaHelper.SetActive(self.m_btnCannothide, not flag)
  UILuaHelper.SetActive(self.m_btnShowUI, not flag)
  UILuaHelper.SetActive(self.m_btnhide, flag)
  UILuaHelper.SetActive(self.m_btnhelp, flag)
  UILuaHelper.SetActive(self.m_btnhelp, flag)
  self:ShowMenuPop(false)
  UILuaHelper.SetActive(self.m_menu, flag)
  local isAllBoned = LoungeManager:CheckAllLoungeHeroIsBoned()
  UILuaHelper.SetActive(self.m_new_redpoint_menu, not isAllBoned)
end

function Form_Lounge_Test:ReportClientMessage()
  local _, lv = LoungeManager:GetLoungeAllAttrsId()
  local data = LoungeManager:GetLoungeDataByHeroId(self.m_curLoungeHeroId)
  local parts = ""
  if data and data.vParts then
    for _, v in pairs(data.vParts) do
      parts = parts .. v .. ","
    end
  end
  local params = {
    Hero_id = self.m_curLoungeHeroId,
    Level = lv,
    Parts = parts,
    IsFinish = data.iStatus
  }
  ReportManager:ReportMessage(CS.ReportDataDefines.Client_lounge, params)
end

function Form_Lounge_Test:OnItemClk(index)
  local itemIndex = index
  if not self.m_unlockHeroList[itemIndex] or self.m_unlockHeroList[itemIndex].heroId == 0 then
    return
  end
  local unlock, isLoungeHero, tips = LoungeManager:CheckHeroLoungeUnlockById(self.m_unlockHeroList[itemIndex].heroId)
  if not unlock and tips then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips)
  end
end

local fullscreen = true
ActiveLuaUI("Form_Lounge_Test", Form_Lounge_Test)
return Form_Lounge_Test
