local BaseManager = require("Manager/Base/BaseManager")
local RoleManager = class("RoleManager", BaseManager)
local TotalFreshServerTimeSecNum = 100
local MaxTTRTimeNum = 2000
local CsTime = CS.UnityEngine.Time
local OneSecondOfMS = 1000
RoleManager.MaxHallBgPosNum = 5
local DefaultMainBgIndex = 1

function RoleManager:OnCreate()
  self.m_uid = nil
  self.m_name = nil
  self.m_level = nil
  self.m_oldPlayerLv = nil
  self.m_oldPlayerExp = nil
  self.m_iAllianceId = nil
  self.m_sAllianceName = nil
  self.m_iAllianceLevel = nil
  self.m_iTotalRecharge = nil
  self.m_sLoginRoleCountry = nil
  self.m_sCreateRoleCountry = nil
  self.m_bNewRole = false
  self.iRoleRegTime = nil
  self.m_reqSceneRealTime = nil
  self.m_headID = nil
  self.m_headCfgDic = {}
  self.m_headFrameID = nil
  self.m_headFrameCfgDic = {}
  self.m_headFrameExpireTime = nil
  self.m_headBackgroundID = nil
  self.m_playerBackgroundCfgDic = {}
  self.m_mainBGIndex = nil
  self.m_mainBGDataList = {}
  self.m_mainBGCfgDic = {}
  self:AddEventListener()
end

function RoleManager:AddEventListener()
  self:addEventListener("eGameEvent_Item_SetItem", handler(self, self.OnItemChange))
  self:addEventListener("eGameEvent_UnlockSystem", handler(self, self.OnSystemUnlock))
end

function RoleManager:OnItemChange(changeItemDataList)
  if not changeItemDataList then
    return
  end
  for i, v in ipairs(changeItemDataList) do
    if v.iNum > 0 then
      local headFrame = self:GetPlayerHeadFrameCfg(v.iID)
      if headFrame ~= nil then
        self:SetRoleHeadFrameNewFlag(v.iID, 1)
      end
      local headCfg = self:GetPlayerHeadCfg(v.iID)
      if headCfg ~= nil then
        self:SetRoleHeadNewFlag(v.iID, 1)
      end
      local mainBgCfg = self:GetMainBackgroundCfg(v.iID)
      if mainBgCfg ~= nil then
        self:SetRoleMainBackgroundNewFlag(v.iID, 1)
      end
    end
  end
end

function RoleManager:OnSystemUnlock(unlockSystemIDList)
  if not unlockSystemIDList then
    return
  end
  for i, v in ipairs(unlockSystemIDList) do
    if v == GlobalConfig.SYSTEM_ID.Decorate then
      self:CheckFreshHallDecorateFirstEnterRedDotCount()
      self:CheckUpdateMainBackgroundRedDotCount()
    end
  end
end

function RoleManager:OnInitNetwork()
  RPCS():Listen_Push_SetLevel(handler(self, self.OnPushSetLevel), "RoleManager")
  RPCS():Listen_Push_Warning(handler(self, self.OnPushWarning), "RoleManager")
  RPCS():Listen_Push_TotalRecharge(handler(self, self.OnPushTotalRecharge), "RoleManager")
  RPCS():Listen_Push_Notice(handler(self, self.OnPushNotice), "RoleManager")
end

function RoleManager:OnAfterFreshData()
  RoleManager.MainBgType = {
    Empty = MTTDProto.MainBackgroundType_Empty,
    Role = MTTDProto.MainBackgroundType_Hero,
    Activity = MTTDProto.MainBackgroundType_Item,
    Fashion = MTTDProto.MainBackgroundType_Fashion
  }
  self:ReqRoleGetNotice()
  self.m_reqSceneRealTime = CsTime.realtimeSinceStartup
  self:CheckUpdateHeadRedDotCount()
  self:CheckUpdateHeadFrameRedDotCount()
  self:CheckUpdateMainBackgroundRedDotCount()
  self:FreshMainBGDataList(self.m_mainBGDataList or {})
  self:CheckFreshHallDecorateFirstEnterRedDotCount()
end

function RoleManager:OnUpdate(dt)
  if self.m_reqSceneRealTime and CsTime.realtimeSinceStartup - self.m_reqSceneRealTime > TotalFreshServerTimeSecNum then
    self:ReqRoleServerTime()
  end
end

