local UIHeroActChallengeBase = class("UIHeroActChallengeBase", require("UI/Common/UIBase"))
local UpdateDeltaNum = 3
local MaxLevelNum = 5
local MidItemIndex = 2
local ItemMoveTime = 0.3
local ItemMoveParam = 328
local BaseMovePosX = 151

function UIHeroActChallengeBase:AfterInit()
  UIHeroActChallengeBase.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1118)
  self.m_activityID = nil
  self.m_activitySubID = nil
  local challengeInitData = {
    itemClkBackFun = handler(self, self.OnChallengeItemClk)
  }
  self.m_luaChallengeLevelGrid = self:CreateInfinityGrid(self.m_level_list_InfinityGrid, "LamiaLevel/UILamiaChallengeLevelItem", challengeInitData)
  self.m_levelHelper = LevelHeroLamiaActivityManager:GetLevelHelper()
  self.m_levelDataList = nil
  self.m_curDetailLevelID = nil
  self.m_luaDetailLevel = nil
  self.m_currentLevelID = nil
  self.m_isCanUpdateLeftTime = false
  self.m_curDeltaTimeNum = 0
  self.m_showEndTime = nil
  self.m_levelListTrans = self.m_level_list.transform
  self.m_itemMoveTween = nil
end

function UIHeroActChallengeBase:OnActive()
  UIHeroActChallengeBase.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  self.openTime = TimeUtil:GetServerTimeS()
  self.report_name = self.m_activityID .. "/" .. self:GetFramePrefabName()
  HeroActivityManager:ReportActOpen(self.report_name, {
    openTime = self.openTime
  })
end

function UIHeroActChallengeBase:OnInactive()
  UIHeroActChallengeBase.super.OnInactive(self)
  self:RemoveAllEventListeners()
  HeroActivityManager:ReportActClose(self.report_name, {
    openTime = self.openTime
  })
end

function UIHeroActChallengeBase:OnDestroy()
  UIHeroActChallengeBase.super.OnDestroy(self)
  self:ClearCacheData()
end

function UIHeroActChallengeBase:OnUpdate(dt)
  self:CheckUpdateLeftTime()
end

function UIHeroActChallengeBase:ClearCacheData()
  self.m_activityID = nil
  self.m_activitySubID = nil
  self.m_isCanUpdateLeftTime = false
  self.m_curDeltaTimeNum = 0
  self.m_showEndTime = nil
end

function UIHeroActChallengeBase:CheckUpdateLeftTime()
  if not self.m_isCanUpdateLeftTime then
    return
  end
  if not self.m_showEndTime then
    return
  end
  if self.m_curDeltaTimeNum <= UpdateDeltaNum then
    self.m_curDeltaTimeNum = self.m_curDeltaTimeNum + 1
  else
    self.m_curDeltaTimeNum = 0
    self:ShowLeftTimeStr()
  end
end

function UIHeroActChallengeBase:ShowLeftTimeStr()
  local nextResetTimer = self.m_showEndTime
  local curTimer = TimeUtil:GetServerTimeS()
  local leftTimeSec = nextResetTimer - curTimer
  if leftTimeSec <= 0 then
    leftTimeSec = 0
    self.m_isCanUpdateLeftTime = false
    return
  end
  self.m_txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(leftTimeSec)
end

function UIHeroActChallengeBase:FreshUI()
  local subActCfg = HeroActivityManager:GetSubInfoByID(self.m_activitySubID) or {}
  local endTime = TimeUtil:TimeStringToTimeSec2(subActCfg.m_EndTime) or 0
  local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.sub, self.m_activitySubID)
  if is_corved then
    endTime = t2
  end
  self.m_showEndTime = endTime
  self.m_isCanUpdateLeftTime = true
  self:FreshLevelList()
  self.m_curDetailLevelID = self.m_currentLevelID
  self:FreshLevelDetailShow(true)
  self:FreshLeftTimes()
  self:BackTweenToInit()
end

function UIHeroActChallengeBase:FreshLeftTimes()
  if not self.m_activityID then
    return
  end
  local curUseTimes = self.m_levelHelper:GetDailyTimesBySubActivityAndSubID(self.m_activityID, self.m_activitySubID) or 0
  local totalFreeNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ActLamiaChallengeDailyLimit") or 0)
  local leftNums = totalFreeNum - curUseTimes
  self.m_txt_challenge_time_Text.text = leftNums .. "/" .. totalFreeNum
end

function UIHeroActChallengeBase:FreshLevelDetailShow()
end

