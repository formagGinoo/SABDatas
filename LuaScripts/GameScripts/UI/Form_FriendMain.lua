local Form_FriendMain = class("Form_FriendMain", require("UI/UIFrames/Form_FriendMainUI"))
local MaxTab = 4
local MaxFriendCount, MaxPointsCount, perTimesCount, FriendRecommendCD, FriendBlackList
local SortType = {
  Recently = 1,
  Power = 2,
  Level = 3
}

function Form_FriendMain:SetInitParam(param)
end

function Form_FriendMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1170)
  self.m_DoubleTrigger = self.m_btnTipsClose:GetComponent("ButtonTriggerDouble")
  if self.m_DoubleTrigger then
    self.m_DoubleTrigger.Clicked = handler(self, self.OnDoubleTriggerClk)
  end
  self.mTabCompentList = {}
  for i = 1, MaxTab do
    self.mTabCompentList[i] = {
      select = self["m_tab_select" .. i],
      unselect = self["m_tab_base_unselect" .. i]
    }
  end
  self:RegisterRedDot()
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClick)
  }
  self.m_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_list_InfinityGrid, "Friend/UIFriendItem", initGridData)
  self.m_inputfield_TMP_InputField.onValueChanged:AddListener(handler(self, self.OnInputChanged))
  local goFilterBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/pnl_center/ui_common_filter").gameObject
  self.m_widgetBtnFilter = self:createFilterButton(goFilterBtnRoot)
  self.m_iFilterTabIndex = 1
  self.m_bFilterDown = false
  self.m_widgetBtnFilter:RefreshTabConfig({
    {iIndex = 1, sTitle = 20059},
    {iIndex = 2, sTitle = 20056},
    {iIndex = 3, sTitle = 20057}
  }, self.m_iFilterTabIndex, self.m_bFilterDown, handler(self, self.OnFilterChanged))
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  MaxFriendCount = tonumber(GlobalManagerIns:GetValue_ByName("FriendMaxNumber").m_Value)
  FriendRecommendCD = tonumber(GlobalManagerIns:GetValue_ByName("FriendRecommendCD").m_Value)
  local maxTimes = tonumber(GlobalManagerIns:GetValue_ByName("FriendPointsAcceptMax").m_Value)
  perTimesCount = tonumber(GlobalManagerIns:GetValue_ByName("FriendPointsNumber").m_Value)
  FriendBlackList = tonumber(GlobalManagerIns:GetValue_ByName("FriendBlackList").m_Value)
  MaxPointsCount = maxTimes * perTimesCount
end

function Form_FriendMain:OnActive()
  self.super.OnActive(self)
  self.curTabIndex = 1
  self:OnDoubleTriggerClk()
  self:AddEventListeners()
  self:FreshUI()
end

function Form_FriendMain:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function Form_FriendMain:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
  self.m_UILockID = nil
end

function Form_FriendMain:AddEventListeners()
  self:addEventListener("eGameEvent_UpdateFriendState", handler(self, self.FreshUI))
  self:addEventListener("eGameEvent_UpdateFriendUIState", handler(self, self.FreshUIState))
end

function Form_FriendMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_FriendMain:RegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_img_RedDot_Base1, RedDotDefine.ModuleType.FriendHaveHeart)
  self:RegisterOrUpdateRedDotItem(self.m_img_RedDot_Base3, RedDotDefine.ModuleType.FriendHaveRqsAdd)
end

local CMD = {}
CMD[1] = function(self)
  FriendManager:SetCurFriendTab(1)
  local friendList = self.mFriendData.vFriend
  local count = #friendList
  if 0 < count then
    self.m_list:SetActive(true)
    self.m_empty:SetActive(false)
    self:SortItemList(friendList)
    self.m_InfinityGrid:ShowItemList(friendList, true)
    self.m_InfinityGrid:LocateTo(0)
    self:PlayItemAniIn()
  else
    self.m_list:SetActive(false)
    self.m_empty:SetActive(true)
  end
  self:FreshUIState()
