local Form_HeroBreakThroughPop = class("Form_HeroBreakThroughPop", require("UI/UIFrames/Form_HeroBreakThroughPopUI"))
local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")

function Form_HeroBreakThroughPop:SetInitParam(param)
end

function Form_HeroBreakThroughPop:AfterInit()
  self.super.AfterInit(self)
  self.m_heroBreakCfgList = {}
  self.m_maxBreakNum = 0
  self.m_breakUpPanelData = {
    panelRoot = self.m_break_subPanel,
    subPanelName = "HeroBreakSubPanel",
    subPanelLua = nil,
    backFun = nil
  }
end

function Form_HeroBreakThroughPop:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
  self:AddEventListeners()
end

function Form_HeroBreakThroughPop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_HeroBreakThroughPop:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_breakUpPanelData and self.m_breakUpPanelData.subPanelLua then
    self.m_breakUpPanelData.subPanelLua:dispose()
    self.m_breakUpPanelData.subPanelLua = nil
  end
end

function Form_HeroBreakThroughPop:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_allHeroList = tParam.heroDataList
    self.m_curChooseHeroIndex = tParam.chooseHeroIndex
    self.m_curShowHeroData = self.m_allHeroList[self.m_curChooseHeroIndex]
    self.m_isJustOne = #self.m_allHeroList <= 1
    self:FreshBreakNum()
    self.m_csui.m_param = nil
  end
end

function Form_HeroBreakThroughPop:ClearData()
end

function Form_HeroBreakThroughPop:FreshBreakNum()
  if not self.m_curShowHeroData then
    return
  end
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

function Form_HeroBreakThroughPop:IsBreakMax()
  local breakNum = self.m_curShowHeroData.serverData.iBreak or 0
  if breakNum >= self.m_maxBreakNum then
    return true
  end
  return false
end

function Form_HeroBreakThroughPop:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_Break", handler(self, self.OnHeroBreak))
end

function Form_HeroBreakThroughPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroBreakThroughPop:OnHeroBreak(param)
  if not param then
    return
  end
  local heroID = param.heroID
  if heroID == self.m_curShowHeroData.serverData.iHeroId then
    self:FreshBreakNum()
    if self:IsBreakMax() then
      self:CloseForm()
    end
  end
end

function Form_HeroBreakThroughPop:FreshUI()
  self:FreshCurTabSubPanelInfo()
  self:CheckShowEnterAnim()
end

function Form_HeroBreakThroughPop:FreshCurTabSubPanelInfo()
  if not self.m_curShowHeroData then
    return
  end
  if self.m_breakUpPanelData.subPanelLua then
    self.m_breakUpPanelData.subPanelLua:SetActive(true)
    self.m_breakUpPanelData.subPanelLua:FreshData({
      heroData = self.m_curShowHeroData,
      allHeroList = self.m_allHeroList,
      chooseIndex = self.m_curChooseHeroIndex
    })
    if self.m_breakUpPanelData.subPanelLua.OnActivePanel then
      self.m_breakUpPanelData.subPanelLua:OnActivePanel()
    end
  else
    local subPanelLua = SubPanelManager:LoadSubPanelWithPanelRoot(self.m_breakUpPanelData.subPanelName, self.m_breakUpPanelData.panelRoot, self, {}, {
      heroData = self.m_curShowHeroData,
      allHeroList = self.m_allHeroList,
      chooseIndex = self.m_curChooseHeroIndex,
      initData = {}
    })
    self.m_breakUpPanelData.subPanelLua = subPanelLua
    if subPanelLua then
      self.m_breakUpPanelData.subPanelLua = subPanelLua
      if self.m_breakUpPanelData.subPanelLua.isNeedShowEnterAnim and subPanelLua.ShowEnterInAnim then
        subPanelLua:ShowEnterInAnim()
        self.m_breakUpPanelData.subPanelLua.isNeedShowEnterAnim = false
      end
      if self.m_breakUpPanelData.subPanelLua.isNeedShowTabAnim and subPanelLua.ShowTabInAnim then
        subPanelLua:ShowTabInAnim()
        self.m_breakUpPanelData.subPanelLua.isNeedShowTabAnim = false
      end
      if subPanelLua.OnActivePanel then
        subPanelLua:OnActivePanel()
      end
    end
  end
end

function Form_HeroBreakThroughPop:CheckShowEnterAnim()
  local subPanelLua = self.m_breakUpPanelData.subPanelLua
  if subPanelLua then
    if subPanelLua.ShowEnterInAnim then
      subPanelLua:ShowEnterInAnim()
    end
  else
    self.m_breakUpPanelData.isNeedShowEnterAnim = true
  end
end

function Form_HeroBreakThroughPop:ShowFormEnterAnim()
end

function Form_HeroBreakThroughPop:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_HeroBreakThroughPop:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_HeroBreakThroughPop:OnBtnsymbolClicked()
  utils.popUpDirectionsUI({tipsID = 1111})
end

function Form_HeroBreakThroughPop:IsOpenGuassianBlur()
  return true
end

function Form_HeroBreakThroughPop:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  for i = 1, HeroManager.BreakShowMaxNum do
    vResourceExtra[#vResourceExtra + 1] = {
      sName = HeroManager.BreakThroughVideoPreStr .. i .. ".mp4",
      eType = DownloadManager.ResourceType.Video
    }
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_HeroBreakThroughPop", Form_HeroBreakThroughPop)
return Form_HeroBreakThroughPop