function RoleManager:OnPushSetLevel(stLevel, msg)
  local levelNum = stLevel.iLevel
  local vItem = stLevel.vItem
  local lastLevel = self.m_level
  self.m_level = stLevel.iLevel
  local stRoleInitSC = CS.UserData.Instance.roleInit
  CS.ReportService.Instance:SetUserInfoVerbose(UserDataManager:GetAccountID(), UserDataManager:GetZoneID(), stLevel.iLevel, stRoleInitSC.iRoleRegTime, TimeUtil:TimerToString2(stRoleInitSC.iRoleRegTime), stRoleInitSC.iTotalRechargeDiamond)
  if ChannelManager:IsUsingQSDK() then
    QSDKManager:UpdateRole()
  end
  self:broadcastEvent("eGameEvent_Role_SetLevel", {
    lastLevel = lastLevel,
    curLevel = levelNum,
    rewardItem = vItem
  })
end

function RoleManager:OnPushWarning(stWarning, msg)
  if not stWarning then
    return
  end
  local errorCode = stWarning.iErrorCode
  if not errorCode then
    return
  end
  local sContent = ConfigManager:GetCommonTextById(20005) .. errorCode
  local showMessageCfg = ConfigManager:GetConfigInsByName("ShowMessage")
  if showMessageCfg then
    local element = showMessageCfg:GetValue_ByID(errorCode)
    if element and element.m_mMessage then
      sContent = element.m_mMessage
    end
  end
  local tParam = {}
  tParam.content = sContent
  tParam.title = ConfigManager:GetCommonTextById(20004)
  tParam.funcText1 = ConfigManager:GetCommonTextById(20006)
  tParam.btnNum = 1
  utils.CheckAndPushCommonTips(tParam)
end

function RoleManager:OnPushTotalRecharge(data)
  self.m_iTotalRecharge = data.iTotalRecharge
end

function RoleManager:OnPushNotice(data)
  utils.addRollingTips(data.vNoticeData)
end

function RoleManager:ReqRoleGetNotice()
  local randomNameCSMsg = MTTDProto.Cmd_Role_GetNotice_CS()
  RPCS():Role_GetNotice(randomNameCSMsg, handler(self, self.OnRoleGetNoticeSC))
end

function RoleManager:OnRoleGetNoticeSC(data, msg)
  if table.getn(data.vNoticeData) > 0 then
    utils.addRollingTips(data.vNoticeData)
  end
end

function RoleManager:ReqGetRandomNameFirst()
  if self.vRandomNameList and #self.vRandomNameList > 0 then
    return
  end
  local randomNameCSMsg = MTTDProto.Cmd_Role_RandomName_CS()
  RPCS():Role_RandomName(randomNameCSMsg, handler(self, self.OnRandomNameSCFirst))
end

function RoleManager:OnRandomNameSCFirst(data, msg)
  self.vRandomNameList = data.vName
end

function RoleManager:ReqGetRandomName()
  if self.vRandomNameList and #self.vRandomNameList > 0 then
    self:broadcastEvent("eGameEvent_Rename_GetRename", self.vRandomNameList[1])
    table.remove(self.vRandomNameList, 1)
    return
  end
  local randomNameCSMsg = MTTDProto.Cmd_Role_RandomName_CS()
  RPCS():Role_RandomName(randomNameCSMsg, handler(self, self.OnRandomNameSC))
end

function RoleManager:OnRandomNameSC(data, msg)
  self.vRandomNameList = data.vName
  self:broadcastEvent("eGameEvent_Rename_GetRename", self.vRandomNameList[1])
  table.remove(self.vRandomNameList, 1)
end

function RoleManager:ReqRoleSetName(nameStr)
  local randomNameCSMsg = MTTDProto.Cmd_Role_SetName_CS()
  randomNameCSMsg.sName = nameStr
  RPCS():Role_SetName(randomNameCSMsg, handler(self, self.OnRoleSetNameSC))
end

function RoleManager:OnRoleSetNameSC(data, msg)
  self.m_name = data.sName
  self:broadcastEvent("eGameEvent_Rename_SetName", data.sName)
end

function RoleManager:ReqVerifyNameIsOnly(nameStr)
  local randomNameCSMsg = MTTDProto.Cmd_Role_SetName_CS()
  randomNameCSMsg.sName = nameStr
  randomNameCSMsg.bCheckNameOnly = true
  RPCS():Role_SetName(randomNameCSMsg, handler(self, self.OnVerifyNameIsOnlySC), handler(self, self.OnVerifyNameIsOnlyFailed))
end

function RoleManager:OnVerifyNameIsOnlySC(data, msg)
end

