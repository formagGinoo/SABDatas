local Form_ActivityDayTask = class("Form_ActivityDayTask", require("UI/UIFrames/Form_ActivityDayTaskUI"))
local DefaultShowSpineName = "saint_base"
local RewardStatus = {
  CannotTake = 1,
  CanTake = 2,
  Taken = 3
}
local QuestStatusPriority = {
  [MTTDProto.QuestState_Finish] = 1,
  [MTTDProto.QuestState_Doing] = 2,
  [MTTDProto.QuestState_Over] = 3
}
local ScrollViewAnimStr = "m_scrollView_in"

function Form_ActivityDayTask:SetInitParam(param)
end

function Form_ActivityDayTask:AfterInit()
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.Back))
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_ActivityDayTask:OnActive()
  self.super.OnActive(self)
  self:LoadShowSpine()
  self:RefreshUI()
  self:RemoveEventListeners()
  self.m_iHandlerIDUpdateQuest = self:addEventListener("eGameEvent_Activity_CommonQuest_UpdateQuest", handler(self, self.OnEventUpdateQuest))
  self.m_iHandlerIDTakeQuestReward = self:addEventListener("eGameEvent_Activity_CommonQuest_TakeQuestReward", handler(self, self.OnEventTakeQuestReward))
  self.m_iHandlerIDTakeDailyReward = self:addEventListener("eGameEvent_Activity_CommonQuest_TakeDailyReward", handler(self, self.OnEventTakeDailyReward))
  self.m_iHandlerIDTakeFinalReward = self:addEventListener("eGameEvent_Activity_CommonQuest_TakeFinalReward", handler(self, self.OnEventTakeFinalReward))
  self.m_iHandlerIDReload = self:addEventListener("eGameEvent_Activity_Reload", handler(self, self.OnEventActivityReload))
end

function Form_ActivityDayTask:RemoveEventListeners()
  if self.m_iHandlerIDUpdateQuest then
    self:removeEventListener("eGameEvent_Activity_CommonQuest_UpdateQuest", self.m_iHandlerIDUpdateQuest)
    self.m_iHandlerIDUpdateQuest = nil
  end
  if self.m_iHandlerIDTakeQuestReward then
    self:removeEventListener("eGameEvent_Activity_CommonQuest_TakeQuestReward", self.m_iHandlerIDTakeQuestReward)
    self.m_iHandlerIDTakeQuestReward = nil
  end
  if self.m_iHandlerIDTakeDailyReward then
    self:removeEventListener("eGameEvent_Activity_CommonQuest_TakeDailyReward", self.m_iHandlerIDTakeDailyReward)
    self.m_iHandlerIDTakeDailyReward = nil
  end
  if self.m_iHandlerIDTakeFinalReward then
    self:removeEventListener("eGameEvent_Activity_CommonQuest_TakeFinalReward", self.m_iHandlerIDTakeFinalReward)
    self.m_iHandlerIDTakeFinalReward = nil
  end
  if self.m_iHandlerIDReload then
    self:removeEventListener("eGameEvent_Activity_Reload", self.m_iHandlerIDReload)
    self.m_iHandlerIDReload = nil
  end
end

function Form_ActivityDayTask:OnInactive()
  self:RemoveEventListeners()
  self:CheckRecycleSpine(true)
end

function Form_ActivityDayTask:OnUpdate(dt)
  self:RefreshRemainTime()
end

function Form_ActivityDayTask:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function Form_ActivityDayTask:RefreshUI()
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_CommonQuest)
  for _, act in pairs(act_list) do
    if act:GetUIType() == GlobalConfig.CommonQuestActType.DayTask_7 then
      self.m_stActivity = act
      break
    end
  end
  if self.m_stActivity == nil then
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYDAYTASK)
    return
  end
  self:RefreshDailyTaskTab(true)
  self:RefreshDailyReward()
  self:RefreshFinalReward()
  self:RefreshRemainTime()
  self:refreshTaskLoopScroll()
end