end
CMD[2] = function(self)
  FriendManager:SetCurFriendTab(2)
  self.m_inputfield:SetActive(true)
  self.m_btn_refresh:SetActive(true)
  self.m_btn_refresh_time:SetActive(false)
  self.m_z_txt_unable:SetActive(false)
  self.m_common_btn_reject:SetActive(false)
  self.m_common_btn_reject_gray:SetActive(false)
  self.m_pnl_box:SetActive(false)
  self.m_txt_empty_Text.text = ConfigManager:GetCommonTextById(20310)
  if self.isShowSearch then
    self.m_txt_tips_Text.text = ConfigManager:GetCommonTextById(20305)
    self.curSearchList = FriendManager:GetSearchList() or {}
    if #self.curSearchList > 0 then
      self.m_empty:SetActive(false)
      self.m_list:SetActive(true)
      self:SortItemList(self.curSearchList)
      self.m_InfinityGrid:ShowItemList(self.curSearchList, true)
      self.m_InfinityGrid:LocateTo(0)
      self:PlayItemAniIn()
    else
      self.m_empty:SetActive(true)
      self.m_list:SetActive(false)
    end
    self:FreshUIState()
    return
  end
  self.m_btn_closesearch:SetActive(false)
  self.m_txt_claim_Text.text = ConfigManager:GetCommonTextById(20300)
  self.m_txt_grey_Text.text = ConfigManager:GetCommonTextById(20300)
  self.m_txt_tips_Text.text = ConfigManager:GetCommonTextById(20304)
  if not FriendManager:GetRecommendFriend() then
    self.m_common_btn_claim:SetActive(false)
    self.m_common_btn_claimgray:SetActive(true)
    FriendManager:RqsGetRecommend(function(vRecommendFriend)
      if self.curTabIndex == 2 then
        self.vRecommendFriend = vRecommendFriend
        if 0 < #vRecommendFriend then
          self.m_empty:SetActive(false)
          self.m_list:SetActive(true)
          self:SortItemList(vRecommendFriend)
          self.m_InfinityGrid:ShowItemList(vRecommendFriend, true)
          self.m_InfinityGrid:LocateTo(0)
          self:PlayItemAniIn()
          self.m_common_btn_claim:SetActive(true)
          self.m_common_btn_claimgray:SetActive(false)
        else
          self.m_empty:SetActive(true)
          self.m_list:SetActive(false)
          self.m_common_btn_claim:SetActive(false)
          self.m_common_btn_claimgray:SetActive(true)
        end
      end
    end)
  else
    self.vRecommendFriend = FriendManager:GetRecommendFriend()
    if #self.vRecommendFriend > 0 then
      self.m_empty:SetActive(false)
      self.m_list:SetActive(true)
      self:SortItemList(self.vRecommendFriend)
      self.m_InfinityGrid:ShowItemList(self.vRecommendFriend, true)
      self.m_InfinityGrid:LocateTo(0)
      self:PlayItemAniIn()
      self.m_common_btn_claim:SetActive(true)
      self.m_common_btn_claimgray:SetActive(false)
    else
      self.m_empty:SetActive(true)
      self.m_list:SetActive(false)
      self.m_common_btn_claim:SetActive(false)
      self.m_common_btn_claimgray:SetActive(true)
    end
    self:FreshUIState()
  end
end
CMD[3] = function(self)
  FriendManager:SetCurFriendTab(3)
  local list = self.mFriendData.vFriendRequest
  local count = #list
  if 0 < count then
    self.m_list:SetActive(true)
    self.m_empty:SetActive(false)
    self:SortItemList(list)
    self.m_InfinityGrid:ShowItemList(list, true)
    self.m_InfinityGrid:LocateTo(0)
    self:PlayItemAniIn()
  else
    self.m_list:SetActive(false)
    self.m_empty:SetActive(true)
  end
  self:FreshUIState()