function RoleManager:OnVerifyNameIsOnlyFailed(msg)
  if msg == nil or msg.rspcode == 0 then
    return
  end
  local iErrorCode = msg.rspcode
  if iErrorCode == 1290 then
    self:broadcastEvent("eGameEvent_Rename_SetNameNotOnly")
  end
end

function RoleManager:ReqRoleServerTime()
  self.m_reqSceneRealTime = CsTime.realtimeSinceStartup
  local msg = MTTDProto.Cmd_Role_ServerTime_CS()
  RPCS():Role_ServerTime(msg, handler(self, self.OnServerTimeSC))
end

function RoleManager:OnServerTimeSC(serverTimeSC, msg)
  if not serverTimeSC then
    return
  end
  if not self.m_reqSceneRealTime then
    return
  end
  local backSceneRealTime = CsTime.realtimeSinceStartup
  local tempTTR = (backSceneRealTime - self.m_reqSceneRealTime) * OneSecondOfMS
  if tempTTR > MaxTTRTimeNum then
    return
  end
  local serverTimeMS = serverTimeSC.iServerTimeMS
  serverTimeMS = serverTimeMS + math.floor(tempTTR / 2)
  local gmtOff = serverTimeSC.iTimeGmtOff
  TimeUtil:SetServerTime(serverTimeMS)
  TimeUtil:SetServerTimeGmtOff(gmtOff)
end

function RoleManager:ReqRoleSeeBusinessCard(uid, zoneID)
  if not uid then
    return
  end
  if not zoneID then
    return
  end
  local msg = MTTDProto.Cmd_Role_SeeBusinessCard_CS()
  msg.iUid = uid
  msg.iZoneId = zoneID
  RPCS():Role_SeeBusinessCard(msg, handler(self, self.OnRoleSeeBusinessCardSC))
end

function RoleManager:OnRoleSeeBusinessCardSC(seeRoleBusinessCardSC, msg)
  if not seeRoleBusinessCardSC then
    return
  end
  local tempRoleBusinessCardInfo = seeRoleBusinessCardSC.stRoleBusinessCard
  if not tempRoleBusinessCardInfo then
    return
  end
  self:broadcastEvent("eGameEvent_RoleBusinessCard", {roleBusinessCard = tempRoleBusinessCardInfo})
end

function RoleManager:ReqRoleSetCard(headID, headFrameID, bgID)
  if not headID then
    return
  end
  if not headFrameID then
    return
  end
  bgID = bgID or self:GetHeadBackGroundID()
  local msg = MTTDProto.Cmd_Role_SetCard_CS()
  msg.iHeadId = headID
  msg.iHeadFrameId = headFrameID
  msg.iShowBackgroundId = bgID
  RPCS():Role_SetCard(msg, handler(self, self.OnRoleSetCardSC))
end

function RoleManager:OnRoleSetCardSC(stRoleSetCardSC, msg)
  if not stRoleSetCardSC then
    return
  end
  self.m_headID = stRoleSetCardSC.iHeadId
  self.m_headFrameID = stRoleSetCardSC.iHeadFrameId
  self.m_headFrameExpireTime = ItemManager:GetItemExpireTime(self.m_headFrameID) or 0
  self.m_headBackgroundID = stRoleSetCardSC.iShowBackgroundId
  self:broadcastEvent("eGameEvent_RoleSetCard", {
    headID = stRoleSetCardSC.iHeadId,
    headFrameID = stRoleSetCardSC.iHeadFrameId,
    bgID = stRoleSetCardSC.iShowBackgroundId
  })
end

function RoleManager:ReqRoleSetMainBackground(allMainBGDataList)
  if not allMainBGDataList then
    return
  end
  local msg = MTTDProto.Cmd_Role_SetMainBackground_CS()
  msg.vMainBackground = allMainBGDataList
  RPCS():Role_SetMainBackground(msg, handler(self, self.OnRoleSetMainBackgroundSC))
end

function RoleManager:OnRoleSetMainBackgroundSC(stRoleSetMainBackgroundSC, msg)
  if not stRoleSetMainBackgroundSC then
    return
  end
  self.m_mainBGIndex = stRoleSetMainBackgroundSC.iIndex
  self:FreshMainBGDataList(stRoleSetMainBackgroundSC.vMainBackground)
  self:broadcastEvent("eGameEvent_Role_SetMainBackground")
end

function RoleManager:ReqRoleSetMainBackgroundIndex(mainBackgroundIndex)
  if not mainBackgroundIndex then
    return
  end
  local msg = MTTDProto.Cmd_Role_SetMainBackgroundIndex_CS()
  msg.iIndex = mainBackgroundIndex
  RPCS():Role_SetMainBackgroundIndex(msg, handler(self, self.OnRoleSetMainBackgroundIndexSC))
