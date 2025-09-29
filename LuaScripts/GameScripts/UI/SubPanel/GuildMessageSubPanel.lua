local UISubPanelBase = require("UI/Common/UISubPanelBase")
local GuildMessageSubPanel = class("GuildMessageSubPanel", UISubPanelBase)
local __MessageType = {
  None = 0,
  Own = 1,
  Unprocessed = 2,
  Done = 3
}
local __MessageCDType = {Enter = 10250, Send = 10251}
local __MessageBG = {
  "Atlas_Guild-6/guild_img_board_listbg_01",
  "Atlas_Guild-6/guild_img_board_listbg_02"
}
local __defaultHeroHead = {
  iHeadId = 0,
  iHeadFrameId = 0,
  iLevel = 1,
  sRoleName = ""
}

function GuildMessageSubPanel:OnInit()
  self.m_stRoleId = {
    iZoneId = UserDataManager:GetZoneID(),
    iUid = RoleManager:GetUID()
  }
  self.m_DoubleTrigger = self.m_btnTipsClose:GetComponent("ButtonTriggerDouble")
  if self.m_DoubleTrigger then
    self.m_DoubleTrigger.Clicked = handler(self, self.OnCloseTabClk)
  end
  self.m_rootTrans = self.m_rootObj.transform
  __defaultHeroHead.sRoleName = ConfigManager:GetCommonTextById(20367)
end

function GuildMessageSubPanel:OnFreshData()
  self.m_topId = GuildManager:GetTopMessageId()
  self.m_upList, self.m_downList = {}, {}
  self:OnCloseTabClk()
  self:refreshLoopScroll()
  local flag = GuildManager:CheckOwnHaveMessagePermission()
  self.m_btn_send:SetActive(flag)
  self.m_cdTypeStr = nil
  self:RefreshCDUI()
end

function GuildMessageSubPanel:RefreshCDUI()
  local cd, startCd = GuildManager:GetGuildMessageCd()
  local joinTime = GuildManager:GetMyAllianceJoinTime()
  local serverTime = TimeUtil:GetServerTimeS()
  self.m_cutDownTime = nil
  self:ClearTimer()
  local lastSendTime = GuildManager:GetLastSendMessageTime()
  if joinTime and 0 < joinTime and startCd > serverTime - joinTime then
    self.m_cdTypeStr = __MessageCDType.Enter
  elseif lastSendTime and 0 < lastSendTime and cd > serverTime - lastSendTime then
    self.m_cutDownTime = cd - (serverTime - lastSendTime)
    self.m_cdTypeStr = __MessageCDType.Send
  end
  if self.m_cutDownTime and self.m_cutDownTime > 0 then
    self.m_txt_cd:SetActive(true)
    self.m_z_txt_sendmes:SetActive(false)
    self.m_txt_cd_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100112), self.m_cutDownTime)
    self.m_downTimer = TimeService:SetTimer(1, -1, function()
      self.m_cutDownTime = self.m_cutDownTime - 1
      if not utils.isNull(self.m_txt_cd_Text) then
        if self.m_cutDownTime < 0 then
          self:ClearTimer()
          self.m_txt_cd:SetActive(false)
          self.m_z_txt_sendmes:SetActive(true)
        end
        self.m_txt_cd_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100112), self.m_cutDownTime)
      end
    end)
  else
    self.m_txt_cd:SetActive(false)
    self.m_z_txt_sendmes:SetActive(true)
  end
end

function GuildMessageSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_MessageNoticeLeave", handler(self, self.OnNewMessageCB))
  self:addEventListener("eGameEvent_Alliance_MessageNoticeChange", handler(self, self.OnFreshData))
  self:addEventListener("eGameEvent_Alliance_MessageNoticePin", handler(self, self.OnPinMessage))
  self:addEventListener("eGameEvent_Alliance_MessageNoticeUnPin", handler(self, self.OnUnPinMessage))
end

function GuildMessageSubPanel:OnPinMessage()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10252)
  self:OnFreshData()
end

function GuildMessageSubPanel:OnUnPinMessage()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10253)
  self:OnFreshData()
end

function GuildMessageSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
  self:ClearTimer()
end

