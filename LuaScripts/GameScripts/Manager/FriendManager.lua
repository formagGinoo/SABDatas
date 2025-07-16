local BaseManager = require("Manager/Base/BaseManager")
local FriendManager = class("FriendManager", BaseManager)

function FriendManager:OnCreate()
  self.mFriendData = nil
  self.mFriendHeartRecieve = {}
  self.mAlreadyRqsAddedList = {}
  self.vShieldRole = nil
end

function FriendManager:OnInitNetwork()
  self.mFriendData = MTTDProto.Cmd_Friend_GetInit_SC()
  RPCS():Listen_Push_Friend_AddFriend(handler(self, self.OnPushAddFriend), "FriendManager")
  RPCS():Listen_Push_Friend_AddFriendRequest(handler(self, self.OnPushAddFriendRequest), "FriendManager")
  RPCS():Listen_Push_Friend_DelFriend(handler(self, self.OnPushDelFriend), "FriendManager")
  RPCS():Listen_Push_Friend_RecieveHeart(handler(self, self.OnPushRecieveHeart), "FriendManager")
end

function FriendManager:OnDailyReset()
  self.bIsDailyReset = true
  self.mFriendHeartRecieve = {}
  self.mFriendData.vFriendHeartRecieveTake = {}
  self.mFriendData.vFriendHeartRecieveUntake = {}
end

function FriendManager:DealFriendData()
  local msg = MTTDProto.Cmd_Friend_GetInit_CS()
  RPCS():Friend_GetInit(msg, handler(self, self.OnFriendGetInitSC))
  local chatmsg = MTTDProto.Cmd_Chat_GetShieldList_CS()
  RPCS():Chat_GetShieldList(chatmsg, handler(self, self.OnChatGetShieldListSC))
end

function FriendManager:OnInitMustRequestInFetchMore()
  self:DealFriendData()
end

function FriendManager:RqsFriendInfo(callback)
  if self.bIsDailyReset then
    local msg = MTTDProto.Cmd_Friend_GetInit_CS()
    RPCS():Friend_GetInit(msg, function(sc)
      self.mFriendHeartRecieve = {}
      self:OnFriendGetInitSC(sc)
      if callback then
        callback()
      end
    end)
  elseif callback then
    callback()
  end
  self.bIsDailyReset = false
end

function FriendManager:OnFriendGetInitSC(data)
  self.mFriendData = data
  for i, v in ipairs(data.vFriendHeartRecieveTake or {}) do
    local tempstr = v.iUid .. ";" .. v.iZoneId
    self.mFriendHeartRecieve[tempstr] = false
  end
  for i, v in ipairs(data.vFriendHeartRecieveUntake or {}) do
    local tempstr = v.iUid .. ";" .. v.iZoneId
    self.mFriendHeartRecieve[tempstr] = true
  end
  self:FreshFriendHeartRedDot()
  self:FreshFriendHaveRqsAddRedDot()
end

function FriendManager:OnChatGetShieldListSC(data)
  self.vShieldRole = data.vShieldRole
end

function FriendManager:OnPushAddFriend(data)
  table.insert(self.mFriendData.vFriend, data.stFriendInfo)
  for i, v in ipairs(self.mFriendData.vFriendRequest) do
    if v.stRoleId.iUid == data.stFriendInfo.stRoleId.iUid and v.stRoleId.iZoneId == data.stFriendInfo.stRoleId.iZoneId then
      table.remove(self.mFriendData.vFriendRequest, i)
      break
    end
  end
  self:broadcastEvent("eGameEvent_UpdateFriendState")
  self:FreshFriendHaveRqsAddRedDot()
end

function FriendManager:OnPushAddFriendRequest(data)
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local maxFriendApplyAccept = tonumber(GlobalManagerIns:GetValue_ByName("FriendApplyAccept").m_Value)
  for i, v in ipairs(self.mFriendData.vFriendRequest) do
    if v.stRoleId.iUid == data.stRequestInfo.stRoleId.iUid and v.stRoleId.iZoneId == data.stRequestInfo.stRoleId.iZoneId then
      table.remove(self.mFriendData.vFriendRequest, i)
      break
    end
  end
  table.insert(self.mFriendData.vFriendRequest, data.stRequestInfo)
  if maxFriendApplyAccept < #self.mFriendData.vFriendRequest then
    table.remove(self.mFriendData.vFriendRequest, 1)
  end
  self:broadcastEvent("eGameEvent_UpdateFriendState")
  self:FreshFriendHaveRqsAddRedDot()