end

function RoleManager:OnRoleSetMainBackgroundIndexSC(stRoleSetMainBackgroundIndexSC, msg)
  if not stRoleSetMainBackgroundIndexSC then
    return
  end
  self.m_mainBGIndex = stRoleSetMainBackgroundIndexSC.iIndex
  self:broadcastEvent("eGameEvent_Role_SetMainBackgroundIndex")
end

function RoleManager:GetDefaultHeadID()
  local headIns = ConfigManager:GetConfigInsByName("PlayerHead")
  local allCfgDic = headIns:GetAll()
  for _, v in pairs(allCfgDic) do
    if v.m_DefaultType == 1 then
      return v.m_HeadID
    end
  end
end

function RoleManager:GetDefaultHeadFrameID()
  local headFrameIns = ConfigManager:GetConfigInsByName("PlayerHeadFrame")
  local allCfgDic = headFrameIns:GetAll()
  for _, v in pairs(allCfgDic) do
    if v.m_DefaultType == 1 then
      return v.m_HeadFrameID
    end
  end
end

function RoleManager:GetDefaultHeadBackGroundID()
  local headBackGroundIns = ConfigManager:GetConfigInsByName("PlayerBackground")
  local allCfgDic = headBackGroundIns:GetAll()
  for _, v in pairs(allCfgDic) do
    if v.m_DefaultType == 1 then
      return v.m_CardBGID
    end
  end
end

function RoleManager:GetDefaultMainBackgroundID()
  local mainBackGroundIns = ConfigManager:GetConfigInsByName("MainBackground")
  local allCfgDic = mainBackGroundIns:GetAll()
  for i, v in pairs(allCfgDic) do
    if v.m_DefaultType == 1 then
      return v.m_BDID
    end
  end
end

function RoleManager:CheckUpdateHeadRedDotCount()
  if not self.m_headID then
    return
  end
  local redDotCount = 0
  local headIns = ConfigManager:GetConfigInsByName("PlayerHead")
  local allCfgDic = headIns:GetAll()
  for _, v in pairs(allCfgDic) do
    local isNewFlag = self:GetRoleHeadNewFlag(v.m_HeadID)
    if isNewFlag == true then
      redDotCount = redDotCount + 1
      break
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.PersonalCardHeadTab,
    count = redDotCount
  })
end

function RoleManager:CheckUpdateHeadFrameRedDotCount()
  if not self.m_headFrameID then
    return
  end
  local redDotCount = 0
  local headFrameIns = ConfigManager:GetConfigInsByName("PlayerHeadFrame")
  local allCfgDic = headFrameIns:GetAll()
  for _, v in pairs(allCfgDic) do
    local isNewFlag = self:GetRoleHeadFrameNewFlag(v.m_HeadFrameID)
    if isNewFlag == true then
      redDotCount = redDotCount + 1
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.PersonalCardHeadFrameTab,
    count = redDotCount
  })
end

function RoleManager:CheckUpdateMainBackgroundRedDotCount()
  if not self.m_headID then
    return
  end
  local redDotCount = 0
  if UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Decorate) then
    local mainBackgroundIns = ConfigManager:GetConfigInsByName("MainBackground")
    local allCfgDic = mainBackgroundIns:GetAll()
    for _, v in pairs(allCfgDic) do
      local isNewFlag = self:GetRoleMainBackgroundNewFlag(v.m_BDID)
      if isNewFlag == true then
        redDotCount = redDotCount + 1
        break
      end
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.HallDecorateActTab,
    count = redDotCount
  })
end

function RoleManager:CheckFreshHallDecorateFirstEnterRedDotCount()
  local redDotCount = 0
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Decorate)
  if openFlag and ClientDataManager then
    local firstEnterFlag = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.HallDecorate)
    if firstEnterFlag == nil or firstEnterFlag == "" then
      redDotCount = redDotCount + 1
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.HallDecorateFirstEnter,
    count = redDotCount
  })
end

function RoleManager:IsMainBgIsAllEmpty(mainBgDataList)
  if not mainBgDataList then
    return true
  end
  if not next(mainBgDataList) then
    return true
  end
  local isAllEmpty = true
  for i, v in pairs(mainBgDataList) do
    if v.iType ~= RoleManager.MainBgType.Empty and v.iId ~= 0 then
      isAllEmpty = false
      break
    end
  end
  return isAllEmpty
end

