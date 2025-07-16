local Form_Activity103Luoleilai_Challenge = class("Form_Activity103Luoleilai_Challenge", require("UI/UIFrames/Form_Activity103Luoleilai_ChallengeUI"))

function Form_Activity103Luoleilai_Challenge:SetInitParam(param)
end

function Form_Activity103Luoleilai_Challenge:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1118)
  self.m_levelHelper = LevelHeroLamiaActivityManager:GetLevelHelper()
  self.UpdateDeltaNum = 3
  self.iMaxPage = 2
  self.iPerPageLevelNum = 5
  self.iSpecialIdx = 4
  self.m_curDeltaTimeNum = 0
  self.m_showEndTime = nil
  self.m_luaDetailLevel = nil
  self.cItemClass = require("UI/Item/LamiaLevel/UI103ChallengLevelItem")
  self.m_itemCache = {}
  self.luaItemClassCache = {}
  self.luaFakeItemClassCache = {}
  self.InitData = {
    itemClkBackFun = handler(self, self.OnChallengeItemClk)
  }
end

function Form_Activity103Luoleilai_Challenge:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  self.openTime = TimeUtil:GetServerTimeS()
  self.report_name = self.m_activityID .. "/" .. self:GetFramePrefabName()
  HeroActivityManager:ReportActOpen(self.report_name, {
    openTime = self.openTime
  })
  CS.GlobalManager.Instance:TriggerWwiseBGMState(149)
end

function Form_Activity103Luoleilai_Challenge:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  HeroActivityManager:ReportActClose(self.report_name, {
    openTime = self.openTime
  })
  if self.m_UILockID then
    UILockIns:Unlock(self.m_UILockID)
    self.m_UILockID = nil
  end
  if self.m_page_timer then
    TimeService:KillTimer(self.m_page_timer)
    self.m_page_timer = nil
  end
end

function Form_Activity103Luoleilai_Challenge:OnUpdate(dt)
  self:CheckUpdateLeftTime()
end

function Form_Activity103Luoleilai_Challenge:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity103Luoleilai_Challenge:AddEventListeners()
  self:addEventListener("eGameEvent_HeroAct_DailyReset", handler(self, self.OnHeroActDailyReset))
  if self.m_luaDetailLevel then
    self.m_luaDetailLevel:AddEventListeners()
  end
end

function Form_Activity103Luoleilai_Challenge:RemoveAllEventListeners()
  if self.m_luaDetailLevel then
    self.m_luaDetailLevel:RemoveAllEventListeners()
  end
  self:clearEventListener()
end

function Form_Activity103Luoleilai_Challenge:OnHeroActDailyReset()
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

function Form_Activity103Luoleilai_Challenge:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_activityID = tonumber(tParam.main_id)
    self.m_activitySubID = tonumber(tParam.sub_id)
    self.m_csui.m_param = nil
  end
end

function Form_Activity103Luoleilai_Challenge:FreshUI()
  local subActCfg = HeroActivityManager:GetSubInfoByID(self.m_activitySubID) or {}
  local endTime = TimeUtil:TimeStringToTimeSec2(subActCfg.m_EndTime) or 0
  local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.sub, self.m_activitySubID)
  if is_corved then
    endTime = t2
  end
  self.m_showEndTime = endTime
  self.m_isCanUpdateLeftTime = true
  self.iCurPage = 1
  self:FreshLeftTimes()
  self:FreshLevelList()
  self.m_curDetailLevelID = self.m_currentLevelID
  self:FreshCurPage()
  self:FreshLevelDetailShow(true)
end