end

function FriendManager:OnPushDelFriend(data)
  local stRoleId = data.stRoleId
  for i, v in ipairs(self.mFriendData.vFriend) do
    if v.stRoleId.iUid == stRoleId.iUid and v.stRoleId.iZoneId == stRoleId.iZoneId then
      table.remove(self.mFriendData.vFriend, i)
      break
    end
  end
  local tempstr = stRoleId.iUid .. ";" .. stRoleId.iZoneId
  self.mFriendHeartRecieve[tempstr] = false
  self:FreshFriendHaveRqsAddRedDot()
  self:FreshFriendHeartRedDot()
end

function FriendManager:OnPushRecieveHeart(data)
  local stRoleId = data.stRoleId
  local tempstr = stRoleId.iUid .. ";" .. stRoleId.iZoneId
  self.mFriendHeartRecieve[tempstr] = true
  self:broadcastEvent("eGameEvent_UpdateFriendState")
  self:FreshFriendHeartRedDot()
end

function FriendManager:RqsGetHeart(stRoleId, callback)
  if not self:PlayerIsFriend(stRoleId) then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10301))
    self:broadcastEvent("eGameEvent_UpdateFriendUIState")
    if callback then
      callback()
    end
    return
  end
  local msg = MTTDProto.Cmd_Friend_GatherHeart_CS()
  msg.stRoleId = stRoleId
  RPCS():Friend_GatherHeart(msg, function()
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10300))
    self.mFriendData.iDailyTakeHeartNum = self.mFriendData.iDailyTakeHeartNum + 1
    local tempstr = stRoleId.iUid .. ";" .. stRoleId.iZoneId
    self.mFriendHeartRecieve[tempstr] = false
    if callback then
      callback()
    end
    self:FreshFriendHeartRedDot()
    self:broadcastEvent("eGameEvent_UpdateFriendUIState")
  end)
end

function FriendManager:RqsSendHeart(stRoleId, callback)
  if not self:PlayerIsFriend(stRoleId) then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10301))
    self:broadcastEvent("eGameEvent_UpdateFriendUIState")
    if callback then
      callback()
    end
    return
  end
  local msg = MTTDProto.Cmd_Friend_SendHeart_CS()
  msg.stRoleId = stRoleId
  RPCS():Friend_SendHeart(msg, function()
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10302))
    table.insert(self.mFriendData.vFriendHeartSend, stRoleId)
    if callback then
      callback()
    end
    self:broadcastEvent("eGameEvent_UpdateFriendUIState")
  end)
end

function FriendManager:RqsGetAndSendAll(callback)
  local msg = MTTDProto.Cmd_Friend_GatherAndSendAllHeart_CS()
  RPCS():Friend_GatherAndSendAllHeart(msg, function(data)
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10320))
    self.mFriendData.iDailyTakeHeartNum = data.iDailyTakeHeartNum
    for i, stRoleId in ipairs(data.vFriendHeartRecieveTake) do
      local tempstr = stRoleId.iUid .. ";" .. stRoleId.iZoneId
      self.mFriendHeartRecieve[tempstr] = false
    end
    for i, stRoleId in ipairs(data.vFriendHeartRecieveUntake) do
      local tempstr = stRoleId.iUid .. ";" .. stRoleId.iZoneId
      self.mFriendHeartRecieve[tempstr] = true
    end
    self.mFriendData.vFriendHeartSend = {}
    for i, v in ipairs(self.mFriendData.vFriend) do
      table.insert(self.mFriendData.vFriendHeartSend, v.stRoleId)
    end
    if callback then
      callback()
    end
    self:FreshFriendHeartRedDot()
  end)
end

function FriendManager:RqsDeleteFriend(stRoleId, callback)
  local msg = MTTDProto.Cmd_Friend_DelFriend_CS()
  msg.stRoleId = stRoleId
  RPCS():Friend_DelFriend(msg, function()
    for i, v in ipairs(self.mFriendData.vFriend) do
      if v.stRoleId.iUid == stRoleId.iUid and v.stRoleId.iZoneId == stRoleId.iZoneId then
        table.remove(self.mFriendData.vFriend, i)
        break
      end
    end
    local tempstr = stRoleId.iUid .. ";" .. stRoleId.iZoneId
    self.mFriendHeartRecieve[tempstr] = false
    if callback then
      callback()
    end
    self:FreshFriendHeartRedDot()
  end)
