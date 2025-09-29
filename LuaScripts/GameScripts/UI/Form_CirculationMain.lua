local Form_CirculationMain = class("Form_CirculationMain", require("UI/UIFrames/Form_CirculationMainUI"))
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local MaxCirculationID = 9
local MaxResonationID = 6
local MAX_SLOT_NUM = 5
local TabType = {Circulation = 1, Resonance = 2}

function Form_CirculationMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, nil, nil, nil, nil)
  self.TabCfg = {
    [TabType.Circulation] = {
      selectNode = self.m_tab_culation_select,
      unSelectNode = self.m_tab_culation_unselect,
      panelNode = self.m_culation
    },
    [TabType.Resonance] = {
      selectNode = self.m_tab_resonate_select,
      unSelectNode = self.m_tab_resonate_unselect,
      panelNode = self.m_resonate
    }
  }
end

function Form_CirculationMain:OnActive()
  self.m_initTab = TabType.Resonance
  self.super.OnActive(self)
  self:AddEventListeners()
  self:CheckRegisterRedDot()
  self:FreshData()
  self:FreshUI()
  self:PlayVoiceOnFirstEnter()
end

function Form_CirculationMain:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:UnRegisterAllRedDotItem()
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
end

function Form_CirculationMain:OnOpen()
  self.super.OnOpen(self)
  ReportManager:ReportSystemModuleOpen("Form_CirculationMain")
end

function Form_CirculationMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CirculationMain:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    if tParam.isCirculation then
      self.m_initTab = TabType.Circulation
    end
    self.m_csui.m_param = nil
  end
end

function Form_CirculationMain:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_CirculationUpgrade", handler(self, self.OnUpgradeBack))
  self:addEventListener("eGameEvent_Hero_CirculationCareerUpgrade", handler(self, self.OnUpgradeBack))
  self:addEventListener("eGameEvent_Hero_SetCirculationCareerHero", handler(self, self.OnUpgradeBack))
end

function Form_CirculationMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CirculationMain:OnUpgradeBack()
  self:FreshShowCirculationInfo()
  self:FreshShowResonationInfo()
end

function Form_CirculationMain:FreshUI()
  self:OnTabClk(self.m_initTab)
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Circulation)
  if openFlag ~= true then
    self.m_tab_culation_lock:SetActive(true)
    self.m_tab_culation_unselect:SetActive(false)
  else
    self.m_tab_culation_lock:SetActive(false)
    self.m_tab_culation_unselect:SetActive(true)
  end
end

function Form_CirculationMain:CheckRegisterRedDot()
  for i = 1, MaxCirculationID do
    local redDotNode = self["m_pnl_red_dot" .. i]
    if redDotNode then
      self:RegisterOrUpdateRedDotItem(redDotNode, RedDotDefine.ModuleType.HeroCirculationUp, i)
    end
    local lightCircleNode = self["m_hero_circulation_red_dot" .. i]
    if lightCircleNode then
      self:RegisterOrUpdateRedDotItem(lightCircleNode, RedDotDefine.ModuleType.HeroCirculationUp, i)
    end
  end
  for i = 1, MaxResonationID do
    local redDotNode = self["m_img_up_" .. i]
    if redDotNode then
      self:RegisterOrUpdateRedDotItem(redDotNode, RedDotDefine.ModuleType.HeroCirculationCareerUp, i)
    end
  end
  self:RegisterOrUpdateRedDotItem(self.m_img_RedDot_Resonate, RedDotDefine.ModuleType.HeroCirculationCareerEntry)
  self:RegisterOrUpdateRedDotItem(self.m_img_RedDot_Culation, RedDotDefine.ModuleType.HeroCirculationEntry)
end

function Form_CirculationMain:FreshShowCirculationInfo()
  for tempID = 1, MaxCirculationID do
    local tempLv = HeroManager:GetCirculationLvByID(tempID)
    local txtLv = self[string.format("m_txt_lv%d_Text", tempID)]
    txtLv.text = string.format(ConfigManager:GetCommonTextById(20033), tempLv)
  end
end

function Form_CirculationMain:OnCirculationClk(circulationID)
  if not circulationID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_CIRCULATIONPOP, {circulationID = circulationID})
end

function Form_CirculationMain:OnBtnCirculation1Clicked()
  self:OnCirculationClk(1)
end

function Form_CirculationMain:OnBtnCirculation2Clicked()
  self:OnCirculationClk(2)
end

function Form_CirculationMain:OnBtnCirculation3Clicked()
  self:OnCirculationClk(3)
