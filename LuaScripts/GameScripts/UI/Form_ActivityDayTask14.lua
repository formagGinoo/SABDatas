local Form_ActivityDayTask14 = class("Form_ActivityDayTask14", require("UI/UIFrames/Form_ActivityDayTask14UI"))
local DefaultShowSpineName = "merchant"
local maxDailyReward = 7
local iUpActivityID = 0
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
local doingTxt = ConfigManager:GetCommonTextById(250001)
local ScrollViewAnimStr = "m_scrollView_in"

function Form_ActivityDayTask14:SetInitParam(param)
end

function Form_ActivityDayTask14:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.Back))
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  local initGridData = {
    itemClkBackFun = handler(self, self.OnTabItemClk)
  }
  self.m_TabInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_tab_list_InfinityGrid, "ActTask/ActTaskTabItem", initGridData)
  self.maxScore = 0
end

function Form_ActivityDayTask14:BindItemAndData()
  local mFinalRewardConfig = self.m_stActivity:GetFinalRewardConfig()
  local keys = {}
  for key in pairs(mFinalRewardConfig) do
    table.insert(keys, key)
    if key > self.maxScore then
      self.maxScore = key
    end
  end
  table.sort(keys)
  self.pointItemData = {}
  for i = 1, #keys do
    local minScoreNum = keys[i - 1] or 0
    local progressObj = self["m_progress" .. i]
    local progressTrans = progressObj.transform
    local tempTab = {
      reward = mFinalRewardConfig[keys[i]],
      itemNumTxt = self["m_txt_integral" .. i].gameObject:GetComponent(T_TextMeshProUGUI),
      itemState = RewardStatus.CannotTake,
      itemMask = self["m_img_box_got" .. i].gameObject,
      itemBtn = self["m_btn_box" .. i].gameObject:GetComponent(T_Button),
      minScoreNum = minScoreNum,
      score = keys[i],
      isReGet = false,
      isReGet2 = false,
      popPosTran = self["m_rewardPop_Pos" .. i].gameObject.transform,
      progress = self["m_progress" .. i].gameObject,
      progressPoint = progressTrans:Find("img_point"),
      progressBarImg = self["m_bar_box" .. i .. "_Image"]
    }
    table.insert(self.pointItemData, tempTab)
  end
end

function Form_ActivityDayTask14:OnActive()
  self.super.OnActive(self)
  self:LoadShowSpine()
  UILuaHelper.SetActive(self.m_reward_pop, false)
  UILuaHelper.SetActive(self.m_btnClosePop, false)
  self:RefreshUI()
  self.m_iHandlerIDUpdateQuest = self:addEventListener("eGameEvent_Activity_CommonQuest_UpdateQuest", handler(self, self.OnEventUpdateQuest))
  self.m_iHandlerIDTakeQuestReward = self:addEventListener("eGameEvent_Activity_CommonQuest_TakeQuestReward", handler(self, self.OnEventTakeQuestReward))
  self.m_iHandlerIDTakeDailyReward = self:addEventListener("eGameEvent_Activity_CommonQuest_TakeDailyReward", handler(self, self.OnEventTakeDailyReward))
  self.m_iHandlerIDTakeFinalReward = self:addEventListener("eGameEvent_Activity_CommonQuest_TakeFinalReward", handler(self, self.OnEventTakeFinalReward))
  self.m_iHandlerIDReload = self:addEventListener("eGameEvent_Activity_AnywayReload", handler(self, self.OnEventActivityReload))
end

function Form_ActivityDayTask14:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleSpine(true)
  self:RemoveEventListeners()
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function Form_ActivityDayTask14:RemoveEventListeners()
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

function Form_ActivityDayTask14:OnEventUpdateQuest(tParam)
  if tParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  local vQuestStatusChanged = tParam.vQuestStatusChanged
  local vQuestInfo = self.m_stActivity:GetQuestInfo(self.iSelectedDay)
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

function Form_ActivityDayTask14:OnEventTakeQuestReward(sc)
  if sc.iQuestType ~= self.m_stActivity:getID() then
    return
  end
  utils.popUpRewardUI(sc.vReward)
  self:RefreshDailyReward()
  self:RefreshFinalReward()
end

function Form_ActivityDayTask14:OnEventTakeDailyReward(sc)
  if sc.iActivityId ~= self.m_stActivity:getID() then
    return
  end
  utils.popUpRewardUI(sc.vReward)
  self:RefreshDailyTaskTab(false)
  if sc.iDay == self.iSelectedDay then
    self:RefreshDailyReward()
  end
end

