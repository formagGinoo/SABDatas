local Form_CirculationMain = class("Form_CirculationMain", require("UI/UIFrames/Form_CirculationMainUI"))
local MaxCirculationID = 9

function Form_CirculationMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, nil, nil, nil, 1114)
end

function Form_CirculationMain:OnActive()
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
    self.m_csui.m_param = nil
  end
end

function Form_CirculationMain:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_CirculationUpgrade", handler(self, self.OnUpgradeBack))
end

function Form_CirculationMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CirculationMain:OnUpgradeBack()
  self:FreshShowCirculationInfo()
end

function Form_CirculationMain:FreshUI()
  self:FreshShowCirculationInfo()
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

local fullscreen = true
ActiveLuaUI("Form_CirculationMain", Form_CirculationMain)
return Form_CirculationMain