function Form_Activity103Luoleilai_Challenge:FreshLevelList()
  local levelData = self.m_levelHelper:GetLevelDataByActAndSubID(self.m_activityID, self.m_activitySubID) or {}
  local levelCfgList = levelData.levelCfgList
  local lastPassLevelID = self.m_levelHelper:GetLastPassLevelIDByActIDAndSubID(self.m_activityID, self.m_activitySubID) or 0
  local showLevelItemList = {}
  local iCurIdx, currentLevelID = 1
  local helper = LevelHeroLamiaActivityManager:GetLevelHelper()
  for index, tempCfg in ipairs(levelCfgList) do
    local isCurrent = tempCfg.m_PreLevel == lastPassLevelID and helper and helper:IsLevelUnLock(tempCfg.m_LevelID)
    local tempShowLevelItem = {levelCfg = tempCfg, isChoose = isCurrent}
    table.insert(showLevelItemList, tempShowLevelItem)
    if isCurrent then
      iCurIdx = index
      currentLevelID = tempCfg.m_LevelID
    end
  end
  self.m_levelDataList = showLevelItemList
  self.m_currentLevelID = currentLevelID
  self.iCurPage = math.ceil(iCurIdx / self.iPerPageLevelNum)
  self:FreshLevelItems()
end

function Form_Activity103Luoleilai_Challenge:FreshLevelItems()
  if not self.m_levelDataList then
    return
  end
  for i = 1, #self.m_levelDataList do
    local tempItem = self.m_levelDataList[i]
    local go = self["m_levelnode_" .. i]
    local fake_go = self["m_levelnode_fake" .. i]
    if tempItem and tempItem.levelCfg then
      local tempLevelCfg = tempItem.levelCfg
      if go then
        local iHashCode = go:GetHashCode()
        if not self.m_itemCache[iHashCode] then
          self.m_itemCache[iHashCode] = self.cItemClass.new(nil, go, self.InitData, tempItem, i)
        else
          self.m_itemCache[iHashCode]:FreshData(tempItem, i)
        end
        self.luaItemClassCache[i] = self.m_itemCache[iHashCode]
      end
      if fake_go then
        local iHashCode = fake_go:GetHashCode()
        if not self.m_itemCache[iHashCode] then
          self.m_itemCache[iHashCode] = self.cItemClass.new(nil, fake_go, self.InitData, tempItem, i)
        else
          self.m_itemCache[iHashCode]:FreshData(tempItem, i)
        end
        self.luaFakeItemClassCache[i] = self.m_itemCache[iHashCode]
      end
    end
  end
end

function Form_Activity103Luoleilai_Challenge:FreshCurPage()
  self.m_level_list1:SetActive(self.iCurPage == 1)
  self.m_level_list2:SetActive(self.iCurPage == 2)
  self.m_btn_arrorl:SetActive(self.iCurPage > 1)
  self.m_btn_arrorr:SetActive(self.iCurPage < self.iMaxPage)
end

function Form_Activity103Luoleilai_Challenge:FreshLevelDetailShow(forceHide)
  if forceHide then
    UILuaHelper.SetActive(self.m_level_detail_root, false)
    return
  end
  if self.m_curDetailLevelID then
    UILuaHelper.SetActive(self.m_level_detail_root, true)
    if self.m_luaDetailLevel == nil then
      self:CreateSubPanel("LevelDetailLuoleilaiSubPanel2", self.m_level_detail_root, self, {
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
  else
    UILuaHelper.SetActive(self.m_level_detail_root, false)
  end
end

function Form_Activity103Luoleilai_Challenge:FreshLeftTimes()
  if not self.m_activityID then
    return
  end
  local curUseTimes = self.m_levelHelper:GetDailyTimesBySubActivityAndSubID(self.m_activityID, self.m_activitySubID) or 0
  local totalFreeNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ActLamiaChallengeDailyLimit") or 0)
  local leftNums = totalFreeNum - curUseTimes
  self.m_txt_challenge_time_Text.text = leftNums .. "/" .. totalFreeNum
end

function Form_Activity103Luoleilai_Challenge:ClearCacheData()
  self.m_activityID = nil
  self.m_activitySubID = nil
  self.m_isCanUpdateLeftTime = false
  self.m_curDeltaTimeNum = 0
  self.m_showEndTime = nil
end

function Form_Activity103Luoleilai_Challenge:CheckUpdateLeftTime()
  if not self.m_isCanUpdateLeftTime then
    return
  end
  if not self.m_showEndTime then
    return
  end
  if self.m_curDeltaTimeNum <= self.UpdateDeltaNum then
    self.m_curDeltaTimeNum = self.m_curDeltaTimeNum + 1
  else
    self.m_curDeltaTimeNum = 0
    self:ShowLeftTimeStr()
  end
end

function Form_Activity103Luoleilai_Challenge:ShowLeftTimeStr()
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

function Form_Activity103Luoleilai_Challenge:GetLevelIndexByLevelID(levelID)
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

function Form_Activity103Luoleilai_Challenge:OnChallengeItemClk(index)
  if not index then
    return
  end
  if self.m_curDetailLevelID then
    local lastIndex = self:GetLevelIndexByLevelID(self.m_curDetailLevelID)
    local lastItem = self.luaItemClassCache[lastIndex]
    if lastItem then
      lastItem:ChangeChoose(false)
    end
    local lastFakeItem = self.luaFakeItemClassCache[lastIndex]
    if lastFakeItem then
      lastFakeItem:ChangeChoose(false)
    end
  end
  local levelList = self.m_levelDataList
  if not levelList then
    return
  end
  local curLevelData = levelList[index]
  self.m_curDetailLevelID = curLevelData.levelCfg.m_LevelID
  self:FreshLevelDetailShow()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(17)
end

function Form_Activity103Luoleilai_Challenge:OnLevelDetailBgClick()
  if self.m_curDetailLevelID then
    self:FreshLevelDetailShow(true)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(34)
  end
end

function Form_Activity103Luoleilai_Challenge:OnBackClk()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.m_activityID
  })
  self:CloseForm()
