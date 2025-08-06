local Form_Activity105_DialogueMain = class("Form_Activity105_DialogueMain", require("UI/UIFrames/Form_Activity105_DialogueMainUI"))

function Form_Activity105_DialogueMain:SetInitParam(param)
end

local LevelDegree = LevelHeroLamiaActivityManager.LevelDegree

function Form_Activity105_DialogueMain:AfterInit()
  Form_Activity105_DialogueMain.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClick),
    parentLua = self
  }
  self.m_luaextensionInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scroll_extension_InfinityGrid, "LamiaLevel/UI105NormalLevelItem", initGridData)
  self.iPerPageNum = 6
  self.iNormalPart1 = 1
  self.iNormalPart2 = 2
end

function Form_Activity105_DialogueMain:OnActive()
  self.iCurNormalPage = self.iNormalPart1
  self.bIsCanChangePage = false
  Form_Activity105_DialogueMain.super.OnActive(self)
end

function Form_Activity105_DialogueMain:OnInactive()
  Form_Activity105_DialogueMain.super.OnInactive(self)
  self:clearEventListener()
end

function Form_Activity105_DialogueMain:OnDestroy()
  Form_Activity105_DialogueMain.super.OnDestroy(self)
end

function Form_Activity105_DialogueMain:FreshUI()
  Form_Activity105_DialogueMain.super.FreshUI(self)
  self:FreshDegreeLevelList()
  self.m_curDegreeIndex = self.m_curDegreeIndex or self:GetChooseIndex() or 1
  self:FreshLevelTab(self.m_curDegreeIndex)
end

