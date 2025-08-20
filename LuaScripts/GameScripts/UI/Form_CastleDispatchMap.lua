local Form_CastleDispatchMap = class("Form_CastleDispatchMap", require("UI/UIFrames/Form_CastleDispatchMapUI"))
local __DISPATCH_COUNT = 10
local __DispatchRefreshCost = utils.changeStringRewardToLuaTable(ConfigManager:GetGlobalSettingsByKey("DispatchRefreshCost"))

function Form_CastleDispatchMap:SetInitParam(param)
end

function Form_CastleDispatchMap:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1174)
  self.m_incident_obj_list = {}
  for i = 1, __DISPATCH_COUNT do
    self.m_incident_obj_list[i] = {}
    local pnl_normal = self["m_incident" .. i].transform:Find("btn_incident/pnl_normal").gameObject
    local btn_incident = self["m_incident" .. i].transform:Find("btn_incident").gameObject
    local btn_normal = pnl_normal.transform:GetComponent(T_Button)
    btn_normal.onClick:RemoveAllListeners()
    UILuaHelper.BindButtonClickManual(self, btn_normal, function()
      self:OpenDispatchView(i)
    end)
    local bg_nml_img = pnl_normal.transform:Find("bg_nml"):GetComponent(T_Image)
    local txt_name = pnl_normal.transform:Find("txt_name"):GetComponent(T_TextMeshProUGUI)
    local txt_incident_num = pnl_normal.transform:Find("txt_incident_num"):GetComponent(T_TextMeshProUGUI)
    local c_common_item = pnl_normal.transform:Find("c_common_item").gameObject
    local bg_sp = pnl_normal.transform:Find("bg_sp").gameObject
    self.m_incident_obj_list[i].pnl_normal = pnl_normal
    self.m_incident_obj_list[i].bg_nml_img = bg_nml_img
    self.m_incident_obj_list[i].txt_name_Text = txt_name
    self.m_incident_obj_list[i].txt_incident_num_Text = txt_incident_num
    self.m_incident_obj_list[i].c_common_item = c_common_item
    self.m_incident_obj_list[i].bg_sp = bg_sp
    self.m_incident_obj_list[i].btn_incident = btn_incident
    local pnl_receive = self["m_incident" .. i].transform:Find("btn_incident/pnl_receive").gameObject
    local pnl_can_receive = pnl_receive.transform:Find("pnl_sel").gameObject
    local pnl_item = pnl_receive.transform:Find("pnl_item").gameObject
    local bg_item2 = pnl_item.transform:Find("bg_item2").gameObject
    local pnl_btn_receive = pnl_item.transform:GetComponent(T_Button)
    pnl_btn_receive.onClick:RemoveAllListeners()
    UILuaHelper.BindButtonClickManual(self, pnl_btn_receive, function()
      self:GetDispatchReward(i)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(198)
    end)
    local icon_star_receive = pnl_item.transform:Find("icon_star_receive"):GetComponent(T_Image)
    local txt_incidentnum = pnl_item.transform:Find("txt_incidentnum"):GetComponent(T_TextMeshProUGUI)
    local pnl_waiting = pnl_receive.transform:Find("pnl_waiting").gameObject
    local txt_time_Text = pnl_waiting.transform:Find("txt_time"):GetComponent(T_TextMeshProUGUI)
    local txt_incident_reward_num = pnl_receive.transform:Find("pnl_item/item_completed/txt_incident_num"):GetComponent(T_TextMeshProUGUI)
    local item_completedBg = pnl_receive.transform:Find("pnl_item/item_completed/c_bg_completed").gameObject
    local item_waitingBg = pnl_receive.transform:Find("pnl_item/item_completed/c_bg_underway").gameObject
    self.m_incident_obj_list[i].pnl_receive = pnl_receive
    self.m_incident_obj_list[i].pnl_can_receive = pnl_can_receive
    self.m_incident_obj_list[i].icon_star_receive = icon_star_receive
    self.m_incident_obj_list[i].txt_incidentnum_Text = txt_incidentnum
    self.m_incident_obj_list[i].pnl_waiting = pnl_waiting
    self.m_incident_obj_list[i].txt_time_Text = txt_time_Text
    self.m_incident_obj_list[i].bg_item2 = bg_item2
    self.m_incident_obj_list[i].txt_incident_reward_num_Text = txt_incident_reward_num
    self.m_incident_obj_list[i].item_completedBg = item_completedBg
    self.m_incident_obj_list[i].item_waitingBg = item_waitingBg
    self["m_incident" .. i]:SetActive(false)
  end
  CastleDispatchManager:SetRedPointFlag()
  self.m_auto_toggle_Toggle.onValueChanged:AddListener(function()
    self:OnToggleValueChanged()
  end)
