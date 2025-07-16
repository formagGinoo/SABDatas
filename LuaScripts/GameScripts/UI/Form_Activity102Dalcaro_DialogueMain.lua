local Form_Activity102Dalcaro_DialogueMain = class("Form_Activity102Dalcaro_DialogueMain", require("UI/UIFrames/Form_Activity102Dalcaro_DialogueMainUI"))
local LevelDegree = LevelHeroLamiaActivityManager.LevelDegree
local UILevelItem = require("UI/Item/LamiaLevel/UIDalcaroItem")
local Dalcaro_DialogueMain_cut = "Dalcaro_DialogueMain_cut"

function Form_Activity102Dalcaro_DialogueMain:SetInitParam(param)
end

function Form_Activity102Dalcaro_DialogueMain:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClick)
  }
  self.m_luaextensionInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scroll_extension_InfinityGrid, "LamiaLevel/UIDalcaroItem", initGridData)
  self.itemCom = UILevelItem.new(nil, self.m_item_choose, nil, nil, 1)
end

function Form_Activity102Dalcaro_DialogueMain:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(123)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(115)
end

function Form_Activity102Dalcaro_DialogueMain:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity102Dalcaro_DialogueMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity102Dalcaro_DialogueMain:FreshUI()
  self.super.FreshUI(self)
  self:FreshDegreeLevelList()
  self:FreshLevelTab(self.m_curDegreeIndex)
end

function Form_Activity102Dalcaro_DialogueMain:FreshLevelTab(index)
  self.super.FreshLevelTab(self, index)
  if index then
    local curDegreeData = self.DegreeCfgTab[index]
    self.m_luaextensionInfinityGrid:ShowItemList(curDegreeData.levelList)
    local chooseItemIndex = self:GetLevelIndexByLevelID(index, curDegreeData.currentID)
    if not chooseItemIndex then
      return
    end
    self.m_luaextensionInfinityGrid:LocateTo(chooseItemIndex - 1)
  end
end

function Form_Activity102Dalcaro_DialogueMain:FreshLevelDetailShow()
  if self.m_curDetailLevelID then
    UILuaHelper.SetActive(self.m_level_detail_root, true)
    if self.m_luaDetailLevel == nil then
      self:CreateSubPanel("LevelDetailDalcaroSubPanel", self.m_level_detail_root, self, {
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
    UILuaHelper.SetActive(self.m_button_extension_choose, true)
    self:FreshChooseItemNode()
    GlobalManagerIns:TriggerWwiseBGMState(95)
  else
    TimeService:SetTimer(0.2, 1, function()
      UILuaHelper.SetActive(self.m_level_detail_root, false)
      UILuaHelper.SetActive(self.m_button_extension_choose, false)
    end)
    GlobalManagerIns:TriggerWwiseBGMState(96)
  end
end

function Form_Activity102Dalcaro_DialogueMain:FreshChooseItemNode()
  if not self.m_curDetailLevelID then
    return
  end
  if not self.m_curDegreeIndex then
    return
  end
  local chooseItemIndex = self:GetLevelIndexByLevelID(self.m_curDegreeIndex, self.m_curDetailLevelID)
  if not chooseItemIndex then
    return
  end
  local itemData = self.DegreeCfgTab[self.m_curDegreeIndex].levelList[chooseItemIndex]
  if not itemData then
    return
  end
  self.itemCom:FreshData(itemData, chooseItemIndex)
end

function Form_Activity102Dalcaro_DialogueMain:GetLevelIndexByLevelID(levelDegree, levelID)
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

function Form_Activity102Dalcaro_DialogueMain:FreshDegreeLevelList()
  for _, v in ipairs(self.DegreeCfgTab) do
    local levelData = self.m_levelHelper:GetLevelDataByActAndSubID(self.m_activityID, v.activitySubID) or {}
    local levelCfgList = levelData.levelCfgList
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

function Form_Activity102Dalcaro_DialogueMain:OnItemClick(index)
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

function Form_Activity102Dalcaro_DialogueMain:OnBtnNormalClicked()
  if self.m_curDegreeIndex == LevelDegree.Normal then
    return
  end
  local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_csui.m_uiGameObject, Dalcaro_DialogueMain_cut)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, Dalcaro_DialogueMain_cut)
  TimeService:SetTimer(aniLen, 1, function()
    self:FreshLevelTab(LevelDegree.Normal)
  end)
end

function Form_Activity102Dalcaro_DialogueMain:OnBtnHardClicked()
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
  local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_csui.m_uiGameObject, Dalcaro_DialogueMain_cut)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, Dalcaro_DialogueMain_cut)
  TimeService:SetTimer(aniLen, 1, function()
    self:FreshLevelTab(LevelDegree.Hard)
  end)
  LocalDataManager:SetIntSimple("HeroActDialogueMainHardEntry" .. self.m_activityID, 1, true)
  self.m_hard_new:SetActive(false)
end

function Form_Activity102Dalcaro_DialogueMain:OnBtnbuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

function Form_Activity102Dalcaro_DialogueMain:OnBtnCollectClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_DIALOGUECOLLECTION, {
    activityID = self.m_activityID,
    activitySubID = self.DegreeCfgTab[LevelDegree.Normal].activitySubID
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity102Dalcaro_DialogueMain", Form_Activity102Dalcaro_DialogueMain)
return Form_Activity102Dalcaro_DialogueMain
