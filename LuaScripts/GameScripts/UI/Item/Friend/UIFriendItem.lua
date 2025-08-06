local UIItemBase = require("UI/Common/UIItemBase")
local UIFriendItem = class("UIFriendItem", UIItemBase)

function UIFriendItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_playerHeadCom = self:createPlayerHead(self.m_circle_head)
  self.m_playerHeadCom:SetPlayerHeadClickBackFun(function()
    self:OnPlayerHeadClk()
  end)
  self.m_btn_more:SetActive(true)
  self.m_btn_more_gray:SetActive(false)
end

function UIFriendItem:OnFreshData()
  if not self.m_itemRootObj then
    return
  end
  self.m_itemRootObj:SetActive(true)
  local data = self.m_itemData
  local is_added = FriendManager:IsFriendInAddedList(data.stRoleId)
  local curTabIdx = FriendManager:GetCurFriendTab()
  self.m_playerHeadCom:SetPlayerHeadInfo(data)
  self.m_txt_player_name_Text.text = data.sName
  self.m_txt_player_desc_Text.text = data.sAllianceName ~= "" and data.sAllianceName or ConfigManager:GetCommonTextById(20111) or ""
  self.m_txt_power_Text.text = data.iPower
  local is_online = data.iLogoutTime == 0
  self.m_online:SetActive(is_online)
  self.m_notonline:SetActive(not is_online)
  if not is_online then
    local ticks = TimeUtil:GetServerTimeS() - data.iLogoutTime
    self.m_notonline_Text.text = self:FormatTimeStr(ticks)
  else
    self.m_online_Text.text = ConfigManager:GetCommonTextById(100045)
  end
  if curTabIdx == 1 then
    self.m_pnl_accept:SetActive(false)
    self.m_pnl_reject:SetActive(false)
    self.m_btn_agree:SetActive(false)
    self.m_pnl_forbid:SetActive(false)
    self.m_pnl_add:SetActive(false)
    self.m_pnl_more:SetActive(true)
    local canGet = FriendManager:GetFriendHeartState(data.stRoleId)
    local is_Send = FriendManager:GetFriendSendHeartState(data.stRoleId)
    if not canGet then
      self.m_pnl_getheart:SetActive(false)
      self.m_pnl_sendheart:SetActive(true)
      self.m_btn_sendtheart:SetActive(not is_Send)
      self.m_btn_sendtheart_gray:SetActive(is_Send)
    else
      self.m_pnl_getheart:SetActive(true)
      self.m_pnl_sendheart:SetActive(false)
    end
  elseif curTabIdx == 2 then
    self.m_pnl_accept:SetActive(false)
    self.m_pnl_reject:SetActive(false)
    self.m_pnl_more:SetActive(false)
    self.m_pnl_getheart:SetActive(false)
    self.m_pnl_sendheart:SetActive(false)
    self.m_pnl_add:SetActive(true)
    self.m_pnl_forbid:SetActive(true)
    local is_friend = FriendManager:PlayerIsFriend(data.stRoleId)
    if is_friend then
      self.m_pnl_add:SetActive(false)
      self.m_btn_agree:SetActive(true)
    else
      self.m_pnl_add:SetActive(true)
      self.m_btn_agree:SetActive(false)
      if is_added then
        self.m_btn_add:SetActive(false)
        self.m_btn_add_gray:SetActive(true)
      else
        self.m_btn_add:SetActive(true)
        self.m_btn_add_gray:SetActive(false)
      end
    end
    local is_shield = FriendManager:PlayerIsShield(data.stRoleId)
    if is_shield then
      self.m_btn_forbid:SetActive(false)
      self.m_btn_forbid_gray:SetActive(true)
    else
      self.m_btn_forbid:SetActive(true)
      self.m_btn_forbid_gray:SetActive(false)
    end
  elseif curTabIdx == 3 then
    self.m_pnl_accept:SetActive(true)
    self.m_pnl_reject:SetActive(true)
    self.m_btn_agree:SetActive(false)
    self.m_pnl_forbid:SetActive(false)
    self.m_pnl_add:SetActive(false)
    self.m_pnl_more:SetActive(false)
    self.m_pnl_getheart:SetActive(false)
    self.m_pnl_sendheart:SetActive(false)
  elseif curTabIdx == 4 then
    self.m_pnl_accept:SetActive(false)
    self.m_pnl_reject:SetActive(true)
    self.m_btn_agree:SetActive(false)
    self.m_pnl_forbid:SetActive(false)
    self.m_pnl_add:SetActive(false)
    self.m_pnl_more:SetActive(false)
    self.m_pnl_getheart:SetActive(false)
    self.m_pnl_sendheart:SetActive(false)
  end
end

function UIFriendItem:RefreshItemFx(delay)
  UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "Friend_item_in")
end