function Form_ActivityDayTask:RefreshDailyTaskTab(bInit)
  local iActiveDay = self.m_stActivity:GetActiveDay()
  iActiveDay = math.min(iActiveDay, 7)
  local iSelectedDay
  if bInit then
    self.m_iSelectedDay = nil
  end
  for iDay = 1, iActiveDay do
    local goBtnDay = self["m_btn_day" .. iDay]
    goBtnDay.transform:Find("img_lock").gameObject:SetActive(false)
    local bShowRed = self.m_stActivity:CheckShowRedByDay(iDay)
    if bShowRed and iSelectedDay == nil then
      iSelectedDay = iDay
    end
    goBtnDay.transform:Find("img_red").gameObject:SetActive(bShowRed)
  end
  for iDay = iActiveDay + 1, 7 do
    local goBtnDay = self["m_btn_day" .. iDay]
    goBtnDay.transform:Find("img_lock").gameObject:SetActive(true)
    goBtnDay.transform:Find("txt_day_unselect" .. iDay).gameObject:SetActive(false)
    goBtnDay.transform:Find("img_red").gameObject:SetActive(false)
  end
  self:SetDailyTaskTabSelected(self.m_iSelectedDay)
  if bInit then
    self:SelectDay(iSelectedDay or iActiveDay, true)
  end
end

function Form_ActivityDayTask:SetDailyTaskTabSelected(iDay)
  if iDay == nil then
    return
  end
  local iActiveDay = self.m_stActivity:GetActiveDay()
  iActiveDay = math.min(iActiveDay, 7)
  local daysState = self:CheckEveryDayQuestState()
  for i = 1, 7 do
    local goBtnDayObj = self["m_btn_day" .. i]
    if goBtnDayObj then
      if iDay == i then
        goBtnDayObj.transform:Find("img_red_line").gameObject:SetActive(true)
        goBtnDayObj.transform:Find("img_fin").gameObject:SetActive(false)
        goBtnDayObj.transform:Find("txt_day_unselect" .. i).gameObject:SetActive(false)
      else
        goBtnDayObj.transform:Find("img_fin").gameObject:SetActive(daysState[i] == MTTDProto.QuestState_Over)
        goBtnDayObj.transform:Find("txt_day_unselect" .. i).gameObject:SetActive(daysState[i] ~= MTTDProto.QuestState_Over and i <= iActiveDay)
        goBtnDayObj.transform:Find("img_red_line").gameObject:SetActive(false)
      end
    end
  end
end

function Form_ActivityDayTask:SelectDay(iDay, isEnterFresh)
  if iDay == self.m_iSelectedDay then
    return
  end
  if iDay > self.m_stActivity:GetActiveDay() then
    local sToast = ConfigManager:GetCommonTextById(20010)
    local iCommonQuestRefreshTime = self.m_stActivity:GetCommonQuestRefreshTime()
    local iServerTime = TimeUtil:GetServerTimeS()
    sToast = string.gsub(sToast, "{time}", TimeUtil:SecondsToFormatStrDHOrHMS(iCommonQuestRefreshTime - iServerTime))
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, sToast)
    return
  end
  self.m_iSelectedDay = iDay
  self:SetDailyTaskTabSelected(self.m_iSelectedDay)
  self:RefreshDailyReward()
  self:refreshTaskLoopScroll()
  if not isEnterFresh then
    UILuaHelper.PlayAnimationByName(self.m_scrollView, ScrollViewAnimStr)
  end
end

function Form_ActivityDayTask:OnBtnday1Clicked()
  self:SelectDay(1)
end

function Form_ActivityDayTask:OnBtnday2Clicked()
  self:SelectDay(2)
end

function Form_ActivityDayTask:OnBtnday3Clicked()
  self:SelectDay(3)
end

function Form_ActivityDayTask:OnBtnday4Clicked()
  self:SelectDay(4)
end

function Form_ActivityDayTask:OnBtnday5Clicked()
  self:SelectDay(5)
end

function Form_ActivityDayTask:OnBtnday6Clicked()
  self:SelectDay(6)
end

function Form_ActivityDayTask:OnBtnday7Clicked()
  self:SelectDay(7)
end