function RoleManager:FreshMainBGDataList(mainBgDataList)
  mainBgDataList = mainBgDataList or {}
  local isAllEmpty = self:IsMainBgIsAllEmpty(mainBgDataList)
  if isAllEmpty then
    mainBgDataList[DefaultMainBgIndex] = {
      iType = RoleManager.MainBgType.Activity,
      iId = self:GetDefaultMainBackgroundID()
    }
  end
  self.m_mainBGDataList = mainBgDataList
end

function RoleManager:InitRole(initRoleSerData)
  if not initRoleSerData then
    return
  end
  self.m_uid = initRoleSerData.iUid
  self.m_name = initRoleSerData.sName
  self.m_level = initRoleSerData.iLevel
  self.m_iAllianceId = initRoleSerData.iAllianceId
  self.m_sAllianceName = initRoleSerData.sAllianceName
  self.m_iAllianceLevel = initRoleSerData.iAllianceLevel
  self.m_iTotalRecharge = initRoleSerData.iTotalRecharge
  self.m_sLoginRoleCountry = initRoleSerData.sLoginRoleCountry
  self.m_sCreateRoleCountry = initRoleSerData.sCreateRoleCountry
  self.m_bNewRole = initRoleSerData.bNewRole
  self.iRoleRegTime = initRoleSerData.iRoleRegTime
  self.m_headID = initRoleSerData.iHeadId
  self.m_headFrameID = initRoleSerData.iHeadFrameId
  self.m_headFrameExpireTime = initRoleSerData.iHeadFrameExpireTime
  self.m_headBackgroundID = initRoleSerData.iShowBackgroundId
  self.m_mainBGIndex = initRoleSerData.iMainBackgroundIndex
  self.m_mainBGDataList = initRoleSerData.vMainBackground
  self.m_mABTest = initRoleSerData.mABTest
  self:broadcastEvent("eGameEvent_Login_SetRegisterRedDot")
  if initRoleSerData.bHasEvlaMessage then
    SettingManager:OnCheckAiHelpMessageRedDot(1)
  end
end

function RoleManager:GetUID()
  return self.m_uid
end

function RoleManager:GetName()
  return self.m_name
end

function RoleManager:GetNewRole()
  return true
end

function RoleManager:GetRoleRegTime()
  return self.iRoleRegTime or 0
end

function RoleManager:GetTotalRecharge()
  return self.m_iTotalRecharge
end

function RoleManager:GetLoginRoleCountry()
  return self.m_sLoginRoleCountry
end

function RoleManager:GetCreateRoleCountry()
  return self.m_sCreateRoleCountry
end

function RoleManager:SetName(name)
  self.m_name = name
end

function RoleManager:GetLevel()
  return self.m_level
end

function RoleManager:GetOldLevel()
  return self.m_oldPlayerLv
end

function RoleManager:ClearOldLevel()
  self.m_oldPlayerLv = nil
end

function RoleManager:CacheCurLevelAndExpAsOld()
  self.m_oldPlayerLv = self.m_level
  self.m_oldPlayerExp = self:GetRoleExp()
end

function RoleManager:GetRoleExp()
  if not ItemManager then
    return
  end
  return ItemManager:GetItemNum(GlobalConfig.ROLE_EXP_ITEM_ID)
end

function RoleManager:GetOldRoleExp()
  return self.m_oldPlayerExp
end

function RoleManager:ClearOldRoleExp()
  self.m_oldPlayerExp = nil
end

function RoleManager:GetRoleMaxExpNum(roleLV)
  if not roleLV then
    return
  end
  local AccountLevelIns = ConfigManager:GetConfigInsByName("AccountLevel")
  local accountLevelCfg = AccountLevelIns:GetValue_ByAccountLv(roleLV)
  if accountLevelCfg:GetError() then
    return
  end
  return accountLevelCfg.m_AccountlvupEXP
end

function RoleManager:SetRoleAllianceInfo(stData)
  self.m_iAllianceId = stData.iAllianceId
  self.m_iAllianceLevel = stData.iLevel
  self.m_sAllianceName = stData.sName
end

function RoleManager:GetRoleAllianceInfo()
  return self.m_iAllianceId, self.m_iAllianceLevel
end

function RoleManager:GetAllianceName()
  if self.m_sAllianceName and self.m_sAllianceName ~= "" then
    return self.m_sAllianceName
  elseif (self.m_sAllianceName == nil or self.m_sAllianceName == "") and ConfigManager then
    return ConfigManager:GetCommonTextById(20111) or ""
  else
    return ""
  end
end