function GuildMessageSubPanel:OnNewMessageCB()
  self:OnFreshData()
  if self.m_loop_scroll_view then
    self.m_loop_scroll_view:moveToCellIndex(1)
  end
end

function GuildMessageSubPanel:refreshLoopScroll()
  local data = GuildManager:GetAllAllianceMessages()
  self.m_messagesIndexes = GuildManager:GetAllNeedRemindMessagesIndex(data)
  self.m_pnl_empty:SetActive(#data == 0)
  local all_cell_size = self:CalculateChatCellSize(data)
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_message_list
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      all_cell_size = all_cell_size,
      update_cell = function(index, cell_object, cell_data)
        self:updateScrollViewCell(index, cell_object, cell_data)
        self:CalculateCellRedPoint(self.m_messagesIndexes)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        CS.GlobalManager.Instance:TriggerWwiseBGMState(138)
        local iAllianceId = RoleManager:GetRoleAllianceInfo()
        if click_name == "m_btn_receive" then
          GuildManager:ReqAllianceMessageNoticeConfirmCS(iAllianceId, cell_data.iNoticeID)
        elseif click_name == "m_btn_search" then
          StackPopup:Push(UIDefines.ID_FORM_GUILDCONFIRMATIONLIST, cell_data)
        elseif click_name == "m_btn_set" then
          self:OnItemClick(click_object, cell_data)
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data, true, all_cell_size)
  end
  self:CalculateCellRedPoint(self.m_messagesIndexes)
end

function GuildMessageSubPanel:CalculateCellRedPoint(messagesIndexes)
  if not messagesIndexes then
    return
  end
  local tips = ConfigManager:GetCommonTextById(100114)
  local activeIndexList = {}
  if self.m_loop_scroll_view then
    activeIndexList = self.m_loop_scroll_view:GetActiveCellsIndexList()
  end
  self.m_upList, self.m_downList = GuildManager:CheckNeedRemindMessageUpDown(messagesIndexes, activeIndexList)
  if self.m_upList and #self.m_upList > 0 then
    if not utils.isNull(self.m_btn_topsure) then
      UILuaHelper.SetActive(self.m_btn_topsure, true)
      self.m_txt_topsure_Text.text = string.gsubnumberreplace(tips, #self.m_upList)
    end
  elseif not utils.isNull(self.m_btn_topsure) then
    UILuaHelper.SetActive(self.m_btn_topsure, false)
  end
  if self.m_downList and #self.m_downList > 0 then
    if not utils.isNull(self.m_btn_downsure) then
      UILuaHelper.SetActive(self.m_btn_downsure, true)
      self.m_txt_downsure_Text.text = string.gsubnumberreplace(tips, #self.m_downList)
    end
  elseif not utils.isNull(self.m_btn_downsure) then
    UILuaHelper.SetActive(self.m_btn_downsure, false)
  end
end

function GuildMessageSubPanel:updateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local showDel = cell_data.iDeleteTime and cell_data.iDeleteTime ~= 0
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_img_message_ontop", not showDel)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_delettips", showDel)
  local playerData = GuildManager:GetGuildMemberDataByPlayerIDType(cell_data.stSender)
  if not showDel then
    local img = LuaBehaviourUtil.findImg(luaBehaviour, "m_icon_ President")
    if playerData then
      LuaBehaviourUtil.setText(luaBehaviour, "m_txt_playername", playerData.sRoleName)
      ResourceUtil:CreateGuildPostIconByPost(img, playerData.iPost)
    else
      LuaBehaviourUtil.setText(luaBehaviour, "m_txt_playername", __defaultHeroHead.sRoleName)
      ResourceUtil:CreateGuildPostIconByPost(img, GuildManager.AlliancePost.Member)
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_top", cell_data.iNoticeID == self.m_topId)
    LuaBehaviourUtil.setText(luaBehaviour, "m_txt_playertalk", cell_data.sContent)
    local iTime = cell_data.iLastEditTime == 0 and cell_data.iSendTime or cell_data.iLastEditTime
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_time", TimeUtil:GetOfflineTimeText(iTime, true))
    local state = self:CheckMessageState(cell_data)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_sure", state == __MessageType.Own)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_done", state == __MessageType.Done)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_btn_receive", state == __MessageType.Unprocessed)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_reddot", state == __MessageType.Unprocessed)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_set", cell_data.iLastEditTime ~= 0 and cell_data.iLastEditTime ~= cell_data.iSendTime)
    local edit = GuildManager:CheckOwnHaveEditMessagePermission(cell_data)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_btn_set", edit)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pnl_checkmes", true)
    if state == __MessageType.Own and cell_data.iNoticeType == GuildManager.AllianceMessageType.All then
      local confirmList, unconfirmedList = GuildManager:GetMessageConfirmPlayer(cell_data)
      local num = #confirmList
      local allNum = num + #unconfirmedList
      local str = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100113), num, allNum)
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_surenum", str)
    end
    local imgName = cell_data.iNoticeID == self.m_topId and __MessageBG[1] or __MessageBG[2]
    LuaBehaviourUtil.setTpImg(luaBehaviour, "m_pnl_img_message_ontop", imgName)
    local c_circle_head = luaBehaviour:FindGameObject("c_circle_head")
    if c_circle_head then
      if not self.m_PlayerHeadCache then
        self.m_PlayerHeadCache = {}
      end
      local gameObjectHashCode = c_circle_head:GetHashCode()
      local tempPlayerHeadCom = self.m_PlayerHeadCache[gameObjectHashCode]
      if not tempPlayerHeadCom then
        tempPlayerHeadCom = self:createPlayerHead(c_circle_head)
        self.m_PlayerHeadCache[gameObjectHashCode] = tempPlayerHeadCom
      end
      local member
      member = GuildManager:GetGuildMemberDataByPlayerIDType(cell_data.stSender)
      member = member or __defaultHeroHead
      tempPlayerHeadCom:SetPlayerHeadInfo(member)
    end
  else
    local isSame = GuildManager:CheckGuildMemberDataByPlayerIDType(cell_data.stDeleter, cell_data.stSender)
    local playerData2 = GuildManager:GetGuildMemberDataByPlayerIDType(cell_data.stDeleter)
    local str = ""
    local delName = playerData2 and playerData2.sRoleName or __defaultHeroHead.sRoleName
    local sendName = playerData and playerData.sRoleName or __defaultHeroHead.sRoleName
    if isSame then
      str = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100111), delName)
    else
      str = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100110), delName, sendName)
    end
    LuaBehaviourUtil.setText(luaBehaviour, "m_txt_delettips", str)
  end
