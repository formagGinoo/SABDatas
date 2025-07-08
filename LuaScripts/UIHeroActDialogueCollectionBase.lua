local UIHeroActDialogueCollectionBase = class("UIHeroActDialogueCollectionBase", require("UI/Common/UIBase"))
local PlotPlayIns = ConfigManager:GetConfigInsByName("PlotPlay")
local PlotStepIns = ConfigManager:GetConfigInsByName("PlotStep")
local PlotMatchDic = {
  [BattleFlowManager.PlotActionType.Video] = true,
  [BattleFlowManager.PlotActionType.TimeLine] = true,
  [BattleFlowManager.PlotActionType.Black] = true
}

function UIHeroActDialogueCollectionBase:AfterInit()
  UIHeroActDialogueCollectionBase.super.AfterInit(self)
  local initData = {
    itemClkBackFun = handler(self, self.OnStoryItemClk)
  }
  self.m_luaLevelStoryList = self:CreateInfinityGrid(self.m_levelStoryList_InfinityGrid, "LamiaLevel/UILamiaDialogCollectionItem", initData)
  self.m_storyLevelCfgList = nil
  self.m_activityID = nil
  self.m_activitySubID = nil
  self.m_levelHelper = LevelHeroLamiaActivityManager:GetLevelHelper()
  self.m_plotPlayCfgDic = {}
  self.m_plotStepCfgDic = {}
end

function UIHeroActDialogueCollectionBase:OnActive()
  UIHeroActDialogueCollectionBase.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
end

function UIHeroActDialogueCollectionBase:OnInactive()
  UIHeroActDialogueCollectionBase.super.OnInactive(self)
end

function UIHeroActDialogueCollectionBase:OnDestroy()
  UIHeroActDialogueCollectionBase.super.OnDestroy(self)
end

function UIHeroActDialogueCollectionBase:FreshUI()
  local showNum = #self.m_storyLevelCfgList
  UILuaHelper.SetActive(self.m_levelStoryList, 0 < showNum)
  UILuaHelper.SetActive(self.m_pnl_empty, showNum <= 0)
  self.m_luaLevelStoryList:ShowItemList(self.m_storyLevelCfgList)
end

function UIHeroActDialogueCollectionBase:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_activityID = tonumber(tParam.activityID)
    self.m_activitySubID = tonumber(tParam.activitySubID)
    self:FreshStoryLevelList()
    self.m_csui.m_param = nil
  end
end

function UIHeroActDialogueCollectionBase:FreshStoryLevelList()
  if not self.m_activityID then
    return
  end
  if not self.m_activitySubID then
    return
  end
  local tempLevelData = self.m_levelHelper:GetLevelDataByActAndSubID(self.m_activityID, self.m_activitySubID)
  if not tempLevelData then
    return
  end
  local showStoryLevelList = {}
  local tempLevelCfgList = tempLevelData.levelCfgList
  for i, v in ipairs(tempLevelCfgList) do
    local levelID = v.m_LevelID
    local isHavePass = self.m_levelHelper:IsLevelHavePass(levelID)
    if isHavePass then
      local isHave = self:IsLevelCfgHaveStory(v)
      if isHave then
        showStoryLevelList[#showStoryLevelList + 1] = v
      end
    end
  end
  self.m_storyLevelCfgList = showStoryLevelList
end

function UIHeroActDialogueCollectionBase:IsLevelCfgHaveStory(levelCfg)
  if not levelCfg then
    return
  end
  local mapID = levelCfg.m_MapID
  if next(self.m_plotPlayCfgDic) == nil then
    self:FreshAllPlotPlayDic()
  end
  local tempPlotPlayList = self.m_plotPlayCfgDic[mapID]
  if not tempPlotPlayList then
    return
  end
  for i, tempPlotPlayCfg in ipairs(tempPlotPlayList) do
    local plotStepIDList = tempPlotPlayCfg.m_PlotStepLst
    local plotStepLen = plotStepIDList.Length
    if 0 < plotStepLen then
      for i = 0, plotStepLen - 1 do
        local tempPlotStepID = plotStepIDList[i]
        local isHaveMatchStep = self:IsPlotStepMatch(tempPlotStepID)
        if isHaveMatchStep then
          return true
        end
      end
    end
  end
  return false
end

function UIHeroActDialogueCollectionBase:FreshAllPlotPlayDic()
  local allCfg = PlotPlayIns:GetAll()
  if not allCfg then
    return
  end
  for _, tempCfg in pairs(allCfg) do
    local mapID = tempCfg.m_MapID
    local tempList = self.m_plotPlayCfgDic[mapID]
    if tempList == nil then
      tempList = {}
      self.m_plotPlayCfgDic[mapID] = tempList
    end
    tempList[#tempList + 1] = tempCfg
  end
end

function UIHeroActDialogueCollectionBase:IsPlotStepMatch(plotStepID)
  if not plotStepID then
    return
  end
  local tempPlotStepCfg = self.m_plotStepCfgDic[plotStepID]
  if tempPlotStepCfg == nil then
    tempPlotStepCfg = PlotStepIns:GetValue_ByID(plotStepID)
    if tempPlotStepCfg:GetError() ~= true then
      self.m_plotStepCfgDic[plotStepID] = tempPlotStepCfg
    end
  end
  local actionType = tempPlotStepCfg.m_ActionType or 0
  if PlotMatchDic[actionType] == true then
    return true
  end
  return false
end

function UIHeroActDialogueCollectionBase:OnStoryItemClk(index)
  if not index then
    return
  end
  local levelCfg = self.m_storyLevelCfgList[index]
  if not levelCfg then
    return
  end
  local mapID = levelCfg.m_MapID
  local activityID = self.m_activityID
  local activitySubID = self.m_activitySubID
  BattleFlowManager:EnterShowPlot(levelCfg.m_LevelID, mapID, function(backFun)
    GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
      if isSuc then
        local subCfg = HeroActivityManager:GetSubInfoByID(activitySubID)
        local formStr = "Form_Hall"
        local formUIID = UIDefines.ID_FORM_HALL
        if subCfg == nil then
          formStr = "Form_Hall"
          formUIID = UIDefines.ID_FORM_HALL
        else
          formStr = "Form_Activity101Lamia_DialogueCollection"
          formUIID = UIDefines.ID_FORM_ACTIVITY101LAMIA_DIALOGUECOLLECTION
        end
        StackFlow:Push(formUIID, {activityID = activityID, activitySubID = activitySubID})
        if backFun then
          backFun(formStr)
        end
      end
    end, true)
  end)
end

function UIHeroActDialogueCollectionBase:OnBtnCloseClicked()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.m_activityID,
    sub_id = HeroActivityManager:GetSubFuncID(self.m_activityID, HeroActivityManager.SubActTypeEnum.NormalLevel)
  })
  self:CloseForm()
end

return UIHeroActDialogueCollectionBase