end

function Form_Activity103Luoleilai_Challenge:OnBtnarrorlClicked()
  self.iCurPage = self.iCurPage - 1
  if self.iCurPage < 1 then
    self.iCurPage = 1
  end
  self:PlayPageTween()
end

function Form_Activity103Luoleilai_Challenge:OnBtnarrorrClicked()
  self.iCurPage = self.iCurPage + 1
  if self.iCurPage > self.iMaxPage then
    self.iCurPage = self.iMaxPage
  end
  self:PlayPageTween()
end

function Form_Activity103Luoleilai_Challenge:PlayPageTween()
  if self.iCurPage == 1 then
    UILuaHelper.PlayAnimationByName(self.m_level_list2, "Challenge_list2_out")
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_level_list2, "Challenge_list2_out")
    self.m_UILockID = UILockIns:Lock(aniLen)
    self.m_page_timer = TimeService:SetTimer(aniLen, 1, function()
      self:FreshCurPage()
      UILuaHelper.PlayAnimationByName(self.m_level_list1, "Challenge_list1_in")
      self.m_page_timer = nil
      if self.m_UILockID then
        UILockIns:Unlock(self.m_UILockID)
        self.m_UILockID = nil
      end
    end)
  else
    UILuaHelper.PlayAnimationByName(self.m_level_list1, "Challenge_list1_out")
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_level_list1, "Challenge_list1_out")
    self.m_UILockID = UILockIns:Lock(aniLen)
    self.m_page_timer = TimeService:SetTimer(aniLen, 1, function()
      self:FreshCurPage()
      UILuaHelper.PlayAnimationByName(self.m_level_list2, "Challenge_list2_in")
      self.m_page_timer = nil
      if self.m_UILockID then
        UILockIns:Unlock(self.m_UILockID)
        self.m_UILockID = nil
      end
    end)
  end
end

function Form_Activity103Luoleilai_Challenge:OnBtnheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_CHALLENGEHERO, {
    activityID = self.m_activityID
  })
end

function Form_Activity103Luoleilai_Challenge:OnBtnrewardClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_CHALLENGEREWARD, {
    activityID = self.m_activityID,
    activitySubID = self.m_activitySubID
  })
end

function Form_Activity103Luoleilai_Challenge:IsFullScreen()
  return true
end

function Form_Activity103Luoleilai_Challenge:GetDownloadResourceExtra(tParam)
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

local fullscreen = true
ActiveLuaUI("Form_Activity103Luoleilai_Challenge", Form_Activity103Luoleilai_Challenge)
return Form_Activity103Luoleilai_Challenge