function RoleManager:CheckLoginAiHelpMessageRedPoint()
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.LoginCustomerService,
    count = 2
  })
end

function RoleManager:GetHeadID()
  if self.m_headID == nil or self.m_headID == 0 then
    return self:GetDefaultHeadID()
  end
  return self.m_headID
end

function RoleManager:GetHeadFrameID()
  if self.m_headFrameID == nil or self.m_headFrameID == 0 then
    return self:GetDefaultHeadFrameID()
  end
  if self.m_headFrameExpireTime ~= nil and self.m_headFrameExpireTime ~= 0 then
    local curServerTime = TimeUtil:GetServerTimeS()
    if curServerTime >= self.m_headFrameExpireTime then
      return self:GetDefaultHeadFrameID()
    end
  end
  return self.m_headFrameID
end

function RoleManager:GetHeadFrameExpireTime()
  return self.m_headFrameExpireTime
end

function RoleManager:GetHeadFrameIDByIDAndExpireTime(headFrameID, expireTime)
  if headFrameID == nil or headFrameID == 0 then
    return self:GetDefaultHeadFrameID()
  end
  if expireTime ~= nil and expireTime ~= 0 then
    local curServerTime = TimeUtil:GetServerTimeS()
    if expireTime <= curServerTime then
      return self:GetDefaultHeadFrameID()
    end
  end
  return headFrameID
end

function RoleManager:GetHeadBackGroundID()
  if self.m_headBackgroundID == nil or self.m_headBackgroundID == 0 then
    return self:GetDefaultHeadBackGroundID()
  end
  return self.m_headBackgroundID
end

function RoleManager:GetPlayerHeadCfg(headID)
  if not headID then
    return
  end
  local tempCfg
  if self.m_headCfgDic[headID] then
    tempCfg = self.m_headCfgDic[headID]
  else
    local headIns = ConfigManager:GetConfigInsByName("PlayerHead")
    local tempHeadCfg = headIns:GetValue_ByHeadID(headID)
    if tempHeadCfg:GetError() ~= true then
      tempCfg = tempHeadCfg
      self.m_headCfgDic[headID] = tempCfg
    end
  end
  return tempCfg
end

function RoleManager:IsHeadFrameHideByChannel(headFrameId)
  if not headFrameId then
    return true
  end
  local frameCfg = self:GetPlayerHeadFrameCfg(headFrameId)
  if frameCfg then
    if ChannelManager:IsUsingQSDK() then
      if frameCfg.m_QucikChannelCode and frameCfg.m_QucikChannelCode ~= 0 and tostring(frameCfg.m_QucikChannelCode) ~= tostring(QSDKManager:GetChannelType()) then
        return true
      end
    elseif frameCfg.m_QucikChannelCode and frameCfg.m_QucikChannelCode ~= 0 then
      return true
    end
  end
  return false
end

function RoleManager:GetPlayerHeadHideTypeValue(playerHeadID, configHideTypeValue)
  if not playerHeadID then
    return configHideTypeValue
  end
  local activityCom = ActivityManager:GetActivityByType(MTTD.ActivityType_UpTimeManager)
  if not activityCom then
    return configHideTypeValue
  end
  local isMatch, serverValue = activityCom:GetPlayerHeadHideStatusByID(playerHeadID)
  if isMatch == true then
    configHideTypeValue = serverValue
  end
  return configHideTypeValue
end

function RoleManager:IsPlayerHeadHide(playerHeadCfg)
  if not playerHeadCfg then
    return
  end
  local hideType = self:GetPlayerHeadHideTypeValue(playerHeadCfg.m_HeadID, playerHeadCfg.m_HideType)
  if hideType == 1 then
    return true
  end
  if ActivityManager:IsInCensorOpen() == true then
    local censorHideType = playerHeadCfg.m_CensorHideType
    if censorHideType == 1 then
      return true
    end
  end
  return false
end

function RoleManager:GetPlayerHeadFrameCfg(headFrameID)
  if not headFrameID then
    return
  end
  local tempCfg
  if self.m_headFrameCfgDic[headFrameID] then
    tempCfg = self.m_headFrameCfgDic[headFrameID]
  else
    local headFrameIns = ConfigManager:GetConfigInsByName("PlayerHeadFrame")
    local tempFrameCfg = headFrameIns:GetValue_ByHeadFrameID(headFrameID)
    if tempFrameCfg:GetError() ~= true then
      tempCfg = tempFrameCfg
      self.m_headFrameCfgDic[headFrameID] = tempCfg
    end
  end
  return tempCfg
end