end

function GuildMessageSubPanel:CalculateChatCellSize(msgList)
  local msg_cell_size = {}
  local context_text = self.m_txt_message_Text
  local context_rectTrans = self.m_pnl_message
  if table.getn(msgList) > 0 then
    for _, msg in pairs(msgList) do
      local height = 0
      if msg.iDeleteTime and msg.iDeleteTime == 0 then
        context_text.text = msg.sContent
        UILuaHelper.ForceRebuildLayoutImmediate(context_rectTrans)
        height = 180 + context_text.transform.sizeDelta.y
      else
        height = 60
      end
      local sizeData = Vector2.New(1153, height)
      table.insert(msg_cell_size, sizeData)
    end
  end
  return msg_cell_size
end

function GuildMessageSubPanel:OnBtnsendClicked()
  if self.m_cutDownTime and self.m_cutDownTime > 0 and self.m_cdTypeStr then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, self.m_cdTypeStr)
    return
  elseif self.m_cdTypeStr == __MessageCDType.Enter then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10250)
    return
  end
  local flag = GuildManager:CheckOwnHaveMessagePermission()
  if not flag then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_GUILDMESSAGEPOP)
end

function GuildMessageSubPanel:CheckMessageState(data)
  local state = __MessageType.None
  local needRemindAll = GuildManager:CheckMessageNeedRemindAll(data)
  if needRemindAll then
    local isOwn = GuildManager:CheckGuildMemberDataByPlayerIDType(data.stSender, self.m_stRoleId)
    if isOwn then
      state = __MessageType.Own
    elseif GuildManager:CheckMessageIsDone(data, self.m_stRoleId) then
      state = __MessageType.Done
    else
      state = __MessageType.Unprocessed
    end
  end
  return state