function Form_ActivityDayTask14:OnEventTakeFinalReward(sc)
  if sc.iActivityId ~= self.m_stActivity:getID() then
    return
  end
  utils.popUpRewardUI(sc.vReward)
  self:RefreshFinalReward()
end

function Form_ActivityDayTask14:OnEventActivityReload()
  self:RefreshUI()
end

function Form_ActivityDayTask14:RefreshUI()
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_CommonQuest)
  for _, act in pairs(act_list) do
    if act:GetUIType() == GlobalConfig.CommonQuestActType.DayTask_14 and act:GetUpActivityID() == iUpActivityID then
      self.m_stActivity = act
      break
    end
  end
  if self.m_stActivity == nil then
    self:CloseForm()
    return
  end
  self:BindItemAndData()
  self:RefreshDailyTaskTab(true)
  self:RefreshDailyReward()
  self:RefreshFinalReward()
  self:RefreshRemainTime()
  self:refreshTaskLoopScroll()
end

function Form_ActivityDayTask14:RefreshDailyTaskTab(bInit)
  local act = self.m_stActivity
  local iActiveDay = act:GetActiveDay()
  local iMaxDay = act:GetActMaxDay()
  self.iSelectedDay = self.iSelectedDay or nil
  local t = {}
  for i = 1, iMaxDay do
    local bShowRed = act:CheckShowRedByDay(i)
    if bShowRed and self.iSelectedDay == nil and bInit then
      self.iSelectedDay = i
    end
    t[i] = {
      bUnlock = i <= iActiveDay,
      bIsSelect = self.iSelectedDay == i,
      bState = self:GetDayQuestState(i),
      bShowRed = bShowRed
    }
  end
  self.iSelectedDay = self.iSelectedDay or iActiveDay
  t[self.iSelectedDay].bIsSelect = true
  self.m_TabData = t
  self.m_TabInfinityGrid:ShowItemList(self.m_TabData)
  self.m_TabInfinityGrid:LocateTo(self.iSelectedDay - 1)
end

function Form_ActivityDayTask14:GetDayQuestState(iDay)
  local bState
  local data = self.m_stActivity:GetQuestInfo(iDay)
  for m, n in ipairs(data) do
    if n.stQuestStatus.iState ~= MTTDProto.QuestState_Over then
      bState = MTTDProto.QuestState_Doing
    end
  end
  bState = bState or MTTDProto.QuestState_Over
  return bState
end

function Form_ActivityDayTask14:RefreshDailyReward()
  local iScoreCur = self.m_stActivity:GetScore(self.iSelectedDay)
  local stDailyRewardConfig = self.m_stActivity:GetDailyRewardConfig(self.iSelectedDay)
  self.m_txt_dailyreward_progress_max_Text.text = string.format(ConfigManager:GetCommonTextById(100035), iScoreCur, stDailyRewardConfig.iNeedScore)
  for i = 1, maxDailyReward do
    if self["m_bar_dailyreward_point" .. i] then
      self["m_bar_dailyreward_point" .. i]:SetActive(i <= iScoreCur + 1 and 0 < iScoreCur)
    end
    if self["m_bar_dailyreward" .. i] then
      self["m_bar_dailyreward" .. i]:SetActive(i <= iScoreCur + 1 and 0 < iScoreCur)
    end
  end
  self.item_list = self.item_list or {}
  self.m_pnl_item_dailyreward1:SetActive(false)
  self.m_pnl_item_dailyreward2:SetActive(false)
  for i, stDailyReward in ipairs(stDailyRewardConfig.vReward) do
    local obj = self["m_pnl_item_dailyreward" .. i]
    obj:SetActive(true)
    local item = self.item_list[i]
    if item == nil then
      item = self:createCommonItem(obj)
    end
    local processData = ResourceUtil:GetProcessRewardData(stDailyReward)
    item:SetItemInfo(processData)
    if iScoreCur < stDailyRewardConfig.iNeedScore then
      obj.transform:Find("c_img_mask").gameObject:SetActive(false)
      obj.transform:Find("c_item_receive").gameObject:SetActive(false)
      obj.transform:Find("m_item_dailyreward_fx_Loop").gameObject:SetActive(false)
      item:SetItemIconClickCB(handler(self, self.OnItemIconClicked))
    elseif not self.m_stActivity:IsDailyRewardTaken(self.iSelectedDay) then
      obj.transform:Find("c_img_mask").gameObject:SetActive(false)
      obj.transform:Find("c_item_receive").gameObject:SetActive(false)
      obj.transform:Find("m_item_dailyreward_fx_Loop").gameObject:SetActive(true)
      item:SetItemIconClickCB(handler(self, self.OnClaimDailyRewardClicked))
    else
      obj.transform:Find("c_img_mask").gameObject:SetActive(true)
      obj.transform:Find("c_item_receive").gameObject:SetActive(true)
      obj.transform:Find("m_item_dailyreward_fx_Loop").gameObject:SetActive(false)
      item:SetItemIconClickCB(handler(self, self.OnItemIconClicked))
    end
  end