function RoleManager:GetPlayerHeadFrameHideTypeValue(playerHeadFrameID, configHideTypeValue)
  if not playerHeadFrameID then
    return configHideTypeValue
  end
  local activityCom = ActivityManager:GetActivityByType(MTTD.ActivityType_UpTimeManager)
  if not activityCom then
    return configHideTypeValue
  end
  local isMatch, serverValue = activityCom:GetHeadFrameStatusByID(playerHeadFrameID)
  if isMatch == true then
    configHideTypeValue = serverValue
  end
  return configHideTypeValue
end

function RoleManager:GetPlayerBackgroundCfg(backgroundID)
  if not backgroundID then
    return
  end
  local tempCfg
  if self.m_playerBackgroundCfgDic[backgroundID] then
    tempCfg = self.m_playerBackgroundCfgDic[backgroundID]
  else
    local headBackgroundIns = ConfigManager:GetConfigInsByName("PlayerBackground")
    local tempBackgroundCfg = headBackgroundIns:GetValue_ByHeadFrameID(backgroundID)
    if tempBackgroundCfg:GetError() ~= true then
      tempCfg = tempBackgroundCfg
      self.m_playerBackgroundCfgDic[backgroundID] = tempCfg
    end
  end
  return tempCfg
end

function RoleManager:GetMainBackgroundCfg(mainBackgroundID)
  if not mainBackgroundID then
    return
  end
  local tempCfg
  if self.m_mainBGCfgDic[mainBackgroundID] then
    tempCfg = self.m_mainBGCfgDic[mainBackgroundID]
  else
    local mainBackgroundIns = ConfigManager:GetConfigInsByName("MainBackground")
    local tempMainBackgroundCfg = mainBackgroundIns:GetValue_ByBDID(mainBackgroundID)
    if tempMainBackgroundCfg:GetError() ~= true then
      tempCfg = tempMainBackgroundCfg
      self.m_mainBGCfgDic[mainBackgroundID] = tempCfg
    end
  end
  return tempCfg
end

function RoleManager:GetMainBackgroundHideTypeValue(mainBackgroundID, configHideTypeValue)
  if not mainBackgroundID then
    return configHideTypeValue
  end
  local activityCom = ActivityManager:GetActivityByType(MTTD.ActivityType_UpTimeManager)
  if not activityCom then
    return configHideTypeValue
  end
  local isMatch, serverValue = activityCom:GetBackgroundHideStatusByID(mainBackgroundID)
  if isMatch == true then
    configHideTypeValue = serverValue
  end
  return configHideTypeValue
end

function RoleManager:SetAllRoleHeadNewFlag()
  local headIns = ConfigManager:GetConfigInsByName("PlayerHead")
  local allCfgDic = headIns:GetAll()
  for _, v in pairs(allCfgDic) do
    local headID = v.m_HeadID
    local isNewFlag = self:GetRoleHeadNewFlag(headID)
    if isNewFlag == true then
      self:SetRoleHeadNewFlag(headID, -1, true)
    end
  end
  self:CheckUpdateHeadRedDotCount()
end

function RoleManager:SetRoleHeadNewFlag(headID, flagNum, isNotFreshRedDot)
  if not headID then
    return
  end
  local keyStr = "RoleHead_" .. headID
  LocalDataManager:SetIntSimple(keyStr, flagNum, true)
  if isNotFreshRedDot ~= true then
    self:CheckUpdateHeadRedDotCount()
  end
end

function RoleManager:GetRoleHeadNewFlag(headID)
  if not headID then
    return
  end
  local keyStr = "RoleHead_" .. headID
  local newFlagNum = LocalDataManager:GetIntSimple(keyStr, -1)
  return newFlagNum == 1
end

function RoleManager:SetAllRoleHeadFrameNewFlag()
  local headFrameIns = ConfigManager:GetConfigInsByName("PlayerHeadFrame")
  local allCfgDic = headFrameIns:GetAll()
  for _, v in pairs(allCfgDic) do
    local headFrameID = v.m_HeadFrameID
    local isNewFlag = self:GetRoleHeadFrameNewFlag(headFrameID)
    if isNewFlag == true then
      self:SetRoleHeadFrameNewFlag(headFrameID, -1, true)
    end
  end
  self:CheckUpdateHeadFrameRedDotCount()
end

function RoleManager:SetRoleHeadFrameNewFlag(headID, flagNum, isNotFreshRedDot)
  if not headID then
    return
  end
  local keyStr = "RoleHeadFrame_" .. headID
  LocalDataManager:SetIntSimple(keyStr, flagNum, true)
  if isNotFreshRedDot ~= true then
    self:CheckUpdateHeadFrameRedDotCount()
  end
