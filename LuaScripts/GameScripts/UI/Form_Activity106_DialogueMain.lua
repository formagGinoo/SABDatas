local Form_Activity106_DialogueMain = class("Form_Activity106_DialogueMain", require("UI/UIFrames/Form_Activity106_DialogueMainUI"))
local LevelDegree = LevelHeroLamiaActivityManager.LevelDegree

function Form_Activity106_DialogueMain:SetInitParam(param)
end

function Form_Activity106_DialogueMain:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClick),
    parentLua = self
  }
  self.m_luaextensionInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scroll_extension_InfinityGrid, "LamiaLevel/UI106NormalLevelItem", initGridData)
end

function Form_Activity106_DialogueMain:OnActive()
  self.super.OnActive(self)
  self:FreshDrawBtn()
  self:CheckPushDraw()
  HeroActivityManager:CheckShowEnterAnim(self.m_csui.m_uiGameObject, "Form_Activity106_DialogueMain_ShowAni", "Activity106_LevelMain_in_DailyFirstOpen", "Activity106_LevelMain_in", 347)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(345)
end

function Form_Activity106_DialogueMain:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity106_DialogueMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity106_DialogueMain:FreshUI()
  Form_Activity106_DialogueMain.super.FreshUI(self)
  self:FreshDegreeLevelList()
  self.m_curDegreeIndex = self.m_curDegreeIndex or self:GetChooseIndex() or 1
  self:FreshLevelTab(self.m_curDegreeIndex)
end

function Form_Activity106_DialogueMain:FreshLevelTab(index)
  Form_Activity106_DialogueMain.super.FreshLevelTab(self, index)
  if index then
    local curDegreeData = self.DegreeCfgTab[index]
    self.m_luaextensionInfinityGrid:ShowItemList(curDegreeData.levelList)
    local chooseItemIndex = self:GetLevelIndexByLevelID(index, curDegreeData.currentID)
    if not chooseItemIndex then
      return
    end
    self.m_luaextensionInfinityGrid:LocateTo(chooseItemIndex - 2)
  end
end

function Form_Activity106_DialogueMain:FreshLevelDetailShow()
  if self.m_curDetailLevelID then
    UILuaHelper.SetActive(self.m_level_detail_root, true)
    if self.m_luaDetailLevel == nil then
      self:CreateSubPanel("LevelDetail106SubPanel", self.m_level_detail_root, self, {
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

function Form_Activity106_DialogueMain:GetLevelIndexByLevelID(levelDegree, levelID)
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

function Form_Activity106_DialogueMain:FreshDegreeLevelList()
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

function Form_Activity106_DialogueMain:OnItemClick(index)
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

function Form_Activity106_DialogueMain:OnBtnNormalClicked()
  if self.m_curDegreeIndex == LevelDegree.Normal then
    return
  end
  self:FreshLevelTab(LevelDegree.Normal)
  self.m_bg_nml:SetActive(true)
  self.m_hard_bg:SetActive(false)
  UILuaHelper.PlayAnimationByName(self.m_scroll_extension, "Activity106_LevelMain_List_in")
end

function Form_Activity106_DialogueMain:OnBtnHardClicked()
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
  UILuaHelper.PlayAnimationByName(self.m_scroll_extension, "Activity106_LevelMain_List_in")
end

function Form_Activity106_DialogueMain:OnBtnbuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

function Form_Activity106_DialogueMain:OnBtnCollectClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY106_DIALOGUECOLLECTION, {
    activityID = self.m_activityID,
    activitySubID = self.DegreeCfgTab[LevelDegree.Normal].activitySubID,
    bIsSecondHalf = false
  })
end

function Form_Activity106_DialogueMain:FreshDrawBtn()
  local vCfgs = HeroActivityManager:GetAllActLostStoryCfg(self.m_activityID)
  if not vCfgs or #vCfgs <= 0 then
    UILuaHelper.SetActive(self.m_btn_draw, false)
    return
  end
  local cfg = vCfgs[1]
  if not cfg then
    UILuaHelper.SetActive(self.m_btn_draw, false)
    return
  end
  local iLevelID = cfg.m_LevelID
  local bIsPassed = self.m_levelHelper:IsLevelHavePass(iLevelID)
  UILuaHelper.SetActive(self.m_btn_draw, bIsPassed)
end

function Form_Activity106_DialogueMain:CheckPushDraw()
  local vCfgs = HeroActivityManager:GetAllActLostStoryCfg(self.m_activityID)
  if not vCfgs or #vCfgs <= 0 then
    return
  end
  local key = HeroActivityManager.ClientDataKey.DialogueMainDraw
  local iMaxStoryID = tonumber(HeroActivityManager:GetClientData(self.m_activityID, key) or 0)
  for _, v in ipairs(vCfgs) do
    local iLevelID = v.m_LevelID
    local bIsPassed = self.m_levelHelper:IsLevelHavePass(iLevelID)
    if bIsPassed and iMaxStoryID < v.m_StoryID then
      StackFlow:Push(UIDefines.ID_FORM_ACTIVITY106_DIALOGUECLUE, {
        iActivityId = self.m_activityID,
        iStoryID = v.m_StoryID,
        bIsSolo = true
      })
      HeroActivityManager:SetClientData(self.m_activityID, key, tostring(v.m_StoryID))
      break
    end
  end
end

function Form_Activity106_DialogueMain:OnBtndrawClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY106_DIALOGUECLUE, {
    iActivityId = self.m_activityID
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity106_DialogueMain", Form_Activity106_DialogueMain)
return Form_Activity106_DialogueMain