end

function Form_ActivityDayTask14:OnItemIconClicked(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function Form_ActivityDayTask14:OnClaimDailyRewardClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self.m_stActivity:RequestTakeDailyReward(self.iSelectedDay)
end

function Form_ActivityDayTask14:RefreshFinalReward()
  local iScoreCur = self.m_stActivity:GetScore()
  local vFinalRewardTakenInfo = self.m_stActivity:GetFinalRewardTakenInfo()
  local isCan = true
  for _, pointScoreData in pairs(self.pointItemData) do
    local isNextGet = false
    local isNextGet2 = false
    local rewardState = RewardStatus.CannotTake
    local isGet = false
    for _, iScoreTaken in ipairs(vFinalRewardTakenInfo) do
      if pointScoreData.score == iScoreTaken then
        rewardState = RewardStatus.Taken
        isNextGet = false
        isGet = true
        break
      end
    end
    if not isGet then
      if iScoreCur < pointScoreData.score then
        rewardState = RewardStatus.CannotTake
        if isCan then
          isNextGet = false
          isNextGet2 = true
          isCan = false
        end
      else
        rewardState = RewardStatus.CanTake
        if isCan then
          isNextGet = true
          isNextGet2 = false
          isCan = false
        end
      end
    end
    pointScoreData.itemState = rewardState
    pointScoreData.isReGet = isNextGet
    pointScoreData.isReGet2 = isNextGet2
  end
  self:RefreshPointReward()
end

function Form_ActivityDayTask14:RefreshPointReward()
  local iScoreCur = self.m_stActivity:GetScore()
  for key, item in pairs(self.pointItemData) do
    item.itemNumTxt.text = tostring(item.score)
    if item.itemBtn.gameObject.transform:Find("m_pnl_fx_box") then
      UILuaHelper.SetActive(item.itemBtn.gameObject.transform:Find("m_pnl_fx_box"), false)
    end
    if item.isReGet then
      if item.itemBtn.gameObject.transform:Find("m_pnl_fx_box") then
        UILuaHelper.SetActive(item.itemBtn.gameObject.transform:Find("m_pnl_fx_box"), true)
      end
      UILuaHelper.BindButtonClickManual(self, item.itemBtn, function()
        self:OnPointItemClick(item)
      end)
    elseif item.itemStates ~= RewardStatus.Taken then
      UILuaHelper.BindButtonClickManual(self, item.itemBtn, function()
        self:RefreshScoreRewardPop(item)
      end)
    end
    if item.reward[1] and item.reward[1].iID then
      self.heroId = item.reward[1].iID
    end
    UILuaHelper.SetActive(item.itemMask, item.itemState == RewardStatus.Taken)
    UILuaHelper.SetActive(item.progressPoint, item.itemState ~= RewardStatus.CannotTake)
    item.progressBarImg.fillAmount = (iScoreCur - item.minScoreNum) / (item.score - item.minScoreNum)
    UILuaHelper.SetActive(item.progress, true)
  end
  local iScoreCur = self.m_stActivity:GetScore()
  self.m_txt_finalreward_max_Text.text = tostring(iScoreCur)
end

function Form_ActivityDayTask14:OnPointItemClick(item)
  self.m_stActivity:RequestTakeFinalReward(item.score)
end

function Form_ActivityDayTask14:RefreshScoreRewardPop(item)
  UILuaHelper.SetActive(self.m_reward_pop, true)
  UILuaHelper.SetActive(self.m_btnClosePop, true)
  UILuaHelper.SetParent(self.m_reward_pop, item.popPosTran, true)
  UILuaHelper.SetActive(self.m_common_item1, false)
  UILuaHelper.SetActive(self.m_common_item2, false)
  for i, v in ipairs(item.reward) do
    UILuaHelper.SetActive(self["m_common_item" .. i], true)
    local common_item = self:createCommonItem(self["m_common_item" .. i].gameObject)
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = v.iID,
      iNum = v.iNum
    })
    common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      utils.openItemDetailPop({iID = itemID, iNum = itemNum})
    end)
    common_item:SetItemInfo(processItemData)
  end
end

