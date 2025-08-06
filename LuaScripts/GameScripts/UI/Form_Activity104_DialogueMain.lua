local Form_Activity104_DialogueMain = class("Form_Activity104_DialogueMain", require("UI/UIFrames/Form_Activity104_DialogueMainUI"))
local LevelDegree = LevelHeroLamiaActivityManager.LevelDegree

function Form_Activity104_DialogueMain:SetInitParam(param)
end

function Form_Activity104_DialogueMain:AfterInit()
  Form_Activity104_DialogueMain.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClick),
    parentLua = self
  }
  self.m_luaextensionInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scroll_extension_InfinityGrid, "LamiaLevel/UI104NormalLevelItem", initGridData)
  self.DegreeCfgTab[LevelDegree.Normal].activitySubIndex = 2
end

function Form_Activity104_DialogueMain:OnActive()
  Form_Activity104_DialogueMain.super.OnActive(self)
  self:addEventListener("eGameEvent_Act4ClueGetAward", handler(self, self.OnEventAct4ClueGetAward))
  CS.GlobalManager.Instance:TriggerWwiseBGMState(297)
end

function Form_Activity104_DialogueMain:OnInactive()
  Form_Activity104_DialogueMain.super.OnInactive(self)
  self:clearEventListener()
end

function Form_Activity104_DialogueMain:OnDestroy()
  Form_Activity104_DialogueMain.super.OnDestroy(self)
end

function Form_Activity104_DialogueMain:OnEventAct4ClueGetAward()
  self.m_luaextensionInfinityGrid:ReBindAll()
end

function Form_Activity104_DialogueMain:FreshUI()
  Form_Activity104_DialogueMain.super.FreshUI(self)
  self:FreshDegreeLevelList()
  self.m_curDegreeIndex = self.m_curDegreeIndex or self:GetChooseIndex() or 1
  self:FreshLevelTab(self.m_curDegreeIndex)
end

function Form_Activity104_DialogueMain:FreshLevelTab(index)
  Form_Activity104_DialogueMain.super.FreshLevelTab(self, index)
  if index then
    local curDegreeData = self.DegreeCfgTab[index]
    self.m_luaextensionInfinityGrid:ShowItemList(curDegreeData.levelList)
    local chooseItemIndex = self:GetLevelIndexByLevelID(index, curDegreeData.currentID)
    if not chooseItemIndex then
      self.m_luaextensionInfinityGrid:LocateTo(self.iPerPageNum)
      return
    end
    self.m_luaextensionInfinityGrid:LocateTo(chooseItemIndex - 2)
  end
end

function Form_Activity104_DialogueMain:FreshLevelDetailShow()
  if self.m_curDetailLevelID then
    UILuaHelper.SetActive(self.m_level_detail_root, true)
    if self.m_luaDetailLevel == nil then
      self:CreateSubPanel("LevelDetail104SubPanel", self.m_level_detail_root, self, {
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

function Form_Activity104_DialogueMain:GetLevelIndexByLevelID(levelDegree, levelID)
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

function Form_Activity104_DialogueMain:FreshDegreeLevelList()
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

function Form_Activity104_DialogueMain:OnItemClick(index)
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

function Form_Activity104_DialogueMain:OnBtnNormalClicked()
  if self.m_curDegreeIndex == LevelDegree.Normal then
    return
  end
  self:FreshLevelTab(LevelDegree.Normal)
  self.m_bg_nml:SetActive(true)
  self.m_hard_bg:SetActive(false)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Acticity104_Level_Main_cut2")
end

function Form_Activity104_DialogueMain:OnBtnHardClicked()
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
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Acticity104_Level_Main_cut")
end

function Form_Activity104_DialogueMain:OnBtnbuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

function Form_Activity104_DialogueMain:OnBtnCollectClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_DIALOGUECOLLECTION, {
    activityID = self.m_activityID,
    activitySubID = self.DegreeCfgTab[LevelDegree.Normal].activitySubID,
    bIsSecondHalf = true
  })
end

function Form_Activity104_DialogueMain:GetDownloadResourceExtra(tParam)
  local _vPackage, _vResourceExtra = Form_Activity104_DialogueMain.super.GetDownloadResourceExtra(self, tParam)
  local vPackage = {}
  local vResourceExtra = {}
  if tParam.main_id then
    local act_id = tParam.main_id
    local subActivityID = HeroActivityManager:GetSubFuncID(act_id, HeroActivityManager.SubActTypeEnum.NormalLevel, 2)
    local subActivityInfoCfg = HeroActivityManager:GetSubInfoByID(subActivityID)
    if subActivityInfoCfg then
      local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(subActivityInfoCfg.m_SubPrefab)
      if vPackageSub ~= nil then
        for m = 1, #vPackageSub do
          vPackage[#vPackage + 1] = vPackageSub[m]
        end
      end
      if vResourceExtraSub ~= nil then
        for n = 1, #vResourceExtraSub do
          vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[n]
        end
      end
    end
  end
  for i, v in ipairs(_vPackage) do
    vPackage[#vPackage + 1] = v
  end
  for i, v in ipairs(_vResourceExtra) do
    vResourceExtra[#vResourceExtra + 1] = v
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_Activity104_DialogueMain", Form_Activity104_DialogueMain)
return Form_Activity104_DialogueMain
