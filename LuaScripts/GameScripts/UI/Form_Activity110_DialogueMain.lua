local Form_Activity110_DialogueMain = class("Form_Activity110_DialogueMain", require("UI/UIFrames/Form_Activity110_DialogueMainUI"))

function Form_Activity110_DialogueMain:SetInitParam(param)
end

function Form_Activity110_DialogueMain:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClick),
    parentLua = self
  }
  self.m_luaextensionInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scroll_extension_InfinityGrid, "LamiaLevel/UI110NormalLevelItem", initGridData)
  self.sSubPanelName = "LevelDetail110SubPanel"
end

function Form_Activity110_DialogueMain:OnActive()
  self.super.OnActive(self)
end

function Form_Activity110_DialogueMain:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity110_DialogueMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity110_DialogueMain:FreshUI()
  Form_Activity110_DialogueMain.super.FreshUI(self)
  self:FreshDegreeLevelList()
  self.m_curDegreeIndex = self.m_curDegreeIndex or self:GetChooseIndex() or 1
  self:FreshLevelTab(self.m_curDegreeIndex)
end

function Form_Activity110_DialogueMain:OnBtnNormalClicked()
  if self.m_curDegreeIndex == self.LevelDegree.Normal then
    return
  end
  self:FreshLevelTab(self.LevelDegree.Normal)
  self.m_bg_nml:SetActive(true)
  self.m_hard_bg:SetActive(false)
  UILuaHelper.PlayAnimationByName(self.m_scroll_extension, "Activity110_LevelMain_List_in")
end

function Form_Activity110_DialogueMain:OnBtnHardClicked()
  if self.m_curDegreeIndex == self.LevelDegree.Hard then
    return
  end
  if self.m_isHarLock then
    local clientMsgStr = ConfigManager:GetClientMessageTextById(40039)
    clientMsgStr = string.CS_Format(clientMsgStr, self:GetHardLevelUnlockStr(), self:GetHardTimeUnlockStr())
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, clientMsgStr)
    return
  end
  LevelHeroLamiaActivityManager:SetActivitySubEnter(self.DegreeCfgTab[self.LevelDegree.Hard].activitySubID)
  self:FreshLevelTab(self.LevelDegree.Hard)
  LocalDataManager:SetIntSimple("HeroActDialogueMainHardEntry" .. self.m_activityID, 1, true)
  self.m_hard_new:SetActive(false)
  self.m_bg_nml:SetActive(false)
  self.m_hard_bg:SetActive(true)
  UILuaHelper.PlayAnimationByName(self.m_scroll_extension, "Activity110_LevelMain_List_in")
end

function Form_Activity110_DialogueMain:OnBtnbuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

function Form_Activity110_DialogueMain:OnBtnCollectClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY110_DIALOGUECOLLECTION, {
    activityID = self.m_activityID,
    activitySubID = self.DegreeCfgTab[self.LevelDegree.Normal].activitySubID,
    bIsSecondHalf = false
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity110_DialogueMain", Form_Activity110_DialogueMain)
return Form_Activity110_DialogueMain