function Form_ActivityDayTask:RefreshDailyReward()
  local iScoreCur = self.m_stActivity:GetScore(self.m_iSelectedDay)
  local stDailyRewardConfig = self.m_stActivity:GetDailyRewardConfig(self.m_iSelectedDay)
  self.m_txt_dailyreward_progress_max_Text.text = string.format(ConfigManager:GetCommonTextById(100035), iScoreCur, stDailyRewardConfig.iNeedScore)
  for i = 1, 7 do
    if self["m_bar_dailyreward_point" .. i] then
      self["m_bar_dailyreward_point" .. i]:SetActive(iScoreCur >= i)
    end
  end
  self.m_pnl_item_dailyreward:SetActive(true)
  if self.m_widgetItemIconDailyReward == nil then
    self.m_widgetItemIconDailyReward = self:createCommonItem(self.m_pnl_item_dailyreward)
  end
  local stDailyReward = stDailyRewardConfig.vReward[1]
  local processData = ResourceUtil:GetProcessRewardData(stDailyReward)
  self.m_widgetItemIconDailyReward:SetItemInfo(processData)
  if iScoreCur < stDailyRewardConfig.iNeedScore then
    self.m_pnl_item_dailyreward.transform:Find("c_img_mask").gameObject:SetActive(false)
    self.m_pnl_item_dailyreward.transform:Find("c_item_receive").gameObject:SetActive(false)
    self.m_pnl_item_dailyreward.transform:Find("m_item_dailyreward_fx_Loop").gameObject:SetActive(false)
    self.m_widgetItemIconDailyReward:SetItemIconClickCB(handler(self, self.OnItemIconClicked))
  elseif not self.m_stActivity:IsDailyRewardTaken(self.m_iSelectedDay) then
    self.m_pnl_item_dailyreward.transform:Find("c_img_mask").gameObject:SetActive(false)
    self.m_pnl_item_dailyreward.transform:Find("c_item_receive").gameObject:SetActive(false)
    self.m_pnl_item_dailyreward.transform:Find("m_item_dailyreward_fx_Loop").gameObject:SetActive(true)
    self.m_widgetItemIconDailyReward:SetItemIconClickCB(handler(self, self.OnClaimDailyRewardClicked))
  else
    self.m_pnl_item_dailyreward.transform:Find("c_img_mask").gameObject:SetActive(true)
    self.m_pnl_item_dailyreward.transform:Find("c_item_receive").gameObject:SetActive(true)
    self.m_pnl_item_dailyreward.transform:Find("m_item_dailyreward_fx_Loop").gameObject:SetActive(false)
    self.m_widgetItemIconDailyReward:SetItemIconClickCB(handler(self, self.OnItemIconClicked))
  end
end

function Form_ActivityDayTask:OnItemIconClicked(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function Form_ActivityDayTask:OnClaimDailyRewardClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self.m_stActivity:RequestTakeDailyReward(self.m_iSelectedDay)
end

function Form_ActivityDayTask:RefreshFinalReward()
  local iScoreCur = self.m_stActivity:GetScore()
  local mFinalRewardConfig = self.m_stActivity:GetFinalRewardConfig()
  local vFinalRewardTakenInfo = self.m_stActivity:GetFinalRewardTakenInfo()
  local iScoreNext, stRewardConfigNext, iScoreMax, stRewardConfigMax
  for iScoreTmp, stFinalRewardConfig in pairs(mFinalRewardConfig) do
    local bTaken = false
    for _, iScoreTaken in ipairs(vFinalRewardTakenInfo) do
      if iScoreTmp == iScoreTaken then
        bTaken = true
        break
      end
    end
    if not bTaken and (iScoreNext == nil or iScoreTmp < iScoreNext) then
      iScoreNext = iScoreTmp
      stRewardConfigNext = stFinalRewardConfig
    end
    if iScoreMax == nil or iScoreTmp > iScoreMax then
      iScoreMax = iScoreTmp
      stRewardConfigMax = stFinalRewardConfig
    end
  end
  local iFinalRewardStatus
  if iScoreNext == nil then
    iFinalRewardStatus = RewardStatus.Taken
    iScoreNext = iScoreMax
    stRewardConfigNext = stRewardConfigMax
  elseif iScoreCur >= iScoreNext then
    iFinalRewardStatus = RewardStatus.CanTake
  else
    iFinalRewardStatus = RewardStatus.CannotTake
  end
  self.m_iFinalRewardScoreNext = iScoreNext
  self.m_stFinalRewardConfigNext = stRewardConfigNext
  if iFinalRewardStatus == RewardStatus.CannotTake then
    self.m_bar_finalreward_bg:SetActive(true)
    self.m_bar_finalreward_Image.fillAmount = math.min(iScoreCur / iScoreNext, 1)
    self.m_txt_finalreward_max_Text.text = string.format(ConfigManager:GetCommonTextById(100036), iScoreCur, iScoreNext)
    self.m_btn_finalreward_receive:SetActive(false)
    self.m_bg_finalreward_received:SetActive(false)
  elseif iFinalRewardStatus == RewardStatus.CanTake then
    self.m_bar_finalreward_bg:SetActive(false)
    self.m_btn_finalreward_receive:SetActive(true)
    self.m_bg_finalreward_received:SetActive(false)
  else
    self.m_bar_finalreward_bg:SetActive(false)
    self.m_btn_finalreward_receive:SetActive(false)
    self.m_bg_finalreward_received:SetActive(true)
  end
end

function Form_ActivityDayTask:OnBtnfinalrewardreceiveClicked()
  self.m_stActivity:RequestTakeFinalReward(self.m_iFinalRewardScoreNext)
end

function Form_ActivityDayTask:RefreshRemainTime()
  self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_stActivity:getActivityRemainTime())