end

function RoleManager:GetRoleHeadBackgroundNewFlag(headBackGroundID)
  if not headBackGroundID then
    return
  end
  local keyStr = "RoleHeadBackGround_" .. headBackGroundID
  local newFlagNum = LocalDataManager:GetIntSimple(keyStr, -1)
  return newFlagNum == 1
end

function RoleManager:SetRoleHeadBackgroundNewFlag(headBackGroundID, flagNum)
  if not headBackGroundID then
    return
  end
  local keyStr = "RoleHeadBackGround_" .. headBackGroundID
  LocalDataManager:SetIntSimple(keyStr, flagNum, true)
end

function RoleManager:GetRoleHeadFrameNewFlag(headFrameID)
  if not headFrameID then
    return
  end
  local itemNum = ItemManager:GetItemNum(headFrameID)
  if itemNum <= 0 then
    return false
  end
  local keyStr = "RoleHeadFrame_" .. headFrameID
  local newFlagNum = LocalDataManager:GetIntSimple(keyStr, -1)
  return newFlagNum == 1
end

function RoleManager:SetRoleMainBackgroundNewFlag(id, flagNum)
  if not id then
    return
  end
  local keyStr = "RoleMainBg_" .. id
  LocalDataManager:SetIntSimple(keyStr, flagNum, true)
  self:CheckUpdateMainBackgroundRedDotCount()
end

function RoleManager:GetRoleMainBackgroundNewFlag(id)
  if not id then
    return
  end
  local keyStr = "RoleMainBg_" .. id
  local newFlagNum = LocalDataManager:GetIntSimple(keyStr, -1)
  return newFlagNum == 1
end

function RoleManager:GetMainBackGroundIndex()
  if self.m_mainBGIndex == nil or self.m_mainBGIndex == 0 then
    self.m_mainBGIndex = DefaultMainBgIndex
  end
  return self.m_mainBGIndex
end

function RoleManager:GetMainBackGroundDataList()
  return self.m_mainBGDataList
end

function RoleManager:ReqGetUserToken(url)
  if not url then
    log.error("Web Act Url Error")
    return
  end
  local getUserTokenMsg = MTTDProto.Cmd_Role_GetUserToken_CS()
  getUserTokenMsg.iTokenType = 1
  RPCS():Role_GetUserToken(getUserTokenMsg, function(sc, msg)
    if sc and sc.sUserToken then
      local langId = CS.MultiLanguageManager.g_iLanguageID
      langId = CS.MultiLanguageManager.Instance:GetLanIDById(langId)
      local uid = self:GetUID()
      local zone = UserDataManager:GetZoneID()
      local param = string.format("auth=promo&usrtoken=%s&clientlang=%s&roleid=%s&zoneid=%s", sc.sUserToken, langId, uid, zone)
      local base64 = UILuaHelper.EncodeBase64(param)
      local separator
      if url:find("?") then
        separator = "&"
      else
        separator = "?"
      end
      local actUrl = string.format("%s%sclientparams=%s", url, separator, base64)
      CS.DeviceUtil.OpenURLNew(actUrl)
      log.info("Web Act Url:" .. actUrl)
    end
  end)
end

function RoleManager:GetMinePlayerInfoTab()
  local stRoleId = {
    iZoneId = UserDataManager:GetZoneID(),
    iUid = self:GetUID()
  }
  local iHeadId = self:GetHeadID()
  local iHeadFrameId = self:GetHeadFrameID()
  local iHeadFrameExpireTime = self:GetHeadFrameExpireTime()
  local iLevel = self:GetLevel()
  return {
    iHeadId = iHeadId,
    iHeadFrameId = iHeadFrameId,
    iHeadFrameExpireTime = iHeadFrameExpireTime,
    iLevel = iLevel,
    stRoleId = stRoleId
  }
end

function RoleManager:CheckSetFirstEnterHallDecorate()
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Decorate)
  if openFlag and ClientDataManager then
    local firstEnterFlag = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.HallDecorate)
    if firstEnterFlag == nil or firstEnterFlag == "" then
      ClientDataManager:SetClientValue(ClientDataManager.ClientKeyType.HallDecorate, "1")
      self:CheckFreshHallDecorateFirstEnterRedDotCount()
    end
  end
end

function RoleManager:GetABTestDownloadAllResourceNewbie()
  local iABTest = self.m_mABTest[1] or 3
  if iABTest == 1 then
    iABTest = 3
  end
  return iABTest
end

return RoleManager