function UIFriendItem:FormatTimeStr(ticks)
  local timeTb = TimeUtil:SecondsToFourUnit(ticks)
  if timeTb.day > 0 then
    return string.gsubNumberReplace(ConfigManager:GetCommonTextById(20315), timeTb.day)
  end
  if 0 < timeTb.hour then
    return string.gsubNumberReplace(ConfigManager:GetCommonTextById(20314), timeTb.hour)
  end
  local min = 0 < timeTb.min and timeTb.min or 1
  return string.gsubNumberReplace(ConfigManager:GetCommonTextById(20313), min)
end

function UIFriendItem:OnBtngetheartClicked()
  FriendManager:RqsGetHeart(self.m_itemData.stRoleId, function()
    self:OnFreshData()
  end)
end

function UIFriendItem:OnBtnsendtheartClicked()
  FriendManager:RqsSendHeart(self.m_itemData.stRoleId, function()
    self:OnFreshData()
  end)
end

function UIFriendItem:OnBtnsendtheartgrayClicked()
  if FriendManager:CanSendPoints() then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10318))
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10319))
  end
end

function UIFriendItem:OnBtnmoreClicked()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self)
  end
end

function UIFriendItem:OnBtnforbidClicked()
  utils.popUpDirectionsUI({
    tipsID = 1171,
    bUseSystemWord = true,
    fContentCB = function(content)
      local str = self.m_itemData and self.m_itemData.sName or ""
      return string.gsubnumberreplace(content, str)
    end,
    func1 = function()
      if self.m_itemData then
        FriendManager:RqsBlockFriend(self.m_itemData.stRoleId, function()
          local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_itemRootObj, "Friend_item_out")
          UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "Friend_item_out")
          self.timer = TimeService:SetTimer(aniLen, 1, function()
            self:broadcastEvent("eGameEvent_UpdateFriendState")
          end)
        end)
      end
    end
  })
end

function UIFriendItem:OnBtnforbidgrayClicked()
  utils.popUpDirectionsUI({
    tipsID = 1172,
    bUseSystemWord = true,
    fContentCB = function(content)
      local str = self.m_itemData and self.m_itemData.sName or ""
      return string.gsubnumberreplace(content, str)
    end,
    func1 = function()
      if self.m_itemData then
        FriendManager:RqsRemoveFromShield(self.m_itemData.stRoleId, function()
          local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_itemRootObj, "Friend_item_out")
          UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "Friend_item_out")
          self.timer = TimeService:SetTimer(aniLen, 1, function()
            self:broadcastEvent("eGameEvent_UpdateFriendState")
          end)
        end)
      end
    end
  })
end

function UIFriendItem:OnBtnagreeClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10321))
end

function UIFriendItem:OnBtnaddClicked()
  FriendManager:RqsAddFriend(self.m_itemData.stRoleId, function()
    self:OnFreshData()
  end)
end

function UIFriendItem:OnBtnaddgrayClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10322))
end

function UIFriendItem:OnBtnacceptClicked()
  FriendManager:RqsConfirmFriendRequest(self.m_itemData.stRoleId, function()
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_itemRootObj, "Friend_item_out")
    UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "Friend_item_out")
    self.timer = TimeService:SetTimer(aniLen, 1, function()
      self:broadcastEvent("eGameEvent_UpdateFriendState")
    end)
  end)
end

function UIFriendItem:OnBtnrejectClicked()
  if FriendManager:GetCurFriendTab() == 3 then
    FriendManager:RqsDelFriendRequest(self.m_itemData.stRoleId, function()
      local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_itemRootObj, "Friend_item_out")
      UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "Friend_item_out")
      self.timer = TimeService:SetTimer(aniLen, 1, function()
        self:broadcastEvent("eGameEvent_UpdateFriendState")
      end)
    end)
  elseif FriendManager:GetCurFriendTab() == 4 then
    utils.popUpDirectionsUI({
      tipsID = 1172,
      bUseSystemWord = true,
      fContentCB = function(content)
        local str = self.m_itemData and self.m_itemData.sName or ""
        return string.gsubnumberreplace(content, str)
      end,
      func1 = function()
        if self.m_itemData then
          FriendManager:RqsRemoveFromShield(self.m_itemData.stRoleId, function()
            local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_itemRootObj, "Friend_item_out")
            UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "Friend_item_out")
            self.timer = TimeService:SetTimer(aniLen, 1, function()
              self:broadcastEvent("eGameEvent_UpdateFriendState")
            end)
          end)
        end
      end
    })
  end
end

function UIFriendItem:OnPlayerHeadClk()
  if not self.m_itemData then
    return
  end
  local tempStRoleID = self.m_itemData.stRoleId
  StackPopup:Push(UIDefines.ID_FORM_PERSONALCARD, {
    zoneID = tempStRoleID.iZoneId,
    otherRoleID = tempStRoleID.iUid
  })
end

function UIFriendItem:dispose()
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  UIFriendItem.super.dispose(self)
end

return UIFriendItem