end
CMD[4] = function(self)
  FriendManager:SetCurFriendTab(4)
  local list = FriendManager:GetShieldRole()
  local count = #list
  self.m_txt_num_Text.text = count .. "/" .. FriendBlackList
  if 0 < count then
    self.m_list:SetActive(true)
    self.m_empty:SetActive(false)
    self:SortItemList(list)
    self.m_InfinityGrid:ShowItemList(list, true)
    self.m_InfinityGrid:LocateTo(0)
    self:PlayItemAniIn()
  else
    self.m_list:SetActive(false)
    self.m_empty:SetActive(true)
  end
  self:FreshUIState()
end

function Form_FriendMain:FreshUI()
  self.mFriendData = FriendManager:GetFriendInfo()
  self:FreshTabState()
  local f = CMD[self.curTabIndex]
  if f then
    f(self)
  end
end

function Form_FriendMain:FreshTabState()
  for i, v in ipairs(self.mTabCompentList) do
    v.select:SetActive(i == self.curTabIndex)
    v.unselect:SetActive(i ~= self.curTabIndex)
  end
end

function Form_FriendMain:OnInputChanged(val)
  val = string.trim(val)
  self.searchText = tonumber(val)
  self.m_btn_closesearch:SetActive(false)
end

function Form_FriendMain:FreshUIState()
  if self.curTabIndex == 1 then
    self.m_inputfield:SetActive(false)
    self.m_btn_refresh:SetActive(false)
    self.m_btn_refresh_time:SetActive(false)
    self.m_z_txt_unable:SetActive(false)
    self.m_common_btn_reject:SetActive(false)
    self.m_common_btn_reject_gray:SetActive(false)
    self.m_txt_empty_Text.text = ConfigManager:GetCommonTextById(20309)
    self.m_txt_claim_Text.text = ConfigManager:GetCommonTextById(20302)
    self.m_txt_grey_Text.text = ConfigManager:GetCommonTextById(20302)
    self.m_txt_tips_Text.text = ConfigManager:GetCommonTextById(20306)
    self.m_pnl_box:SetActive(true)
    self.m_txt_numtotal_Text.text = self.mFriendData.iDailyTakeHeartNum * perTimesCount .. "/" .. MaxPointsCount
    local friendList = self.mFriendData.vFriend
    local count = #friendList
    self.m_txt_num_Text.text = count .. "/" .. MaxFriendCount
    if FriendManager:CanGetAndSendAll() then
      self.m_common_btn_claim:SetActive(true)
      self.m_common_btn_claimgray:SetActive(false)
    else
      self.m_common_btn_claim:SetActive(false)
      self.m_common_btn_claimgray:SetActive(true)
    end
  elseif self.curTabIndex == 2 then
    if FriendManager:CanRqsAddAllFriend() then
      self.m_common_btn_claim:SetActive(true)
      self.m_common_btn_claimgray:SetActive(false)
    else
      self.m_common_btn_claim:SetActive(false)
      self.m_common_btn_claimgray:SetActive(true)
    end
    local time = self.iLastRqsTime or 0
    local cur_time = TimeUtil:GetServerTimeS()
    if cur_time - time > FriendRecommendCD then
      self.m_btn_refresh_time:SetActive(false)
    else
      self.m_btn_refresh_time:SetActive(true)
      local left_time = FriendRecommendCD - (cur_time - time)
      self.m_txt_time_Text.text = left_time
      if self.timer then
        TimeService:KillTimer(self.timer)
        self.timer = nil
      end
      self.timer = TimeService:SetTimer(1, -1, function()
        left_time = left_time - 1
        if left_time <= 0 then
          TimeService:KillTimer(self.timer)
          self.m_btn_refresh_time:SetActive(false)
        end
        self.m_txt_time_Text.text = left_time
      end)
    end
  elseif self.curTabIndex == 3 then
    self.m_inputfield:SetActive(false)
    self.m_btn_refresh:SetActive(false)
    self.m_btn_refresh_time:SetActive(false)
    self.m_z_txt_unable:SetActive(false)
    self.m_pnl_box:SetActive(false)
    self.m_txt_claim_Text.text = ConfigManager:GetCommonTextById(20301)
    self.m_txt_grey_Text.text = ConfigManager:GetCommonTextById(20301)
    self.m_txt_tips_Text.text = ConfigManager:GetCommonTextById(20308)
    self.m_txt_empty_Text.text = ConfigManager:GetCommonTextById(20311)
    self.m_txt_num_Text.text = #self.mFriendData.vFriend .. "/" .. MaxFriendCount
    self.m_common_btn_reject:SetActive(true)
    local list = self.mFriendData.vFriendRequest
    local count = #list
    if 0 < count then
      self.m_common_btn_claim:SetActive(true)
      self.m_common_btn_claimgray:SetActive(false)
      self.m_common_btn_reject:SetActive(true)
      self.m_common_btn_reject_gray:SetActive(false)
    else
      self.m_common_btn_claim:SetActive(false)
      self.m_common_btn_claimgray:SetActive(true)
      self.m_common_btn_reject:SetActive(false)
      self.m_common_btn_reject_gray:SetActive(true)
    end
    if #self.mFriendData.vFriend >= MaxFriendCount then
      self.m_common_btn_claim:SetActive(false)
      self.m_common_btn_claimgray:SetActive(true)
    end
  elseif self.curTabIndex == 4 then
    self.m_inputfield:SetActive(false)
    self.m_btn_refresh:SetActive(false)
    self.m_btn_refresh_time:SetActive(false)
    self.m_z_txt_unable:SetActive(true)
    self.m_pnl_box:SetActive(false)
    self.m_common_btn_reject:SetActive(false)
    self.m_common_btn_reject_gray:SetActive(false)
    self.m_txt_empty_Text.text = ConfigManager:GetCommonTextById(20312)
    self.m_txt_tips_Text.text = ConfigManager:GetCommonTextById(20307)
    self.m_common_btn_claim:SetActive(false)
    self.m_common_btn_claimgray:SetActive(false)
  end
