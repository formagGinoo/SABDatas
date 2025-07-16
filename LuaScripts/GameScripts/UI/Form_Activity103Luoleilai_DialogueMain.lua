local Form_Activity103Luoleilai_DialogueMain = class("Form_Activity103Luoleilai_DialogueMain", require("UI/UIFrames/Form_Activity103Luoleilai_DialogueMainUI"))
local LevelDegree = LevelHeroLamiaActivityManager.LevelDegree

function Form_Activity103Luoleilai_DialogueMain:SetInitParam(param)
end

function Form_Activity103Luoleilai_DialogueMain:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClick),
    parentLua = self
  }
  self.m_luaextensionInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scroll_extension_InfinityGrid, "LamiaLevel/UI103NormalLevelItem", initGridData)
end

function Form_Activity103Luoleilai_DialogueMain:OnActive()
  Form_Activity103Luoleilai_DialogueMain.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(297)
end

function Form_Activity103Luoleilai_DialogueMain:OnInactive()
  Form_Activity103Luoleilai_DialogueMain.super.OnInactive(self)
end

function Form_Activity103Luoleilai_DialogueMain:OnDestroy()
  Form_Activity103Luoleilai_DialogueMain.super.OnDestroy(self)
end

function Form_Activity103Luoleilai_DialogueMain:FreshUI()
  Form_Activity103Luoleilai_DialogueMain.super.FreshUI(self)
  self:FreshDegreeLevelList()
  self.m_curDegreeIndex = 1
  self:FreshLevelTab(self.m_curDegreeIndex)
end

function Form_Activity103Luoleilai_DialogueMain:FreshLevelTab(index)
  Form_Activity103Luoleilai_DialogueMain.super.FreshLevelTab(self, index)
  if index then
    local curDegreeData = self.DegreeCfgTab[index]
    self.m_luaextensionInfinityGrid:ShowItemList(curDegreeData.levelList)
    local chooseItemIndex = self:GetLevelIndexByLevelID(index, curDegreeData.currentID)
    if not chooseItemIndex then
      return
    end
    self.m_luaextensionInfinityGrid:LocateTo(chooseItemIndex - 2)
  end
  self.m_bg_nml:SetActive(false)
  self.m_hard_bg:SetActive(false)
end

function Form_Activity103Luoleilai_DialogueMain:GetLevelIndexByLevelID(levelDegree, levelID)
  if not levelDegree then
    return
  end
  if not levelID then
    return
  end
  local levelDataList = self.DegreeCfgTab[levelDegree].levelList
  for i, v in ipairs(levelDataList) do
    if v.levelCfg.m_LevelID == levelID then
      return i
    end
  end
end

function Form_Activity103Luoleilai_DialogueMain:FreshDegreeLevelList()
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
      local tempShowLevelItem = {levelCfg = tempCfg, isChoose = isCurrent}
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

function Form_Activity103Luoleilai_DialogueMain:OnItemClick(index)
  if not index then
    return
  end
  local degreeCfgTab = self.DegreeCfgTab[self.m_curDegreeIndex]
  local levelList = degreeCfgTab.levelList
  if not levelList then
    return
  end
  local curLevelData = levelList[index]
  local curLevelID = curLevelData.levelCfg.m_LevelID
  degreeCfgTab.currentID = curLevelID
  self.m_curDetailLevelID = curLevelID
  self:FreshLevelDetailShow()
end

function Form_Activity103Luoleilai_DialogueMain:FreshLevelDetailShow()
  if self.m_curDetailLevelID then
    UILuaHelper.SetActive(self.m_level_detail_root, true)
    if self.m_luaDetailLevel == nil then
      self:CreateSubPanel("LevelDetailLuoleilaiSubPanel", self.m_level_detail_root, self, {
        bgBackFun = handler(self, self.OnLevelDetailBgClick)
      }, {
        activityID = self.m_activityID,
        levelID = self.m_curDetailLevelID
      }, function(luaPanel)
        self.m_luaDetailLevel = luaPanel
        self.m_luaDetailLevel:AddEventListeners()
      end)
    else
      self.m_luaDetailLevel:FreshData({
        activityID = self.m_activityID,
        levelID = self.m_curDetailLevelID
      })
    end
    GlobalManagerIns:TriggerWwiseBGMState(95)
  else
    TimeService:SetTimer(0.2, 1, function()
      UILuaHelper.SetActive(self.m_level_detail_root, false)
    end)
    GlobalManagerIns:TriggerWwiseBGMState(96)
  end
end

function Form_Activity103Luoleilai_DialogueMain:OnBtnbuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

function Form_Activity103Luoleilai_DialogueMain:OnBtnCollectClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_DIALOGUECOLLECTION, {
    activityID = self.m_activityID,
    activitySubID = self.DegreeCfgTab[LevelDegree.Normal].activitySubID,
    bIsSecondHalf = false
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity103Luoleilai_DialogueMain", Form_Activity103Luoleilai_DialogueMain)
return Form_Activity103Luoleilai_DialogueMain