end

function Form_ActivityDayTask:OnEventUpdateQuest(tParam)
  if tParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  local vQuestStatusChanged = tParam.vQuestStatusChanged
  local vQuestInfo = self.m_stActivity:GetQuestInfo(self.m_iSelectedDay)
  local bRefreshDailyTask = false
  for _, stQuestStatus in pairs(vQuestStatusChanged) do
    for _, stQuestInfo in pairs(vQuestInfo) do
      if stQuestInfo.stQuestConfig.iId == stQuestStatus.iId then
        bRefreshDailyTask = true
        break
      end
    end
    if bRefreshDailyTask then
      break
    end
  end
  self:RefreshDailyTaskTab(false)
  if bRefreshDailyTask then
    self:refreshTaskLoopScroll()
  end
end

function Form_ActivityDayTask:OnEventTakeQuestReward(sc)
  if sc.iQuestType ~= self.m_stActivity:getID() then
    return
  end
  utils.popUpRewardUI(sc.vReward)
  self:RefreshDailyReward()
  self:RefreshFinalReward()
end

function Form_ActivityDayTask:OnEventTakeDailyReward(sc)
  if sc.iActivityId ~= self.m_stActivity:getID() then
    return
  end
  utils.popUpRewardUI(sc.vReward)
  self:RefreshDailyTaskTab(false)
  if sc.iDay == self.m_iSelectedDay then
    self:RefreshDailyReward()
  end
end

function Form_ActivityDayTask:OnEventTakeFinalReward(sc)
  if sc.iActivityId ~= self.m_stActivity:getID() then
    return
  end
  utils.popUpRewardUI(sc.vReward)
  self:RefreshFinalReward()
end

function Form_ActivityDayTask:OnEventActivityReload()
  self:RefreshUI()
end

function Form_ActivityDayTask:OnBtnsearchClicked()
  if self.m_stFinalRewardConfigNext and next(self.m_stFinalRewardConfigNext) then
    local itemData = self.m_stFinalRewardConfigNext[1]
    utils.openItemDetailPop({
      iID = itemData.iID,
      iNum = itemData.iNum
    })
  end
end

function Form_ActivityDayTask:Back()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYDAYTASK)
end