end

function Form_FriendMain:SortItemList(list)
  table.sort(list, function(a, b)
    if self.m_iFilterTabIndex == SortType.Recently then
      local aOLState = a.iLogoutTime == 0 and 1 or 2
      local bOLState = b.iLogoutTime == 0 and 1 or 2
      if self.m_bFilterDown then
        if aOLState ~= bOLState then
          return aOLState > bOLState
        end
        return a.iLogoutTime < b.iLogoutTime
      else
        if aOLState ~= bOLState then
          return aOLState < bOLState
        end
        return a.iLogoutTime > b.iLogoutTime
      end
    end
    if self.m_iFilterTabIndex == SortType.Power then
      if self.m_bFilterDown then
        return a.iPower < b.iPower
      else
        return a.iPower > b.iPower
      end
    end
    if self.m_iFilterTabIndex == SortType.Level then
      if self.m_bFilterDown then
        return a.iLevel < b.iLevel
      else
        return a.iLevel > b.iLevel
      end
    end
  end)
end

function Form_FriendMain:PlayItemAniIn()
  local list = self.m_InfinityGrid:GetAllShownItemList()
  for k, v in ipairs(list) do
    v:RefreshItemFx()
  end
end

function Form_FriendMain:OnItemClick(item)
  self.m_tips:SetActive(true)
  self.curItem = item
  local pos = self.m_tips.transform.parent:InverseTransformPoint(item.m_itemRootObj.transform.position)
  local _, content_h = UILuaHelper.GetUISize(self.m_tips)
  local _, height = UILuaHelper.GetUISize(self.m_rootTrans)
  local d_pos = Vector3.New(250, pos.y, pos.z)
  d_pos.y = d_pos.y
  d_pos.y = math.max(math.min(d_pos.y, height * 0.5 - content_h * 0.5), -height * 0.5)
  UILuaHelper.SetLocalPosition(self.m_tips, d_pos.x, d_pos.y, 0)