end

function FriendManager:RqsBlockFriend(stRoleId, callback)
  if RoleManager:GetUID() == stRoleId.iUid and UserDataManager:GetZoneID() == stRoleId.iZoneId then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10326))
    return
  end
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local FriendBlackList = tonumber(GlobalManagerIns:GetValue_ByName("FriendBlackList").m_Value)
  local count = #self.vShieldRole
  if FriendBlackList <= count then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10317))
    return
  end
  local msg = MTTDProto.Cmd_Chat_AddToShield_CS()
  msg.stRoleId = stRoleId
  local roleData
  for i, v in ipairs(self.mFriendData.vFriend) do
    if v.stRoleId.iUid == stRoleId.iUid and v.stRoleId.iZoneId == stRoleId.iZoneId then
      roleData = v
      break
    end
  end
  RPCS():Chat_AddToShield(msg, function(data)
    for i, v in ipairs(self.vRecommendFriend or {}) do
      if v.stRoleId.iUid == stRoleId.iUid and v.stRoleId.iZoneId == stRoleId.iZoneId then
        table.remove(self.vRecommendFriend, i)
        roleData = roleData or v
        break
      end
    end
    for i, v in ipairs(self.vSearchList or {}) do
      if v.stRoleId.iUid == stRoleId.iUid and v.stRoleId.iZoneId == stRoleId.iZoneId then
        table.remove(self.vSearchList, i)
        roleData = roleData or v
        break
      end
    end
    table.insert(self.vShieldRole, roleData)
    if callback then
      callback()
    end
    self:FreshFriendHeartRedDot()
    self:FreshFriendHaveRqsAddRedDot()
  end)
end

function FriendManager:RqsRemoveFromShield(stRoleId, callback)
  local msg = MTTDProto.Cmd_Chat_RemoveFromShield_CS()
  msg.stRoleId = stRoleId
  RPCS():Chat_RemoveFromShield(msg, function()
    for i, v in ipairs(self.vShieldRole) do
      if v.stRoleId.iUid == stRoleId.iUid and v.stRoleId.iZoneId == stRoleId.iZoneId then
        table.remove(self.vShieldRole, i)
        break
      end
    end
    if callback then
      callback()
    end
  end)
end

function FriendManager:RqsGetRecommend(callback)
  local msg = MTTDProto.Cmd_Friend_GetRecommend_CS()
  RPCS():Friend_GetRecommend(msg, function(data)
    self.mAlreadyRqsAddedList = {}
    self.vRecommendFriend = data.vRecommendFriend
    if callback then
      callback(self.vRecommendFriend)
    end
  end)
end

function FriendManager:RqsSearchRole(iRoleId, callback)
  local msg = MTTDProto.Cmd_Friend_SearchRole_CS()
  msg.iRoleId = iRoleId
  RPCS():Friend_SearchRole(msg, function(data)
    self.vSearchList = data.vRole
    if callback then
      callback(self.vSearchList)
    end
  end)
end

function FriendManager:RqsAddFriend(stRoleId, callback)
  if RoleManager:GetUID() == stRoleId.iUid and UserDataManager:GetZoneID() == stRoleId.iZoneId then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10325))
    return
  end
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local MaxFriendCount = tonumber(GlobalManagerIns:GetValue_ByName("FriendMaxNumber").m_Value)
  local count = #self.mFriendData.vFriend
  if MaxFriendCount <= count then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10308))
    return
  end
  if self:PlayerIsShield(stRoleId) then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10316))
    return
  end
  local msg = MTTDProto.Cmd_Friend_AddFriend_CS()
  msg.stRoleId = stRoleId
  RPCS():Friend_AddFriend(msg, function()
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10307))
    self:SetRqsAddeddata2Local(stRoleId)
    if callback then
      callback()
    end
  end)
end