end

function GuildMessageSubPanel:OnItemClick(item, cell_data)
  self.m_pnl_tips:SetActive(true)
  self.m_clickItemData = cell_data
  self:RefreshTipsUI(cell_data)
  local pos = self.m_pnl_tips.transform.parent:InverseTransformPoint(item.transform.position)
  local _, content_h = UILuaHelper.GetUISize(self.m_pnl_tips)
  local _, height = UILuaHelper.GetUISize(self.m_rootTrans)
  local d_pos = Vector3.New(300, pos.y, pos.z)
  d_pos.y = math.max(math.min(d_pos.y, height * 0.5 - content_h * 0.5), -height * 0.5)
  UILuaHelper.SetLocalPosition(self.m_pnl_tips, d_pos.x, d_pos.y, 0)
end

function GuildMessageSubPanel:RefreshTipsUI(message)
  local delFlag = GuildManager:CheckOwnHaveDelMessagePermission(message)
  self.m_btn_delete:SetActive(delFlag)
  local pinFlag = GuildManager:CheckOwnHavePinMessagePermission()
  self.m_btn_untop:SetActive(message.iNoticeID == self.m_topId and pinFlag)
  self.m_btn_ontop:SetActive(message.iNoticeID ~= self.m_topId and pinFlag)
  local isOwn = GuildManager:CheckGuildMemberDataByPlayerIDType(message.stSender, self.m_stRoleId)
  self.m_btn_editor:SetActive(isOwn)
end

function GuildMessageSubPanel:OnCloseTabClk()
  self.m_pnl_tips:SetActive(false)
  self.m_clickItemData = nil
end

function GuildMessageSubPanel:OnBtnontopClicked()
  if self.m_clickItemData then
    self.m_topId = GuildManager:GetTopMessageId()
    if self.m_topId and self.m_topId ~= 0 then
      utils.popUpDirectionsUI({
        tipsID = 1245,
        func1 = function()
          local iAllianceId = RoleManager:GetRoleAllianceInfo()
          GuildManager:ReqAllianceMessageNoticePinCS(iAllianceId, self.m_clickItemData.iNoticeID)
        end
      })
    else
      local iAllianceId = RoleManager:GetRoleAllianceInfo()
      GuildManager:ReqAllianceMessageNoticePinCS(iAllianceId, self.m_clickItemData.iNoticeID)
    end
  end
end

function GuildMessageSubPanel:OnBtnuntopClicked()
  if self.m_clickItemData then
    local iAllianceId = RoleManager:GetRoleAllianceInfo()
    GuildManager:ReqAllianceMessageNoticeUnPinCS(iAllianceId, self.m_clickItemData.iNoticeID)
  end
end

function GuildMessageSubPanel:OnBtneditorClicked()
  if self.m_clickItemData then
    StackPopup:Push(UIDefines.ID_FORM_GUILDMESSAGEEDITORPOP, self.m_clickItemData.iNoticeID)
  end
end

function GuildMessageSubPanel:OnBtndeleteClicked()
  if self.m_clickItemData then
    utils.popUpDirectionsUI({
      tipsID = 1242,
      func1 = function()
        local iAllianceId = RoleManager:GetRoleAllianceInfo()
        GuildManager:ReqAllianceMessageNoticeDeleteCS(iAllianceId, self.m_clickItemData.iNoticeID)
      end
    })
  end
end

function GuildMessageSubPanel:OnBtntopsureClicked()
  if self.m_upList and #self.m_upList > 0 and self.m_loop_scroll_view then
    self.m_loop_scroll_view:moveToCellIndex(self.m_upList[#self.m_upList])
  end
end

function GuildMessageSubPanel:OnBtndownsureClicked()
  if self.m_downList and #self.m_downList > 0 and self.m_loop_scroll_view then
    self.m_loop_scroll_view:moveToCellIndex(self.m_downList[1])
  end
end

function GuildMessageSubPanel:ClearTimer()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
    self.m_cutDownTime = nil
  end
end

function GuildMessageSubPanel:dispose()
  GuildMessageSubPanel.super.dispose(self)
  self:ClearTimer()
end

return GuildMessageSubPanel