end

function Form_CastleDispatchMap:OnActive()
  self.super.OnActive(self)
  self.m_timer_list = {}
  self.m_dispatchDataMap = {}
  self.m_initDispatchDataMap = {}
  self:RefreshUI()
  self:AddEventListeners()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(197)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(196)
  if self.m_dispatchDataMap then
    local dispatchCount = table.getn(self.m_dispatchDataMap)
    LocalDataManager:SetIntSimple("CastleDispatchCount", dispatchCount)
  end
end

function Form_CastleDispatchMap:OnInactive()
  self.super.OnInactive(self)
  self.m_dispatchDataMap = {}
  self.m_initDispatchDataMap = {}
  self:RemoveAllEventListeners()
  self:ClearTimer()
end

function Form_CastleDispatchMap:OnToggleValueChanged()
  LocalDataManager:SetIntSimple("Auto_Dispatch", self.m_auto_toggle_Toggle.isOn == true and 1 or 0)
end

function Form_CastleDispatchMap:ClearTimer()
  for i = __DISPATCH_COUNT, 1, -1 do
    if self.m_timer_list[i] and self.m_timer_list[i].timer then
      TimeService:KillTimer(self.m_timer_list[i].timer)
      self.m_timer_list[i].timer = nil
      self.m_timer_list[i].cutDownTime = nil
      self.m_timer_list[i] = {}
    end
  end
  self.m_timer_list = {}
end