function Form_ActivityDayTask14:GetPointReward()
  self.m_stActivity:RequestTakeFinalReward(self.m_iFinalRewardScoreNext)
end

function Form_ActivityDayTask14:RefreshRemainTime()
  local endTime = self.m_stActivity:getActivityEndTime()
  if endTime == 0 then
    self.m_txtRemainTime:SetActive(false)
    return
  end
  self.m_txtRemainTime:SetActive(true)
  local left_time = self.m_stActivity:getActivityRemainTime()
  self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(left_time)
  if self.timer then
    TimeService:KillTimer(self.timer)
  end
  self.timer = TimeService:SetTimer(1, -1, function()
    left_time = left_time - 1
    if left_time <= 0 then
      TimeService:KillTimer(self.timer)
      self:CloseForm()
    end
    self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(left_time)
  end)
end

function Form_ActivityDayTask14:refreshTaskLoopScroll(is_tab_change)
  if is_tab_change then
    UILuaHelper.PlayAnimationByName(self.m_scrollView, ScrollViewAnimStr)
  end
  local data = self.m_stActivity:GetQuestInfo(self.iSelectedDay)
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
  local is_have_reward = false
  for i, v in ipairs(data) do
    if v.stQuestStatus.iState == MTTDProto.QuestState_Finish then
      is_have_reward = true
    end
  end
  self.m_bg_getall_normal:SetActive(is_have_reward)
  self.m_bg_getall_grey:SetActive(not is_have_reward)
  self.is_have_reward = is_have_reward
end

function Form_ActivityDayTask14:updateScrollViewCell(index, cell_object, cell_data)
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
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_star_progress_num", stepNum .. "/" .. stQuestConfig.iObjectiveCount or "0")
  if not stQuestConfig.iObjectiveCount or tostring(stQuestConfig.iObjectiveCount) == "0" or stQuestStatus.iState ~= MTTDProto.QuestState_Doing then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_bk", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_txt_star_progress_num", false)
  else
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_bk", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_txt_star_progress_num", true)
  end
  if stQuestConfig.iJump ~= 0 then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_doing", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_btn_go", stQuestStatus.iState == MTTDProto.QuestState_Doing)
  else
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_doing", true)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_doing", doingTxt)
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

function Form_ActivityDayTask14:OnBtngetallClicked()
  if self.is_have_reward then
    self.m_stActivity:RqsTakeOneDayAllReward(self.iSelectedDay)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(40041))
  end
end

function Form_ActivityDayTask14:OnBtnsearchClicked()
  if self.heroId then
    StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {
      heroID = self.heroId
    })
  end
end

function Form_ActivityDayTask14:OnBtnfinalrewardreceiveClicked()
  self.m_stActivity:RequestTakeFinalReward(self.m_iFinalRewardScoreNext)
end

function Form_ActivityDayTask14:OnTabItemClk(idx)
  if idx == self.iSelectedDay then
    return
  end
  if idx > self.m_stActivity:GetActiveDay() then
    local sToast = ConfigManager:GetCommonTextById(20010)
    local iCommonQuestRefreshTime = self.m_stActivity:GetCommonQuestRefreshTime()
    local iServerTime = TimeUtil:GetServerTimeS()
    sToast = string.gsub(sToast, "{time}", TimeUtil:SecondsToFormatStrDHOrHMS(iCommonQuestRefreshTime - iServerTime))
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, sToast)
    return
  end
  self.m_TabData[self.iSelectedDay].bIsSelect = false
  self.m_TabData[idx].bIsSelect = true
  self.m_TabInfinityGrid:ReBind(self.iSelectedDay)
  self.m_TabInfinityGrid:ReBind(idx)
  self.iSelectedDay = idx
  self:RefreshDailyReward()
  self:refreshTaskLoopScroll(true)
end

function Form_ActivityDayTask14:Back()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
  self.iSelectedDay = nil
end

function Form_ActivityDayTask14:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function Form_ActivityDayTask14:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleObjectByName(DefaultShowSpineName, self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_ActivityDayTask14:LoadShowSpine()
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

function Form_ActivityDayTask14:OnBtnClosePopClicked()
  UILuaHelper.SetActive(self.m_reward_pop, false)
  UILuaHelper.SetActive(self.m_btnClosePop, false)
end

function Form_ActivityDayTask14:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  vResourceExtra[#vResourceExtra + 1] = {
    sName = DefaultShowSpineName,
    eType = DownloadManager.ResourceType.UI
  }
  return vPackage, vResourceExtra
end

function Form_ActivityDayTask14:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_ActivityDayTask14", Form_ActivityDayTask14)
return Form_ActivityDayTask14
