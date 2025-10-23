local Form_Activity112_DialogueMain = class("Form_Activity112_DialogueMain", require("UI/UIFrames/Form_Activity112_DialogueMainUI"))
local LevelDegree = LevelHeroLamiaActivityManager.LevelDegree

function Form_Activity112_DialogueMain:SetInitParam(param)
end

function Form_Activity112_DialogueMain:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClick),
    parentLua = self
  }
  self.m_luaextensionInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scroll_extension_InfinityGrid, "LamiaLevel/UI112NormalLevelItem", initGridData)
  self.sSubPanelName = "LevelDetail112SubPanel"
  self.iClueFormID = UIDefines.ID_FORM_ACTIVITY112_DIALOGUECLUE
end

function Form_Activity112_DialogueMain:OnActive()
  self.super.OnActive(self)
  self:FreshDrawBtn()
  HeroActivityManager:CheckShowEnterAnim(self.m_csui.m_uiGameObject, "Form_Activity112_DialogueMain_ShowAni", "Activity112_LevelMain_in_DailyFirstOpen", "Activity112_LevelMain_in", 347)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(427)
end

function Form_Activity112_DialogueMain:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity112_DialogueMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity112_DialogueMain:FreshUI()
  Form_Activity112_DialogueMain.super.FreshUI(self)
  self:FreshDegreeLevelList()
  self.m_curDegreeIndex = self.m_curDegreeIndex or self:GetChooseIndex() or 1
  self:FreshLevelTab(self.m_curDegreeIndex)
end

function Form_Activity112_DialogueMain:OnBtnNormalClicked()
  if self.m_curDegreeIndex == LevelDegree.Normal then
    return
  end
  self:FreshLevelTab(LevelDegree.Normal)
  self.m_bg_nml:SetActive(true)
  self.m_hard_bg:SetActive(false)
  UILuaHelper.PlayAnimationByName(self.m_scroll_extension, "Activity108_LevelMain_List_in")
end

function Form_Activity112_DialogueMain:OnBtnHardClicked()
  if self.m_curDegreeIndex == LevelDegree.Hard then
    return
  end
  if self.m_isHarLock then
    local clientMsgStr = ConfigManager:GetClientMessageTextById(40039)
    clientMsgStr = string.CS_Format(clientMsgStr, self:GetHardLevelUnlockStr(), self:GetHardTimeUnlockStr())
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, clientMsgStr)
    return
  end
  LevelHeroLamiaActivityManager:SetActivitySubEnter(self.DegreeCfgTab[LevelDegree.Hard].activitySubID)
  self:FreshLevelTab(LevelDegree.Hard)
  LocalDataManager:SetIntSimple("HeroActDialogueMainHardEntry" .. self.m_activityID, 1, true)
  self.m_hard_new:SetActive(false)
  self.m_bg_nml:SetActive(false)
  self.m_hard_bg:SetActive(true)
  UILuaHelper.PlayAnimationByName(self.m_scroll_extension, "Activity108_LevelMain_List_in")
end

function Form_Activity112_DialogueMain:OnBtnCollectClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY112_DIALOGUECOLLECTION, {
    activityID = self.m_activityID,
    activitySubID = self.DegreeCfgTab[LevelDegree.Normal].activitySubID,
    bIsSecondHalf = false
  })
end

function Form_Activity112_DialogueMain:FreshLevelTab(index)
  Form_Activity112_DialogueMain.super.FreshLevelTab(self, index)
  if index then
    self.m_curDegreeIndex = index
    local curDegreeData = self.DegreeCfgTab[index]
    local chooseItemIndex = self:GetLevelIndexByLevelID(index, curDegreeData.currentID)
    if not chooseItemIndex then
      return
    end
    self.m_luaextensionInfinityGrid:LocateTo(chooseItemIndex - 3)
  end
end

local fullscreen = true
ActiveLuaUI("Form_Activity112_DialogueMain", Form_Activity112_DialogueMain)
return Form_Activity112_DialogueMain