function Form_CastleDispatchMap:AddEventListeners()
  self:addEventListener("eGameEvent_CastleDoDispatch", handler(self, self.DoDispatchCB))
  self:addEventListener("eGameEvent_TakeDispatchReward", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_RefreshDispatch", handler(self, self.RefreshDispatchData))
  self:addEventListener("eGameEvent_CancelDispatch", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_CastleDispatchRefresh", handler(self, self.OnDailyRefresh))
  self:addEventListener("eGameEvent_CastleDoQuickDispatch", handler(self, self.DoQuickDispatch))
end

function Form_CastleDispatchMap:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CastleDispatchMap:OnDailyRefresh()
  self:ClearTimer()
  self:RefreshUI()
end

function Form_CastleDispatchMap:RefreshUI(showAnimIndexTab)
  self.m_dispatchLevel = CastleDispatchManager:GetDispatchLevel()
  self.m_dispatchDataMap = CastleDispatchManager:GetDispatchData()
  self.m_initDispatchDataMap = table.deepcopy(self.m_dispatchDataMap)
  local isEmpty = true
  for i = 1, 10 do
    if self.m_dispatchDataMap[i] then
      self:RefreshOnePlaceUI(i, self.m_dispatchDataMap[i], showAnimIndexTab ~= nil and showAnimIndexTab[i] or false)
      self:RefreshTime(i, self.m_dispatchDataMap[i])
      if self.m_dispatchDataMap[i] and self.m_dispatchDataMap[i].iRewardTime == 0 then
        isEmpty = false
      end
    else
      self["m_incident" .. i]:SetActive(false)
    end
  end
  self.m_pnl_empty:SetActive(isEmpty)
  self:RefreshBtnState()
  local maxGrade, minGrade = CastleDispatchManager:GetDispatchMaxMinStar()
  local str = string.gsubNumberReplace(ConfigManager:GetClientMessageTextById(45011), minGrade, maxGrade)
  if maxGrade == minGrade then
    str = maxGrade
  end
  self.m_txt_star_num_Text.text = str
  self.m_auto_toggle_Toggle.isOn = LocalDataManager:GetIntSimple("Auto_Dispatch", 0) == 1
end

function Form_CastleDispatchMap:RefreshBtnState()
  local quickReceive = CastleDispatchManager:CheckQuickReceiveDispatchIsUnlock()
  local fast = CastleDispatchManager:CheckFastDispatchIsUnlock()
  local tab = CastleDispatchManager:QuicklyDispatch()
  self.m_pnl_quicksel:SetActive(0 < #tab and fast)
  self.m_pnl_quickgrey:SetActive(#tab == 0 and fast)
  self.m_pnl_quicklock:SetActive(not fast)
  local list = CastleDispatchManager:GetCanGetRewardDispatchList()
  self.m_pnl_getallsel:SetActive(0 < #list and quickReceive)
  self.m_pnl_getallgrey:SetActive(#list == 0 and quickReceive)
  self.m_pnl_getalllock:SetActive(not quickReceive)
  self.m_pnl_auto:SetActive(fast)
end

function Form_CastleDispatchMap:RefreshTime(index, dispatchEvent)
  if not self.m_incident_obj_list[index] or not self.m_incident_obj_list[index].txt_time_Text then
    return
  end
  if self.m_timer_list[index] and self.m_timer_list[index].timer then
    TimeService:KillTimer(self.m_timer_list[index].timer)
    self.m_timer_list[index].timer = nil
    self.m_timer_list[index].cutDownTime = nil
    self.m_timer_list[index] = {}
  else
    self.m_timer_list[index] = {}
  end
  self.m_timer_list[index].cutDownTime = CastleDispatchManager:GetDispatchDurationTimeByData(dispatchEvent)
  self.m_incident_obj_list[index].txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_timer_list[index].cutDownTime)
  if self.m_timer_list[index].cutDownTime > 0 then
    self.m_timer_list[index].timer = TimeService:SetTimer(1, -1, function()
      self.m_timer_list[index].cutDownTime = self.m_timer_list[index].cutDownTime - 1
      if self.m_timer_list[index].cutDownTime <= 0 then
        self.m_incident_obj_list[index].txt_time_Text.text = ""
        TimeService:KillTimer(self.m_timer_list[index].timer)
        self.m_timer_list[index].timer = nil
        self.m_timer_list[index].cutDownTime = nil
        self:RefreshBtnState()
        self:RefreshOnePlaceUI(index, self.m_dispatchDataMap[index])
        return
      end
      self.m_incident_obj_list[index].txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_timer_list[index].cutDownTime)
    end)
  else
    self.m_incident_obj_list[index].txt_time_Text.text = ""
  end
end

function Form_CastleDispatchMap:RefreshOnePlaceUI(index, data, playAnim)
  local objTab = self.m_incident_obj_list[index]
  if objTab and data and data.iRewardTime == 0 then
    local eventCfg = CastleDispatchManager:GetCastleDispatchEventCfg(data.iGroupId, data.iEventId)
    if eventCfg then
      local rewardData = utils.changeCSArrayToLuaTable(eventCfg.m_Reward)[1]
      local processData = ResourceUtil:GetProcessRewardData({
        iID = rewardData[1],
        iNum = rewardData[2]
      })
      objTab.pnl_normal:SetActive(data.iStartTime == 0)
      objTab.pnl_receive:SetActive(data.iStartTime ~= 0)
      if data.iStartTime == 0 then
        local reward_item = self:createCommonItem(objTab.c_common_item)
        reward_item:SetItemInfo(processData)
        objTab.txt_incident_num_Text.text = eventCfg.m_Grade
      else
        local time = CastleDispatchManager:GetDispatchDurationTimeByData(data)
        UILuaHelper.SetActive(objTab.item_completedBg, time <= 0)
        UILuaHelper.SetActive(objTab.item_waitingBg, 0 < time)
        objTab.pnl_waiting:SetActive(0 < time)
        objTab.bg_item2:SetActive(0 < time)
        objTab.pnl_can_receive:SetActive(time <= 0)
        UILuaHelper.SetAtlasSprite(objTab.icon_star_receive, processData.icon_name, nil, nil, true)
        objTab.txt_incidentnum_Text.text = rewardData[2]
        if playAnim then
          UILuaHelper.PlayAnimationByName(objTab.btn_incident, "m_incident_switch")
        end
      end
      local lvCfg = CastleDispatchManager:GetCastleDispatchLevelCfg(self.m_dispatchLevel)
      if lvCfg then
        objTab.bg_sp:SetActive(eventCfg.m_Grade >= lvCfg.m_SpecialStar)
      end
      objTab.txt_incident_reward_num_Text.text = eventCfg.m_Grade
    end
    local locationCfg = CastleDispatchManager:GetCastleDispatchLocationCfg(index)
    if locationCfg then
      objTab.txt_name_Text.text = locationCfg.m_mDispatchLocation
    end
    self["m_incident" .. index]:SetActive(true)
  else
    self["m_incident" .. index]:SetActive(false)
  end
end

function Form_CastleDispatchMap:OpenDispatchView(index)
  local data = self.m_dispatchDataMap[index]
  if data then
    StackFlow:Push(UIDefines.ID_FORM_CASTLEDISPATCHSELECT, {id = index, event = data})
  end
end

function Form_CastleDispatchMap:GetDispatchReward(index)
  local data = self.m_dispatchDataMap[index]
  local time = CastleDispatchManager:GetDispatchDurationTimeByData(data)
  if data and time < 0 then
    CastleDispatchManager:ReqTakeDispatchReward({index})
  else
    StackPopup:Push(UIDefines.ID_FORM_CASTLEDISPATCHPOPUP, {id = index, event = data})
  end
end

function Form_CastleDispatchMap:RefreshDispatchData()
  self:RefreshUI()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 45001)
end

function Form_CastleDispatchMap:DoDispatchCB()
  local showAnimIndexTab = self:GetShowAnimList()
  self:RefreshUI(showAnimIndexTab)
end

function Form_CastleDispatchMap:DoQuickDispatch()
  local showAnimIndexTab = self:GetShowAnimList()
  self:RefreshUI(showAnimIndexTab)
  StackPopup:Push(UIDefines.ID_FORM_CASTLEDISPATCHSTART)
end

function Form_CastleDispatchMap:GetShowAnimList()
  local showAnimIndexList = {}
  local dispatchDataMap = CastleDispatchManager:GetDispatchData()
  for i, v in pairs(self.m_initDispatchDataMap) do
    local tempData = dispatchDataMap[i]
    if tempData and v.iEventId == tempData.iEventId and v.iGroupId == tempData.iGroupId and v.iStartTime == 0 and tempData.iStartTime ~= 0 then
      showAnimIndexList[i] = true
    end
  end
  return showAnimIndexList
end

function Form_CastleDispatchMap:OnBtnresetClicked()
  local notDispatchList = CastleDispatchManager:GetNotDispatchEvent()
  if table.getn(notDispatchList) == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 45013)
    return
  end
  local cost = __DispatchRefreshCost[1] or {}
  local processData = ResourceUtil:GetProcessRewardData({
    tonumber(cost[1]),
    1
  })
  utils.ShowCommonTipCost({
    beforeItemID = tonumber(cost[1]),
    beforeItemNum = tonumber(cost[2]),
    formatFun = function(sContent)
      return string.format(sContent, tostring(processData.name), cost[2])
    end,
    confirmCommonTipsID = 1175,
    funSure = function()
      CastleDispatchManager:ReqRefreshDispatch()
    end
  })
end

function Form_CastleDispatchMap:OnBtnquickClicked()
  local fast = CastleDispatchManager:CheckFastDispatchIsUnlock()
  if fast then
    local tab = CastleDispatchManager:QuicklyDispatch()
    if 0 < #tab then
      if self.m_auto_toggle_Toggle.isOn then
        local mLocationHero = {}
        for i, v in pairs(tab) do
          mLocationHero[v.index] = v.heroTab
        end
        CastleDispatchManager:ReqCastleDoQuickDispatch(mLocationHero)
      else
        StackPopup:Push(UIDefines.ID_FORM_CASTLEDISPATCHSELECTQUICK)
      end
      CS.GlobalManager.Instance:TriggerWwiseBGMState(61)
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 45005)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(3)
    end
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 45003)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(3)
  end
end

function Form_CastleDispatchMap:OnBtnpopupClicked()
  StackPopup:Push(UIDefines.ID_FORM_CASTLEDISPATCHPOPUPRULE)
end

function Form_CastleDispatchMap:OnBtngetallClicked()
  local quickReceive = CastleDispatchManager:CheckQuickReceiveDispatchIsUnlock()
  if quickReceive then
    local list = CastleDispatchManager:GetCanGetRewardDispatchList()
    if 0 < #list then
      CastleDispatchManager:ReqTakeDispatchReward(list)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(200)
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 45012)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(3)
    end
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 45004)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(3)
  end
end

function Form_CastleDispatchMap:OnBackClk()
  self:CloseForm()
end

function Form_CastleDispatchMap:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_CastleDispatchMap:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleDispatchMap:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CastleDispatchMap", Form_CastleDispatchMap)
return Form_CastleDispatchMap