function Form_ActivityDayTask:refreshTaskLoopScroll()
  self.m_click_cell_object = nil
  local data = self.m_stActivity:GetQuestInfo(self.m_iSelectedDay)
  table.sort(data, function(a, b)
    if a.stQuestStatus.iState == b.stQuestStatus.iState then
      return a.stQuestConfig.iId < b.stQuestConfig.iId
    else
      return QuestStatusPriority[a.stQuestStatus.iState] < QuestStatusPriority[b.stQuestStatus.iState]
    end
  end)
  if self.m_loop_scroll_view == nil then
    local loopscroll = self.m_scrollView
    local params = {
      show_data = data,
      loop_scroll_object = loopscroll,
      update_cell = function(index, cell_object, cell_data)
        self:updateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if click_name == "c_btn_go" then
          CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
          QuickOpenFuncUtil:OpenFunc(cell_data.stQuestConfig.iJump)
        elseif click_name == "c_btn_receive" then
          CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
          self.m_stActivity:RequestTakeQuestReward({
            cell_data.stQuestConfig.iId
          })
          self.m_move_to_id = cell_data.stQuestConfig.iId
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  elseif self.m_move_to_id then
    self.m_loop_scroll_view:reloadData(data)
    self.m_move_to_id = nil
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function Form_ActivityDayTask:updateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local node = luaBehaviour:FindGameObject("node")
  local stQuestConfig = cell_data.stQuestConfig
  local stQuestStatus = cell_data.stQuestStatus
  local stepNum = 0
  if stQuestStatus.iState == MTTDProto.QuestState_Doing then
    stepNum = stQuestStatus.vCondStep[1] or 0
  elseif stQuestStatus.iState == MTTDProto.QuestState_Finish then
    stepNum = stQuestConfig.iObjectiveCount or 0
  else
    stepNum = stQuestConfig.iObjectiveCount or 0
  end
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_progress_cur", stepNum)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_progress_max", stQuestConfig.iObjectiveCount or "0")
  if not stQuestConfig.iObjectiveCount or tostring(stQuestConfig.iObjectiveCount) == "0" or stQuestStatus.iState ~= MTTDProto.QuestState_Doing then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_bg_bar", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_progress_cur", false)
  else
    local imgBar = LuaBehaviourUtil.findImg(luaBehaviour, "m_img_bar")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_bg_bar", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_progress_cur", true)
    imgBar.fillAmount = tonumber(stepNum) / tonumber(stQuestConfig.iObjectiveCount)
  end
  if stQuestConfig.iJump ~= 0 then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_doing", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_btn_go", stQuestStatus.iState == MTTDProto.QuestState_Doing)
  else
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_doing", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_btn_go", false)
  end
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_btn_receive", stQuestStatus.iState == MTTDProto.QuestState_Finish)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_complete", stQuestStatus.iState ~= MTTDProto.QuestState_Doing and stQuestStatus.iState ~= MTTDProto.QuestState_Finish)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_bg_tab02", stQuestStatus.iState ~= MTTDProto.QuestState_Doing and stQuestStatus.iState ~= MTTDProto.QuestState_Finish)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_content", self.m_stActivity:getLangText(stQuestConfig.sName))
  local iRewardCount = math.min(#stQuestConfig.vReward, 2)
  for iRewardIndex = 1, iRewardCount do
    local stReward = stQuestConfig.vReward[iRewardIndex]
    local panelRewardItem = luaBehaviour:FindGameObject("c_common_item" .. iRewardIndex)
    panelRewardItem.gameObject:SetActive(true)
    self:removeWidget(panelRewardItem.gameObject)
    local commonItem = self:createCommonItem(panelRewardItem.gameObject)
    local processData = ResourceUtil:GetProcessRewardData(stReward)
    commonItem:SetItemInfo(processData)
    commonItem:SetItemIconClickCB(handler(self, self.OnItemIconClicked))
  end
  for iRewardIndex = iRewardCount + 1, 2 do
    local panelRewardItem = luaBehaviour:FindGameObject("c_common_item" .. iRewardIndex)
    panelRewardItem.gameObject:SetActive(false)
  end
end

function Form_ActivityDayTask:CheckEveryDayQuestState()
  local sevenDayState = {}
  for i = 1, 7 do
    local data = self.m_stActivity:GetQuestInfo(i)
    for m, n in ipairs(data) do
      if n.stQuestStatus.iState ~= MTTDProto.QuestState_Over then
        sevenDayState[i] = MTTDProto.QuestState_Doing
      end
    end
    if not sevenDayState[i] then
      sevenDayState[i] = MTTDProto.QuestState_Over
    end
  end
  return sevenDayState
end

function Form_ActivityDayTask:IsFullScreen()
  return true
end

function Form_ActivityDayTask:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleObjectByName(DefaultShowSpineName, self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_ActivityDayTask:LoadShowSpine()
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  self.m_HeroSpineDynamicLoader:GetObjectByName(DefaultShowSpineName, function(nameStr, object)
    self:CheckRecycleSpine()
    UILuaHelper.SetParent(object, self.m_root_hero, true)
    UILuaHelper.SetActive(object, true)
    UILuaHelper.SpineResetMatParam(object)
    self.m_curHeroSpineObj = object
  end)
end

function Form_ActivityDayTask:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  vResourceExtra[#vResourceExtra + 1] = {
    sName = DefaultShowSpineName,
    eType = DownloadManager.ResourceType.UI
  }
  return vPackage, vResourceExtra
end

ActiveLuaUI("Form_ActivityDayTask", Form_ActivityDayTask)
return Form_ActivityDayTask