function Form_Activity105_DialogueMain:GetChooseIndex()
  local degreeCfgTab = self.DegreeCfgTab[LevelDegree.Normal]
  if not degreeCfgTab then
    return
  end
  local levelList = degreeCfgTab.levelList
  if not levelList then
    return
  end
  local temp = levelList[1]
  if not temp then
    return
  end
  local lastLevelData = temp[#temp]
  if not lastLevelData then
    return
  end
  local lastLeveCfg = lastLevelData.levelCfg
  if not lastLeveCfg then
    return
  end
  if not self.m_isHarLock and self.m_levelHelper:IsLevelHavePass(lastLeveCfg.m_LevelID) == true then
    return LevelDegree.Hard
  end
end

function Form_Activity105_DialogueMain:FreshLevelTab(index)
  Form_Activity105_DialogueMain.super.FreshLevelTab(self, index)
  if index then
    local curDegreeData = self.DegreeCfgTab[index]
    local showLevelItemList = curDegreeData.levelList
    local temp = {}
    if index == LevelDegree.Normal then
      temp = showLevelItemList[self.iCurNormalPage]
      self.m_bg_nml:SetActive(self.iCurNormalPage == self.iNormalPart1)
      self.m_bg_nml2:SetActive(self.iCurNormalPage == self.iNormalPart2)
      self.m_btn_timing:SetActive(self.iCurNormalPage == self.iNormalPart1 and self.bIsCanChangePage)
      self.m_btn_annihilation:SetActive(self.iCurNormalPage == self.iNormalPart2 and self.bIsCanChangePage)
      self.m_hard_bg:SetActive(false)
    else
      temp = showLevelItemList
      self.m_hard_new:SetActive(false)
      self.m_bg_nml:SetActive(false)
      self.m_bg_nml2:SetActive(false)
      self.m_btn_timing:SetActive(false)
      self.m_btn_annihilation:SetActive(false)
      self.m_hard_bg:SetActive(true)
    end
    self.m_luaextensionInfinityGrid:ShowItemList(temp)
    local chooseItemIndex = self:GetLevelIndexByLevelID(index, curDegreeData.currentID)
    if not chooseItemIndex then
      return
    end
    self.m_luaextensionInfinityGrid:LocateTo(chooseItemIndex - 2)
  end
end

function Form_Activity105_DialogueMain:FreshLevelDetailShow()
  if self.m_curDetailLevelID then
    UILuaHelper.SetActive(self.m_level_detail_root, true)
    if self.m_luaDetailLevel == nil then
      self:CreateSubPanel("LevelDetail105SubPanel", self.m_level_detail_root, self, {
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

function Form_Activity105_DialogueMain:GetLevelIndexByLevelID(levelDegree, levelID)
  if not levelDegree then
    return
  end
  if not levelID then
    return
  end
  local levelDataList = self.DegreeCfgTab[levelDegree].levelList
  local temp = {}
  if levelDegree == LevelDegree.Normal then
    temp = levelDataList[self.iCurNormalPage]
  else
    temp = levelDataList
  end
  for i, v in ipairs(temp) do
    if v.levelCfg.m_LevelID == levelID then
      return i
    end
  end
end

function Form_Activity105_DialogueMain:FreshDegreeLevelList()
  for i, v in ipairs(self.DegreeCfgTab) do
    local levelData = self.m_levelHelper:GetLevelDataByActAndSubID(self.m_activityID, v.activitySubID) or {}
    local levelCfgList = levelData.levelCfgList
    local curlevelCfg = self.m_levelHelper:GetCurLevel(self.m_activityID, v.activitySubID) or {}
    local nextLevelID = curlevelCfg.m_LevelID or 0
    local showLevelItemList = {}
    if i == LevelDegree.Normal then
      for index, tempCfg in ipairs(levelCfgList) do
        local iCurPage = math.ceil(index / self.iPerPageNum)
        showLevelItemList[iCurPage] = showLevelItemList[iCurPage] or {}
        local isCurrent = tempCfg.m_LevelID == nextLevelID
        local tempShowLevelItem = {
          levelCfg = tempCfg,
          isChoose = isCurrent,
          iCurPage = iCurPage
        }
        table.insert(showLevelItemList[iCurPage], tempShowLevelItem)
        if isCurrent then
          v.currentID = tempCfg.m_LevelID
          self.iCurNormalPage = iCurPage
          self.bIsCanChangePage = index > self.iPerPageNum
        end
      end
      for _, tempList in pairs(showLevelItemList) do
        for _, tempItem in ipairs(tempList) do
          tempItem.maxNum = #tempList
        end
      end
    else
      for index, tempCfg in ipairs(levelCfgList) do
        local isCurrent = tempCfg.m_LevelID == nextLevelID
        local tempShowLevelItem = {levelCfg = tempCfg, isChoose = isCurrent}
        table.insert(showLevelItemList, tempShowLevelItem)
        if isCurrent then
          v.currentID = tempCfg.m_LevelID
        end
      end
      for _, vv in ipairs(showLevelItemList) do
        vv.maxNum = #showLevelItemList
      end
    end
    v.levelList = showLevelItemList
  end
end

function Form_Activity105_DialogueMain:OnItemClick(index)
  if not index then
    return
  end
  local degreeCfgTab = self.DegreeCfgTab[self.m_curDegreeIndex]
  local levelList = degreeCfgTab.levelList
  if not levelList then
    return
  end
  local temp = {}
  if self.m_curDegreeIndex == LevelDegree.Normal then
    temp = levelList[self.iCurNormalPage]
  else
    temp = levelList
  end
  local curLevelData = temp[index]
  local curLevelID = curLevelData.levelCfg.m_LevelID
  degreeCfgTab.currentID = curLevelID
  self.m_curDetailLevelID = curLevelID
  self:FreshLevelDetailShow()
end

function Form_Activity105_DialogueMain:OnBtnNormalClicked()
  if self.m_curDegreeIndex == LevelDegree.Normal then
    return
  end
  self:FreshLevelTab(LevelDegree.Normal)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Acticity104_Level_Main_cut2")
end

function Form_Activity105_DialogueMain:OnBtnHardClicked()
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
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Acticity104_Level_Main_cut")
end

function Form_Activity105_DialogueMain:OnBtnbuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

function Form_Activity105_DialogueMain:OnBtnCollectClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY105_DIALOGUECOLLECTION, {
    activityID = self.m_activityID,
    activitySubID = self.DegreeCfgTab[LevelDegree.Normal].activitySubID
  })
end

function Form_Activity105_DialogueMain:OnBtntimingClicked()
  if self.iCurNormalPage == self.iNormalPart2 or not self.bIsCanChangePage then
    return
  end
  self.iCurNormalPage = self.iNormalPart2
  self:FreshLevelTab(self.m_curDegreeIndex)
  UILuaHelper.PlayAnimationByName(self.m_btn_annihilation, "DialogueMain_annihilation_in")
  UILuaHelper.PlayAnimationByName(self.m_scroll_extension, "Activity105_DialogueMain_item")
end

function Form_Activity105_DialogueMain:OnBtnannihilationClicked()
  if self.iCurNormalPage == self.iNormalPart1 or not self.bIsCanChangePage then
    return
  end
  self.iCurNormalPage = self.iNormalPart1
  self:FreshLevelTab(self.m_curDegreeIndex)
  UILuaHelper.PlayAnimationByName(self.m_btn_timing, "DialogueMain_timing_in")
  UILuaHelper.PlayAnimationByName(self.m_scroll_extension, "Activity105_DialogueMain_item")
end

local fullscreen = true
ActiveLuaUI("Form_Activity105_DialogueMain", Form_Activity105_DialogueMain)
return Form_Activity105_DialogueMain