function UIHeroActChallengeBase:FreshLevelList()
  local levelData = self.m_levelHelper:GetLevelDataByActAndSubID(self.m_activityID, self.m_activitySubID) or {}
  local levelCfgList = levelData.levelCfgList
  local lastPassLevelID = self.m_levelHelper:GetLastPassLevelIDByActIDAndSubID(self.m_activityID, self.m_activitySubID) or 0
  local showLevelItemList = {}
  local moveIndex, currentLevelID = 1
  for index, tempCfg in ipairs(levelCfgList) do
    local isCurrent = tempCfg.m_PreLevel == lastPassLevelID
    local tempShowLevelItem = {levelCfg = tempCfg, isChoose = isCurrent}
    showLevelItemList[#showLevelItemList + 1] = tempShowLevelItem
    if isCurrent then
      moveIndex = index
      currentLevelID = tempCfg.m_LevelID
    end
  end
  self.m_levelDataList = showLevelItemList
  self.m_luaChallengeLevelGrid:ShowItemList(self.m_levelDataList)
  self.m_luaChallengeLevelGrid:LocateTo(moveIndex - 1)
  self.m_currentLevelID = currentLevelID
end

function UIHeroActChallengeBase:BackTweenToInit()
  self:CheckKillTween()
  self.m_itemMoveTween = self.m_levelListTrans:DOLocalMoveX(BaseMovePosX, ItemMoveTime)
  self.m_itemMoveTween:PlayForward()
  self.m_itemMoveTween:OnKill(handler(self, self.OnItemMoveKillWithBack))
end

function UIHeroActChallengeBase:CheckKillTween()
  if self.m_itemMoveTween and self.m_itemMoveTween:IsPlaying() then
    self.m_itemMoveTween:Kill()
    self.m_itemMoveTween = nil
  end
end

function UIHeroActChallengeBase:ChooseItemTween(index)
  if not index then
    return
  end
  if index > MaxLevelNum then
    return
  end
  self:CheckKillTween()
  local moveX = BaseMovePosX - (index - MidItemIndex) * ItemMoveParam
  self.m_itemMoveTween = self.m_levelListTrans:DOLocalMoveX(moveX, ItemMoveTime)
  self.m_itemMoveTween:PlayForward()
  self.m_itemMoveTween:OnKill(handler(self, self.OnItemMoveKill))
end

function UIHeroActChallengeBase:OnItemMoveKill()
  self.m_itemMoveTween = nil
end

function UIHeroActChallengeBase:OnItemMoveKillWithBack()
  self.m_itemMoveTween = nil
  local _, posY, PosZ = UILuaHelper.GetLocalPosition(self.m_levelListTrans)
  UILuaHelper.SetLocalPosition(self.m_levelListTrans, BaseMovePosX, posY, PosZ)
end

function UIHeroActChallengeBase:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_activityID = tonumber(tParam.main_id)
    self.m_activitySubID = tonumber(tParam.sub_id)
    self.m_csui.m_param = nil
  end
end

function UIHeroActChallengeBase:GetLevelIndexByLevelID(levelID)
  if not levelID then
    return
  end
  local levelDataList = self.m_levelDataList
  for i, v in ipairs(levelDataList) do
    if v.levelCfg.m_LevelID == levelID then
      return i
    end
  end
end

function UIHeroActChallengeBase:AddEventListeners()
  self:addEventListener("eGameEvent_HeroAct_DailyReset", handler(self, self.OnHeroActDailyReset))
  if self.m_luaDetailLevel then
    self.m_luaDetailLevel:AddEventListeners()
  end
end

function UIHeroActChallengeBase:RemoveAllEventListeners()
  if self.m_luaDetailLevel then
    self.m_luaDetailLevel:RemoveAllEventListeners()
  end
  self:clearEventListener()
end

function UIHeroActChallengeBase:OnHeroActDailyReset()
  if not self.m_activityID then
    return
  end
  local isOpen = HeroActivityManager:IsSubActIsOpenByID(self.m_activityID, self.m_activitySubID)
  if isOpen ~= true then
    self:CloseForm()
    return
  end
  self:FreshLeftTimes()
end

function UIHeroActChallengeBase:OnBackClk()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.m_activityID
  })
  self:CloseForm()
end

function UIHeroActChallengeBase:OnChallengeItemClk(index)
  if not index then
    return
  end
  if self.m_curDetailLevelID then
    local lastIndex = self:GetLevelIndexByLevelID(self.m_curDetailLevelID)
    local lastItem = self.m_luaChallengeLevelGrid:GetShowItemByIndex(lastIndex)
    if lastItem then
      lastItem:ChangeChoose(false)
    end
  end
  local levelList = self.m_levelDataList
  if not levelList then
    return
  end
  local curLevelData = levelList[index]
  self.m_curDetailLevelID = curLevelData.levelCfg.m_LevelID
  self:FreshLevelDetailShow()
  self:ChooseItemTween(index)
end

function UIHeroActChallengeBase:OnLevelDetailBgClick()
  if self.m_curDetailLevelID then
    local lastIndex = self:GetLevelIndexByLevelID(self.m_curDetailLevelID)
    local lastItem = self.m_luaChallengeLevelGrid:GetShowItemByIndex(lastIndex)
    if lastItem then
      lastItem:ChangeChoose(false)
    end
    self.m_curDetailLevelID = nil
    self:FreshLevelDetailShow()
    self:BackTweenToInit()
  end
end

function UIHeroActChallengeBase:IsFullScreen()
  return true
end

function UIHeroActChallengeBase:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  if tParam.main_id then
    local act_id = tParam.main_id
    local subActivityID = HeroActivityManager:GetSubFuncID(act_id, HeroActivityManager.SubActTypeEnum.ChallengeLevel)
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
  return vPackage, vResourceExtra
end

return UIHeroActChallengeBase