end

function Form_FriendMain:OnDoubleTriggerClk()
  self.m_tips:SetActive(false)
  self.curItem = nil
end

function Form_FriendMain:OnBtnitemdeletClicked()
  local item = self.curItem
  utils.popUpDirectionsUI({
    tipsID = 1173,
    bUseSystemWord = true,
    fContentCB = function(content)
      local str = item.m_itemData and item.m_itemData.sName or ""
      return string.gsubnumberreplace(content, str)
    end,
    func1 = function()
      self:OnDoubleTriggerClk()
      if item.m_itemData then
        FriendManager:RqsDeleteFriend(item.m_itemData.stRoleId, function()
          local aniLen = UILuaHelper.GetAnimationLengthByName(item.m_itemRootObj, "Friend_item_out")
          UILuaHelper.PlayAnimationByName(item.m_itemRootObj, "Friend_item_out")
          item.timer = TimeService:SetTimer(aniLen, 1, function()
            self:broadcastEvent("eGameEvent_UpdateFriendState")
          end)
        end)
      end
    end
  })
end

function Form_FriendMain:OnBtnitemblockClicked()
  local item = self.curItem
  utils.popUpDirectionsUI({
    tipsID = 1171,
    bUseSystemWord = true,
    fContentCB = function(content)
      local str = item.m_itemData and item.m_itemData.sName or ""
      return string.gsubnumberreplace(content, str)
    end,
    func1 = function()
      self:OnDoubleTriggerClk()
      if item.m_itemData then
        FriendManager:RqsBlockFriend(item.m_itemData.stRoleId, function()
          local aniLen = UILuaHelper.GetAnimationLengthByName(item.m_itemRootObj, "Friend_item_out")
          UILuaHelper.PlayAnimationByName(item.m_itemRootObj, "Friend_item_out")
          item.timer = TimeService:SetTimer(aniLen, 1, function()
            self:broadcastEvent("eGameEvent_UpdateFriendState")
          end)
        end)
      end
    end
  })
end

function Form_FriendMain:OnFilterChanged(iIndex, bDown)
  self.m_iFilterTabIndex = iIndex
  self.m_bFilterDown = bDown
  self.m_InfinityGrid:LocateTo(0)
  self:FreshUI()
end

function Form_FriendMain:OnBackClk()
  self:CloseForm()
end

function Form_FriendMain:OnTab1Clicked()
  if self.curTabIndex == 1 then
    return
  end
  self:OnDoubleTriggerClk()
  self.curTabIndex = 1
  self:FreshUI()
end

function Form_FriendMain:OnTab2Clicked()
  if self.curTabIndex == 2 then
    return
  end
  self:OnDoubleTriggerClk()
  self.curTabIndex = 2
  self:FreshUI()
end

function Form_FriendMain:OnTab3Clicked()
  if self.curTabIndex == 3 then
    return
  end
  self:OnDoubleTriggerClk()
  self.curTabIndex = 3
  self:FreshUI()
end

function Form_FriendMain:OnTab4Clicked()
  if self.curTabIndex == 4 then
    return
  end
  self:OnDoubleTriggerClk()
  self.curTabIndex = 4
  self:FreshUI()
end

function Form_FriendMain:OnCommonbtnclaimClicked()
  if self.curTabIndex == 1 then
    FriendManager:RqsGetAndSendAll(function()
      self:FreshUI()
    end)
  elseif self.curTabIndex == 2 then
    FriendManager:RqsAddFriendBatch(function()
      self:FreshUI()
    end)
  elseif self.curTabIndex == 3 then
    FriendManager:RqsConfirmAllFriendRequest(function()
      self:FreshUI()
    end)
  end
end

function Form_FriendMain:OnCommonbtnrejectgrayClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10324))
end