function FriendManager:RqsAddFriendBatch(callback)
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local MaxFriendCount = tonumber(GlobalManagerIns:GetValue_ByName("FriendMaxNumber").m_Value)
  local count = #self.mFriendData.vFriend
  if MaxFriendCount <= count then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10308))
    return
  end
  local msg = MTTDProto.Cmd_Friend_AddFriendBatch_CS()
  local list = {}
  for i, v in ipairs(self.vRecommendFriend) do
    if not self:IsFriendInAddedList(v.stRoleId) then
      table.insert(list, v.stRoleId)
    end
  end
  msg.vRoleId = list
  RPCS():Friend_AddFriendBatch(msg, function(data)
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10307))
    for i, v in ipairs(list) do
      self:SetRqsAddeddata2Local(v)
    end
    if callback then
      callback()
    end
  end)
end

function FriendManager:RqsConfirmFriendRequest(stRoleId, callback)
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local MaxFriendCount = tonumber(GlobalManagerIns:GetValue_ByName("FriendMaxNumber").m_Value)
  local count = #self.mFriendData.vFriend
  if MaxFriendCount <= count then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10308))
    return
  end
  local msg = MTTDProto.Cmd_Friend_ConfirmFriendRequest_CS()
  msg.stRoleId = stRoleId
  RPCS():Friend_ConfirmFriendRequest(msg, function()
    for i, v in ipairs(self.mFriendData.vFriendRequest) do
      if v.stRoleId.iUid == stRoleId.iUid and v.stRoleId.iZoneId == stRoleId.iZoneId then
        table.remove(self.mFriendData.vFriendRequest, i)
        break
      end
    end
    if callback then
      callback()
    end
    self:FreshFriendHaveRqsAddRedDot()
  end, function(fail_msg)
    if fail_msg.rspcode == MTTD.Error_Friend_NoFriendRequest then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10312))
      for i, v in ipairs(self.mFriendData.vFriendRequest) do
        if v.stRoleId.iUid == stRoleId.iUid and v.stRoleId.iZoneId == stRoleId.iZoneId then
          table.remove(self.mFriendData.vFriendRequest, i)
          break
        end
      end
      if callback then
        callback()
      end
      self:FreshFriendHaveRqsAddRedDot()
    end
  end)
end

function FriendManager:RqsDelFriendRequest(stRoleId, callback)
  local msg = MTTDProto.Cmd_Friend_DelFriendRequest_CS()
  msg.stRoleId = stRoleId
  RPCS():Friend_DelFriendRequest(msg, function()
    for i, v in ipairs(self.mFriendData.vFriendRequest) do
      if v.stRoleId.iUid == stRoleId.iUid and v.stRoleId.iZoneId == stRoleId.iZoneId then
        table.remove(self.mFriendData.vFriendRequest, i)
        break
      end
    end
    if callback then
      callback()
    end
    self:FreshFriendHaveRqsAddRedDot()
  end)
end

function FriendManager:RqsConfirmAllFriendRequest(callback)
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local MaxFriendCount = tonumber(GlobalManagerIns:GetValue_ByName("FriendMaxNumber").m_Value)
  local count = #self.mFriendData.vFriend
  if MaxFriendCount <= count then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10308))
    return
  end
  local msg = MTTDProto.Cmd_Friend_ConfirmAllFriendRequest_CS()
  RPCS():Friend_ConfirmAllFriendRequest(msg, function()
    self.mFriendData.vFriendRequest = {}
    if callback then
      callback()
    end
    self:FreshFriendHaveRqsAddRedDot()
  end)
end

function FriendManager:RqsDelAllFriendRequest(callback)
  local msg = MTTDProto.Cmd_Friend_DelAllFriendRequest_CS()
  RPCS():Friend_DelAllFriendRequest(msg, function()
    self.mFriendData.vFriendRequest = {}
    if callback then
      callback()
    end
    self:FreshFriendHaveRqsAddRedDot()
  end)
end

function FriendManager:GetFriendInfo()
  return self.mFriendData
end

function FriendManager:GetRecommendFriend()
  return self.vRecommendFriend
end

function FriendManager:GetSearchList()
  return self.vSearchList
end

function FriendManager:GetShieldRole()
  return self.vShieldRole
end

function FriendManager:SetCurFriendTab(idx)
  self.curFriendTab = idx
end

function FriendManager:GetCurFriendTab()
  return self.curFriendTab or 1
end