end

function Form_CirculationMain:OnBtnCirculation4Clicked()
  self:OnCirculationClk(4)
end

function Form_CirculationMain:OnBtnCirculation5Clicked()
  self:OnCirculationClk(5)
end

function Form_CirculationMain:OnBtnCirculation6Clicked()
  self:OnCirculationClk(6)
end

function Form_CirculationMain:OnBtnCirculation7Clicked()
  self:OnCirculationClk(7)
end

function Form_CirculationMain:OnBtnCirculation8Clicked()
  self:OnCirculationClk(8)
end

function Form_CirculationMain:OnBtnCirculation9Clicked()
  self:OnCirculationClk(9)
end

function Form_CirculationMain:IsFullScreen()
  return true
end

function Form_CirculationMain:PlayVoiceOnFirstEnter()
  local closeVoice = ConfigManager:GetGlobalSettingsByKey("CirculationVoice")
  CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playingId = nil
  end)
end

function Form_CirculationMain:OnBtnitem1Clicked()
  StackPopup:Push(UIDefines.ID_FORM_CIRCULATIONRESONANCEPOP, {careerID = 1})
end

function Form_CirculationMain:OnBtnitem2Clicked()
  StackPopup:Push(UIDefines.ID_FORM_CIRCULATIONRESONANCEPOP, {careerID = 2})
end

function Form_CirculationMain:OnBtnitem3Clicked()
  StackPopup:Push(UIDefines.ID_FORM_CIRCULATIONRESONANCEPOP, {careerID = 3})
end

function Form_CirculationMain:OnBtnitem4Clicked()
  StackPopup:Push(UIDefines.ID_FORM_CIRCULATIONRESONANCEPOP, {careerID = 4})
end

function Form_CirculationMain:OnBtnitem5Clicked()
  StackPopup:Push(UIDefines.ID_FORM_CIRCULATIONRESONANCEPOP, {careerID = 5})
end

function Form_CirculationMain:OnBtnitem6Clicked()
  StackPopup:Push(UIDefines.ID_FORM_CIRCULATIONRESONANCEPOP, {careerID = 6})
end

function Form_CirculationMain:FreshShowResonationInfo()
  for tempID = 1, MaxResonationID do
    local tempLv = HeroManager:GetCirculationCareerLvByID(tempID)
    local heroList = HeroManager:GetLocationHeroByCareerID(tempID)
    local txtLv = self[string.format("m_txt_lv_%d_Text", tempID)]
    local txtName = self[string.format("m_txt_job_name_%d_Text", tempID)]
    local careerCfg = CareerCfgIns:GetValue_ByCareerID(tempID)
    local tempName = careerCfg.m_mCareerName
    self:FreshShowLocationInfo(tempID, heroList)
    txtName.text = tempName
    txtLv.text = string.format(ConfigManager:GetCommonTextById(20033), tempLv)
  end
end

function Form_CirculationMain:FreshShowLocationInfo(careerID, heroList)
  for PosID = 1, MAX_SLOT_NUM do
    local fillObj = self[string.format("m_yellow_%d_%d", careerID, PosID)]
    local emptyObj = self[string.format("m_white_%d_%d", careerID, PosID)]
    UILuaHelper.SetActive(fillObj, false)
    UILuaHelper.SetActive(emptyObj, false)
    local lock, _ = HeroManager:GetCareerLocationLock(careerID, PosID)
    if not lock then
      if heroList[PosID] then
        UILuaHelper.SetActive(fillObj, true)
      else
        UILuaHelper.SetActive(emptyObj, true)
      end
    end
  end
end

function Form_CirculationMain:ChangeTabShow(tabType)
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

function Form_CirculationMain:OnTabculationClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Circulation)
  if openFlag then
    self:OnTabClk(TabType.Circulation)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
  end
end

function Form_CirculationMain:OnTabresonateClicked()
  self:OnTabClk(TabType.Resonance)
end

function Form_CirculationMain:OnTabClk(tabType)
  if not TabType then
    return
  end
  if self.m_curTabType == tabType then
    return
  end
  if tabType == TabType.Circulation then
    self:FreshShowCirculationInfo()
    self.m_widgetBtnBack:SetExplainID(1114)
  else
    self:FreshShowResonationInfo()
    self.m_widgetBtnBack:SetExplainID(1261)
  end
  self:ChangeTabShow(tabType)
end

local fullscreen = true
ActiveLuaUI("Form_CirculationMain", Form_CirculationMain)
return Form_CirculationMain
