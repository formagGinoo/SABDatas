local Form_Activity108_DialogueMain = class("Form_Activity108_DialogueMain", require("UI/UIFrames/Form_Activity108_DialogueMainUI"))

function Form_Activity108_DialogueMain:SetInitParam(param)
end

function Form_Activity108_DialogueMain:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClick),
    parentLua = self
  }
  self.m_luaextensionInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scroll_extension_InfinityGrid, "LamiaLevel/UI108NormalLevelItem", initGridData)
  self.sSubPanelName = "LevelDetail109SubPanel"
end

function Form_Activity108_DialogueMain:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(360)
end

function Form_Activity108_DialogueMain:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity108_DialogueMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity108_DialogueMain:FreshUI()
  Form_Activity108_DialogueMain.super.FreshUI(self)
  self:FreshDegreeLevelList()
  self.m_curDegreeIndex = 1
  self:FreshLevelTab(self.m_curDegreeIndex)
end

function Form_Activity108_DialogueMain:FreshDegreeLevelList()
  for _, v in ipairs(self.DegreeCfgTab) do
    local levelData = self.m_levelHelper:GetLevelDataByActAndSubID(self.m_activityID, v.activitySubID) or {}
    local levelCfgList = levelData.levelCfgList
    if not levelCfgList then
      return
    end
    local curlevelCfg = self.m_levelHelper:GetCurLevel(self.m_activityID, v.activitySubID) or {}
    local nextLevelID = curlevelCfg.m_LevelID or 0
    local showLevelItemList = {}
    for index, tempCfg in ipairs(levelCfgList) do
      local isCurrent = tempCfg.m_LevelID == nextLevelID
      local tempShowLevelItem = {
        levelCfg = tempCfg,
        isChoose = false,
        bIsCurrent = isCurrent
      }
      showLevelItemList[#showLevelItemList + 1] = tempShowLevelItem
      if isCurrent then
        v.currentID = tempCfg.m_LevelID
      end
    end
    for _, vv in ipairs(showLevelItemList) do
      vv.maxNum = #showLevelItemList
    end
    v.levelList = showLevelItemList
  end
end

function Form_Activity108_DialogueMain:OnBtnbuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

function Form_Activity108_DialogueMain:OnBtnCollectClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY108_DIALOGUECOLLECTION, {
    activityID = self.m_activityID,
    activitySubID = self.DegreeCfgTab[self.LevelDegree.Normal].activitySubID,
    bIsSecondHalf = false
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity108_DialogueMain", Form_Activity108_DialogueMain)
return Form_Activity108_DialogueMain