function FriendManager:GetFriendHeartState(stRoleId)
  local data = self.mFriendHeartRecieve
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local maxTimes = tonumber(GlobalManagerIns:GetValue_ByName("FriendPointsAcceptMax").m_Value)
  local perTimesCount = tonumber(GlobalManagerIns:GetValue_ByName("FriendPointsNumber").m_Value)
  if maxTimes * perTimesCount <= self.mFriendData.iDailyTakeHeartNum * perTimesCount then
    return false
  end
  local tempstr = stRoleId.iUid .. ";" .. stRoleId.iZoneId
  for i, v in pairs(data) do
    if tempstr == i then
      return v
    end
  end
end

function FriendManager:GetFriendSendHeartState(stRoleId)
  local data = self.mFriendData.vFriendHeartSend
  for i, v in pairs(data) do
    if v.iUid == stRoleId.iUid and v.iZoneId == stRoleId.iZoneId then
      return true
    end
  end
  return false
end

function FriendManager:PlayerIsFriend(stRoleId)
  for i, v in ipairs(self.mFriendData.vFriend) do
    if v.stRoleId.iUid == stRoleId.iUid and v.stRoleId.iZoneId == stRoleId.iZoneId then
      return true
    end
  end
  return false
end

function FriendManager:PlayerIsShield(stRoleId)
  for i, v in ipairs(self.vShieldRole) do
    if v.stRoleId.iUid == stRoleId.iUid and v.stRoleId.iZoneId == stRoleId.iZoneId then
      return true
    end
  end
  return false
end

function FriendManager:CanSendPoints()
  local data = self.mFriendData.vFriendHeartSend
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local maxSendCount = tonumber(GlobalManagerIns:GetValue_ByName("FriendPointsSendMax").m_Value)
  return maxSendCount > #data
end

function FriendManager:CanGetAndSendAll()
  local flag = false
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local maxTimes = tonumber(GlobalManagerIns:GetValue_ByName("FriendPointsAcceptMax").m_Value)
  local perTimesCount = tonumber(GlobalManagerIns:GetValue_ByName("FriendPointsNumber").m_Value)
  local data = self.mFriendHeartRecieve
  for i, v in pairs(data) do
    if v then
      flag = true
      break
    end
  end
  if maxTimes * perTimesCount <= self.mFriendData.iDailyTakeHeartNum * perTimesCount then
    flag = false
  end
  if flag then
    return flag
  end
  for i, v in ipairs(self.mFriendData.vFriend) do
    local is_have = false
    for _, vv in ipairs(self.mFriendData.vFriendHeartSend) do
      if v.stRoleId.iUid == vv.iUid and v.stRoleId.iZoneId == vv.iZoneId then
        is_have = true
      end
    end
    if not is_have then
      flag = true
      break
    end
  end
  if not self:CanSendPoints() then
    flag = false
  end
  return flag
end

function FriendManager:CanRqsAddAllFriend()
  local flag = false
  for i, v in ipairs(self.vRecommendFriend) do
    if not self:IsFriendInAddedList(v.stRoleId) then
      flag = true
    end
  end
  return flag
end

function FriendManager:IsFriendInAddedList(stRoleId)
  local tempstr = stRoleId.iUid .. ";" .. stRoleId.iZoneId
  return self.mAlreadyRqsAddedList[tempstr]
end

function FriendManager:SetRqsAddeddata2Local(stRoleId)
  local tempstr = stRoleId.iUid .. ";" .. stRoleId.iZoneId
  self.mAlreadyRqsAddedList[tempstr] = true
end

function FriendManager:FreshFriendHeartRedDot()
  local flag = false
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local maxTimes = tonumber(GlobalManagerIns:GetValue_ByName("FriendPointsAcceptMax").m_Value)
  local perTimesCount = tonumber(GlobalManagerIns:GetValue_ByName("FriendPointsNumber").m_Value)
  local data = self.mFriendHeartRecieve
  for i, v in pairs(data) do
    if v then
      flag = true
    end
  end
  if maxTimes * perTimesCount <= self.mFriendData.iDailyTakeHeartNum * perTimesCount then
    flag = false
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.FriendHaveHeart,
    count = flag and 1 or 0
  })
end

function FriendManager:FreshFriendHaveRqsAddRedDot()
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.FriendHaveRqsAdd,
    count = #self.mFriendData.vFriendRequest
  })
end

return FriendManager