function Form_FriendMain:OnCommonbtnclaimgrayClicked()
  if self.curTabIndex == 1 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10306))
  elseif self.curTabIndex == 2 then
    local friendList = self.mFriendData.vFriend
    local count = #friendList
    if count >= MaxFriendCount then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10308))
    end
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10323))
  elseif self.curTabIndex == 3 then
    local friendList = self.mFriendData.vFriend
    local count = #friendList
    if count >= MaxFriendCount then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10308))
      return
    end
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10324))
  end
end

function Form_FriendMain:OnCommonbtnrejectClicked()
  FriendManager:RqsDelAllFriendRequest(function()
    self:FreshUI()
  end)
end

function Form_FriendMain:OnBtnfindClicked()
  if self.searchText then
    self.m_common_btn_claim:SetActive(false)
    self.m_common_btn_claimgray:SetActive(false)
    FriendManager:RqsSearchRole(self.searchText, function(vRole)
      self.curSearchList = vRole
      if self.curTabIndex == 2 then
        if 0 < #vRole then
          self.m_empty:SetActive(false)
          self.m_list:SetActive(true)
          self:SortItemList(vRole)
          self.m_InfinityGrid:ShowItemList(vRole, true)
          self:PlayItemAniIn()
        else
          self.m_empty:SetActive(true)
          self.m_list:SetActive(false)
        end
      end
    end)
    self.m_btn_closesearch:SetActive(true)
    self.isShowSearch = true
    self.m_txt_tips_Text.text = ConfigManager:GetCommonTextById(20305)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10313))
  end
end

function Form_FriendMain:OnBtnrefreshClicked()
  self.isShowSearch = false
  self.m_btn_closesearch:SetActive(false)
  self.m_txt_tips_Text.text = ConfigManager:GetCommonTextById(20304)
  self.m_inputfield_TMP_InputField.text = ""
  self.searchText = nil
  FriendManager:RqsGetRecommend(function(vRecommendFriend)
    self.vRecommendFriend = vRecommendFriend
    if 0 < #vRecommendFriend then
      self.m_empty:SetActive(false)
      self.m_list:SetActive(true)
      self:SortItemList(vRecommendFriend)
      self.m_InfinityGrid:ShowItemList(vRecommendFriend, true)
      self.m_InfinityGrid:LocateTo(0)
      self:PlayItemAniIn()
      self.m_common_btn_claim:SetActive(true)
      self.m_common_btn_claimgray:SetActive(false)
    else
      self.m_empty:SetActive(true)
      self.m_list:SetActive(false)
      self.m_common_btn_claim:SetActive(false)
      self.m_common_btn_claimgray:SetActive(true)
    end
  end)
  self.iLastRqsTime = TimeUtil:GetServerTimeS()
  self:FreshUIState()
end

function Form_FriendMain:OnBtnrefreshtimeClicked()
end

function Form_FriendMain:OnBtnclosesearchClicked()
  self.m_btn_closesearch:SetActive(false)
  self.m_txt_tips_Text.text = ConfigManager:GetCommonTextById(20304)
  self.m_inputfield_TMP_InputField.text = ""
  self.searchText = nil
  self.vRecommendFriend = FriendManager:GetRecommendFriend()
  if #self.vRecommendFriend > 0 then
    self.m_empty:SetActive(false)
    self.m_list:SetActive(true)
    self:SortItemList(self.vRecommendFriend)
    self.m_InfinityGrid:ShowItemList(self.vRecommendFriend, true)
    self:PlayItemAniIn()
    self.m_common_btn_claim:SetActive(true)
    self.m_common_btn_claimgray:SetActive(false)
  else
    self.m_empty:SetActive(true)
    self.m_list:SetActive(false)
    self.m_common_btn_claim:SetActive(false)
    self.m_common_btn_claimgray:SetActive(true)
  end
  self:FreshUIState()
  self.isShowSearch = false
end

function Form_FriendMain:OnBtnCloseClicked()
  self:OnBackClk()
end

local fullscreen = true
ActiveLuaUI("Form_FriendMain", Form_FriendMain)
return Form_FriendMain
