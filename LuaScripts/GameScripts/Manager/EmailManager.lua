local BaseManager = require("Manager/Base/BaseManager")
local EmailManager = class("EmailManager", BaseManager)
local CData_MailTemplateInstance = CS.CData_MailTemplate.GetInstance()
local CData_GlobalSettingsInstance = CS.CData_GlobalSettings.GetInstance()
local pairs = _ENV.pairs
local ipairs = _ENV.ipairs
local tostring = _ENV.tostring

function EmailManager:OnCreate()
  self.m_mailList = nil
  self.m_collectMailList = nil
  self.m_isHaveNewMail = nil
  self:AddEventListener()
end

function EmailManager:OnInitNetwork()
  RPCS():Listen_Push_NewMailNotify(handler(self, self.OnPushNewMailItem), "EmailManager")
end

function EmailManager:OnUpdate(dt)
end

function EmailManager:OnInitMustRequestInFetchMore()
  local mailGetListCSMsg = MTTDProto.Cmd_Mail_GetMail_CS()
  RPCS():Mail_GetMail(mailGetListCSMsg, handler(self, self.OnEMailGetListSC))
end

function EmailManager:AddEventListener()
  self:addEventListener("eGameEvent_UnlockSystem", handler(self, self.OnUnlockSystem))
end

function EmailManager:OnUnlockSystem(param)
  if not param then
    return
  end
  for i, v in ipairs(param) do
    if v == GlobalConfig.SYSTEM_ID.Mail then
      self:CheckUpdateEmailEntryRedDotCount()
      self:CheckUpdateCollectEmailEntryRedDotCount()
    end
  end
end

function EmailManager:OnEMailGetListSC(stEmailListData, msg)
  log.info("EmailManager OnEMailGetListSC stEmailListData: ", tostring(stEmailListData))
  self.m_mailList = {}
  local mailDataList = stEmailListData.vMail
  for _, v in pairs(mailDataList) do
    if v then
      local templateConfigData
      local templateCfg = CData_MailTemplateInstance:GetValue_ByMailTemplateID(v.iTemplateId)
      if not templateCfg:GetError() then
        templateConfigData = templateCfg
      end
      local emailItem = {serverData = v, templateConfigData = templateConfigData}
      self.m_mailList[#self.m_mailList + 1] = emailItem
    end
  end
  self.m_collectMailList = {}
  local collectMailList = stEmailListData.vCollectMail
  for _, v in pairs(collectMailList) do
    if v then
      local templateConfigData
      local templateCfg = CData_MailTemplateInstance:GetValue_ByMailTemplateID(v.iTemplateId)
      if not templateCfg:GetError() then
        templateConfigData = templateCfg
      end
      local emailItem = {serverData = v, templateConfigData = templateConfigData}
      self.m_collectMailList[#self.m_collectMailList + 1] = emailItem
    end
  end
  self:CheckUpdateEmailEntryRedDotCount()
  self:CheckUpdateCollectEmailEntryRedDotCount()
  self:CheckUpdateEmailHaveRecRedDotCount()
end

function EmailManager:OnPushNewMailItem(stMailData, msg)
  self.m_isHaveNewMail = true
  self:CheckUpdateEmailEntryRedDotCount()
end

function EmailManager:ReqReadMail(mailID)
  if not mailID then
    return
  end
  local readMailMsg = MTTDProto.Cmd_Mail_ReadMail_CS()
  readMailMsg.iMailId = mailID
  RPCS():Mail_ReadMail(readMailMsg, handler(self, self.OnEmailReadSC))
end

function EmailManager:OnEmailReadSC(stReadEmailData, msg)
  local emailID = stReadEmailData.iMailId
  local cacheEmailData = self:GetEmailDataByID(emailID)
  if not cacheEmailData then
    return
  end
  cacheEmailData.serverData.iOpenTime = stReadEmailData.iOpenTime
  cacheEmailData.serverData.iDelTime = stReadEmailData.iDelTime
  self:broadcastEvent("eGameEvent_Email_ReadEmail", emailID)
  self:CheckUpdateEmailEntryRedDotCount()
end

function EmailManager:ReqDelMail(mailID)
  if not mailID then
    return
  end
  local reqMsg = MTTDProto.Cmd_Mail_DelMail_CS()
  local mailIDList = {
    [1] = mailID
  }
  reqMsg.vMailId = mailIDList
  RPCS():Mail_DelMail(reqMsg, handler(self, self.OnEmailDelSC))
end

function EmailManager:OnEmailDelSC(stDelMailData, msg)
  local delEmailIDList = stDelMailData.vMailId
  for i, v in pairs(delEmailIDList) do
    if v then
      self:DelEmailByID(v)
    end
  end
  self:broadcastEvent("eGameEvent_Email_DelEmail", delEmailIDList)
  self:CheckUpdateEmailEntryRedDotCount()
  self:CheckUpdateCollectEmailEntryRedDotCount()
  self:CheckUpdateEmailHaveRecRedDotCount()
end

function EmailManager:ReqDelAllRcvMail()
  local reqMsg = MTTDProto.Cmd_Mail_DelAllRcvMail_CS()
  RPCS():Mail_DelAllRcvMail(reqMsg, handler(self, self.OnEMailDelAllRcvMailSC))
end

function EmailManager:OnEMailDelAllRcvMailSC(stDelAllRcvMailData, msg)
  local delEmailIDList = stDelAllRcvMailData.vMailId
  for _, v in pairs(delEmailIDList) do
    if v then
      self:DelEmailByID(v)
    end
  end
  self:broadcastEvent("eGameEvent_Email_DelEmail", delEmailIDList)
end

function EmailManager:ReqRcvMailAttach(emailID)
  if not emailID then
    return
  end
  local reqMsg = MTTDProto.Cmd_Mail_RcvMailAttach_CS()
  reqMsg.iMailId = emailID
  RPCS():Mail_RcvMailAttach(reqMsg, handler(self, self.OnRcvEmailAttachSC))
end

function EmailManager:OnRcvEmailAttachSC(stRcvMailAttachData, msg)
  local emailID = stRcvMailAttachData.iMailId
  local isDel = stRcvMailAttachData.bDel
  local rewardList = stRcvMailAttachData.vReward
  local isCollect = stRcvMailAttachData.bCollect
  if isCollect then
    local mailData = self:GetEmailDataByID(emailID)
    if mailData then
      mailData.serverData.iRcvAttachTime = stRcvMailAttachData.iRcvAttachTime
      mailData.serverData.iOpenTime = stRcvMailAttachData.iOpenTime
      mailData.serverData.iDelTime = stRcvMailAttachData.iDelTime
    end
    self:DelEmailByID(emailID)
    self:AddCollectEmailData(mailData)
    self:broadcastEvent("eGameEvent_Email_DelEmail", {emailID})
  elseif isDel then
    self:DelEmailByID(emailID)
    self:broadcastEvent("eGameEvent_Email_DelEmail", {emailID})
  else
    local mailData = self:GetEmailDataByID(emailID)
    if mailData then
      mailData.serverData.iRcvAttachTime = stRcvMailAttachData.iRcvAttachTime
      mailData.serverData.iOpenTime = stRcvMailAttachData.iOpenTime
      mailData.serverData.iDelTime = stRcvMailAttachData.iDelTime
      self:broadcastEvent("eGameEvent_Email_AttachEmail", emailID)
    end
  end
  if rewardList and next(rewardList) then
    utils.popUpRewardUI(rewardList, function()
      if isCollect then
        self:broadcastEvent("eGameEvent_Email_AddCollectEmail_ShowRewardBack")
      end
    end)
  end
  self:CheckUpdateEmailEntryRedDotCount()
  self:CheckUpdateCollectEmailEntryRedDotCount()
  self:CheckUpdateEmailHaveRecRedDotCount()
end

function EmailManager:ReqRcvAllMailAttach()
  local reqMsg = MTTDProto.Cmd_Mail_RcvAllMailAttach_CS()
  RPCS():Mail_RcvAllMailAttach(reqMsg, handler(self, self.OnRcvAllMailAttachSC))
end

function EmailManager:OnRcvAllMailAttachSC(stRcvAllMailAttachData, msg)
  local showRewardItemList = {}
  local rcvMailDataList = stRcvAllMailAttachData.vMail
  if rcvMailDataList and next(rcvMailDataList) then
    for _, v in pairs(rcvMailDataList) do
      self:UpdateEmailData(v)
      if v.vItems and next(v.vItems) then
        for _, rewardItem in ipairs(v.vItems) do
          showRewardItemList[#showRewardItemList + 1] = rewardItem
        end
      end
    end
  end
  local isAddCollectEmail = false
  local isDelMail = false
  local delOrCollectEmailIDList = {}
  local collectIDList = stRcvAllMailAttachData.vCollectId
  if collectIDList and next(collectIDList) then
    for _, mailID in pairs(collectIDList) do
      local mailData = self:GetEmailDataByID(mailID)
      self:AddCollectEmailData(mailData)
      self:DelEmailByID(mailID)
      delOrCollectEmailIDList[#delOrCollectEmailIDList + 1] = mailID
      isAddCollectEmail = true
    end
    isDelMail = true
  end
  local delMailIDList = stRcvAllMailAttachData.vDelMailId
  if delMailIDList and next(delMailIDList) then
    for _, mailID in pairs(delMailIDList) do
      self:DelEmailByID(mailID)
      delOrCollectEmailIDList[#delOrCollectEmailIDList + 1] = mailID
    end
    isDelMail = true
  end
  if isDelMail then
    self:broadcastEvent("eGameEvent_Email_DelEmail", delOrCollectEmailIDList)
  else
    self:broadcastEvent("eGameEvent_Email_AttachEmail")
  end
  if next(showRewardItemList) then
    utils.popUpRewardUI(showRewardItemList, function()
      if isAddCollectEmail then
        self:broadcastEvent("eGameEvent_Email_AddCollectEmail_ShowRewardBack")
      end
    end)
  end
  self:CheckUpdateEmailEntryRedDotCount()
  self:CheckUpdateCollectEmailEntryRedDotCount()
  self:CheckUpdateEmailHaveRecRedDotCount()
end

function EmailManager:ReqGetNewMail()
  if not self.m_isHaveNewMail then
    return
  end
  local reqMsg = MTTDProto.Cmd_Mail_GetNewMail_CS()
  RPCS():Mail_GetNewMail(reqMsg, handler(self, self.OnGetNewMailSC))
end

function EmailManager:OnGetNewMailSC(stNewMailData, msg)
  local newMailDataList = stNewMailData.vMail
  if newMailDataList and next(newMailDataList) then
    for _, v in pairs(newMailDataList) do
      self:UpdateEmailData(v)
    end
    self:CheckEmailNumberOverLimit()
  end
  self.m_isHaveNewMail = false
  self:broadcastEvent("eGameEvent_Email_GetNewEmail")
  self:CheckUpdateEmailEntryRedDotCount()
  self:CheckUpdateCollectEmailEntryRedDotCount()
  self:CheckUpdateEmailHaveRecRedDotCount()
end

function EmailManager:ReqDelCollectMail(mailID)
  if not mailID then
    return
  end
  local reqMsg = MTTDProto.Cmd_Mail_DelCollectMail_CS()
  reqMsg.iMailId = mailID
  RPCS():Mail_DelCollectMail(reqMsg, handler(self, self.OnDelCollectMailSC))
end

function EmailManager:OnDelCollectMailSC(stDelCollectMailData, msg)
  if not stDelCollectMailData then
    return
  end
  local mailID = stDelCollectMailData.iMailId
  if not mailID then
    return
  end
  self:DelCollectEmailByID(mailID)
  self:broadcastEvent("eGameEvent_Email_DelCollectEmail", {mailID})
end

function EmailManager:GetEmailDataByID(emailID)
  if not emailID then
    return
  end
  for _, v in ipairs(self.m_mailList) do
    if v and v.serverData.iMailId == emailID then
      return v
    end
  end
end

function EmailManager:DelEmailByID(emailID)
  if not emailID then
    return
  end
  if not self.m_mailList then
    return
  end
  for i, v in ipairs(self.m_mailList) do
    if v and v.serverData.iMailId == emailID then
      table.remove(self.m_mailList, i)
    end
  end
end

function EmailManager:UpdateEmailData(emailServerData)
  if not emailServerData then
    return
  end
  if not self.m_mailList then
    return
  end
  local isMatch = false
  local tempEmailID = emailServerData.iMailId
  for _, v in ipairs(self.m_mailList) do
    if v and v.serverData.iMailId == tempEmailID then
      v.serverData.iRcvAttachTime = emailServerData.iRcvAttachTime
      v.serverData.iOpenTime = emailServerData.iOpenTime
      v.serverData.iDelTime = emailServerData.iDelTime
      isMatch = true
    end
  end
  if isMatch == false then
    local templateConfigData
    local templateCfg = CData_MailTemplateInstance:GetValue_ByMailTemplateID(emailServerData.iTemplateId)
    if not templateCfg:GetError() then
      templateConfigData = templateCfg
    end
    local emailItem = {serverData = emailServerData, templateConfigData = templateConfigData}
    self.m_mailList[#self.m_mailList + 1] = emailItem
  end
end

function EmailManager:GetCollectEmailDataByID(emailID)
  if not emailID then
    return
  end
  if not self.m_collectMailList then
    return
  end
  for _, v in ipairs(self.m_collectMailList) do
    if v and v.serverData.iMailId == emailID then
      return v
    end
  end
end

function EmailManager:DelCollectEmailByID(emailID)
  if not emailID then
    return
  end
  if not self.m_collectMailList then
    return
  end
  for i, v in ipairs(self.m_collectMailList) do
    if v and v.serverData.iMailId == emailID then
      table.remove(self.m_collectMailList, i)
    end
  end
end

function EmailManager:AddCollectEmailData(mailData)
  if not mailData then
    return
  end
  local isMatch = false
  local tempEmailID = mailData.serverData.iMailId
  for _, v in ipairs(self.m_collectMailList) do
    if v and v.serverData.iMailId == tempEmailID then
      v.serverData.iRcvAttachTime = mailData.serverData.iRcvAttachTime
      v.serverData.iOpenTime = mailData.serverData.iOpenTime
      v.serverData.iDelTime = mailData.serverData.iDelTime
      isMatch = true
    end
  end
  if not isMatch then
    self.m_collectMailList[#self.m_collectMailList + 1] = mailData
    self:CheckCollectEmailNumberOverLimit()
  end
end

function EmailManager:CheckEmailNumberOverLimit()
  if not self.m_mailList then
    return
  end
  local mailCntLimitCfgData = CData_GlobalSettingsInstance:GetValue_ByName("MailCntLimit")
  local limitNum = tonumber(mailCntLimitCfgData.m_Value)
  local totalMailNum = #self.m_mailList
  if limitNum < totalMailNum then
    table.sort(self.m_mailList, function(a, b)
      if a.serverData.iTime == b.serverData.iTime and a.serverData.iMailId and b.serverData.iMailId then
        return a.serverData.iMailId > b.serverData.iMailId
      else
        return a.serverData.iTime > b.serverData.iTime
      end
    end)
  end
  for i = totalMailNum, limitNum + 1, -1 do
    table.remove(self.m_mailList, i)
  end
end

function EmailManager:CheckCollectEmailNumberOverLimit()
  if not self.m_collectMailList then
    return
  end
  local mailCntLimitCfgData = CData_GlobalSettingsInstance:GetValue_ByName("CollectMailMaxNum")
  local limitNum = tonumber(mailCntLimitCfgData.m_Value)
  local totalMailNum = #self.m_collectMailList
  if limitNum < totalMailNum then
    table.sort(self.m_collectMailList, function(a, b)
      if a.serverData.iTime == b.serverData.iTime and a.serverData.iMailId and b.serverData.iMailId then
        return a.serverData.iMailId > b.serverData.iMailId
      else
        return a.serverData.iTime > b.serverData.iTime
      end
    end)
  end
  for i = totalMailNum, limitNum + 1, -1 do
    table.remove(self.m_collectMailList, i)
  end
end

function EmailManager:_IsCollectEmail(emailData)
  if not emailData then
    return
  end
  local serverData = emailData.serverData
  if not serverData then
    return
  end
  local templateCfg = emailData.templateConfigData or {}
  if templateCfg.m_TemplateMailType ~= nil and templateCfg.m_TemplateMailType ~= 0 then
    return true
  end
end

function EmailManager:_IsEmailItemCanRecOrReadByData(emailData)
  if not emailData then
    return
  end
  local serverData = emailData.serverData
  if not serverData then
    return
  end
  local attachmentItems = serverData.vItems
  local isCanRcv = false
  if attachmentItems and next(attachmentItems) and serverData.iRcvAttachTime == 0 then
    isCanRcv = true
  end
  local isCanRead = serverData.iOpenTime == 0
  return isCanRead or isCanRcv
end

function EmailManager:_IsEmailItemCanRecByData(emailData)
  if not emailData then
    return
  end
  local serverData = emailData.serverData
  if not serverData then
    return
  end
  local attachmentItems = serverData.vItems
  local isCanRcv = false
  if attachmentItems and next(attachmentItems) and serverData.iRcvAttachTime == 0 then
    isCanRcv = true
  end
  return isCanRcv
end

function EmailManager:GetAllEmailDataList()
  if not self.m_mailList or #self.m_mailList <= 0 then
    return
  end
  local curTime = TimeUtil:GetServerTimeS()
  local allDataNum = #self.m_mailList
  local isDelEmail = false
  for i = allDataNum, 1, -1 do
    local tempMailData = self.m_mailList[i]
    if tempMailData and tempMailData.serverData.iDelTime ~= 0 and curTime >= tempMailData.serverData.iDelTime then
      isDelEmail = true
      table.remove(self.m_mailList, i)
    end
  end
  table.sort(self.m_mailList, function(a, b)
    local isARead = a.serverData.iOpenTime ~= 0
    local isBRead = b.serverData.iOpenTime ~= 0
    if isARead ~= isBRead then
      return isBRead
    end
    if isARead == false then
      if a.serverData.bSticky ~= b.serverData.bSticky then
        return a.serverData.bSticky
      end
      if a.serverData.iTime == b.serverData.iTime and a.serverData.iMailId and b.serverData.iMailId then
        return a.serverData.iMailId > b.serverData.iMailId
      else
        return a.serverData.iTime > b.serverData.iTime
      end
    end
    if a.serverData.iTime == b.serverData.iTime and a.serverData.iMailId and b.serverData.iMailId then
      return a.serverData.iMailId > b.serverData.iMailId
    else
      return a.serverData.iTime > b.serverData.iTime
    end
  end)
  if isDelEmail then
    self:CheckUpdateEmailEntryRedDotCount()
    self:CheckUpdateCollectEmailEntryRedDotCount()
    self:CheckUpdateEmailHaveRecRedDotCount()
  end
  return self.m_mailList
end

function EmailManager:GetAllCollectEmailList()
  if not self.m_collectMailList or #self.m_collectMailList <= 0 then
    return
  end
  local curTime = TimeUtil:GetServerTimeS()
  local allDataNum = #self.m_collectMailList
  local isDelEmail = false
  for i = allDataNum, 1, -1 do
    local tempMailData = self.m_collectMailList[i]
    if tempMailData and tempMailData.serverData.iDelTime ~= 0 and curTime >= tempMailData.serverData.iDelTime then
      isDelEmail = true
      table.remove(self.m_collectMailList, i)
    end
  end
  table.sort(self.m_collectMailList, function(a, b)
    local isARead = a.serverData.iOpenTime ~= 0
    local isBRead = b.serverData.iOpenTime ~= 0
    if isARead ~= isBRead then
      return isBRead
    end
    if isARead == false then
      if a.serverData.bSticky ~= b.serverData.bSticky then
        return a.serverData.bSticky
      end
      if a.serverData.iTime == b.serverData.iTime and a.serverData.iMailId and b.serverData.iMailId then
        return a.serverData.iMailId > b.serverData.iMailId
      else
        return a.serverData.iTime > b.serverData.iTime
      end
    end
    if a.serverData.iTime == b.serverData.iTime and a.serverData.iMailId and b.serverData.iMailId then
      return a.serverData.iMailId > b.serverData.iMailId
    else
      return a.serverData.iTime > b.serverData.iTime
    end
  end)
  return self.m_collectMailList
end

function EmailManager:GetIsHaveNewMail()
  return self.m_isHaveNewMail
end

function EmailManager:IsEmailItemCanRecOrRead(mailID)
  if not mailID then
    return
  end
  local emailData = self:GetEmailDataByID(mailID)
  if not emailData then
    return
  end
  return self:_IsEmailItemCanRecOrReadByData(emailData) and 1 or 0
end

function EmailManager:IsEmailItemCanRec(mailID)
  if not mailID then
    return
  end
  local emailData = self:GetEmailDataByID(mailID)
  if not emailData then
    return
  end
  return self:_IsEmailItemCanRecByData(emailData) and 1 or 0
end

function EmailManager:CheckUpdateEmailEntryRedDotCount()
  if not self.m_mailList then
    return
  end
  local redDotCount = 0
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Mail)
  if isOpen then
    for _, mailData in ipairs(self.m_mailList) do
      if self:_IsEmailItemCanRecOrReadByData(mailData) == true then
        redDotCount = redDotCount + 1
      end
    end
    if self.m_isHaveNewMail then
      redDotCount = redDotCount + 1
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.MailEntry,
    count = redDotCount
  })
end

function EmailManager:CheckUpdateCollectEmailEntryRedDotCount()
  if not self.m_mailList then
    return
  end
  local redDotCount = 0
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Mail)
  if isOpen then
    for _, mailData in ipairs(self.m_mailList) do
      if self:_IsCollectEmail(mailData) == true and self:_IsEmailItemCanRecOrReadByData(mailData) == true then
        redDotCount = redDotCount + 1
      end
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.CollectMailEntry,
    count = redDotCount
  })
end

function EmailManager:CheckUpdateEmailHaveRecRedDotCount()
  if not self.m_mailList then
    return
  end
  local redDotCount = 0
  for _, mailData in ipairs(self.m_mailList) do
    if self:_IsEmailItemCanRecByData(mailData) == true then
      redDotCount = redDotCount + 1
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.MailHaveRec,
    count = redDotCount
  })
end

function EmailManager:CheckGetParamStr(match, paramStr)
  if not match or not paramStr then
    return paramStr
  end
  if match == "iHeadFrameId" then
    local frameID = tonumber(paramStr)
    local frameCfg = RoleManager:GetPlayerHeadFrameCfg(frameID)
    if not frameCfg then
      return paramStr
    end
    return frameCfg.m_mHeadName
  elseif match == "AllianceBattleBoss" then
    local bossId = tonumber(paramStr)
    if not bossId then
      return paramStr
    end
    local cfg = GuildManager:GetGuildBattleBossCfgByID(bossId)
    if not cfg then
      return paramStr
    end
    return cfg.m_mName
  else
    return paramStr
  end
end

function EmailManager:ReplaceParamStrByServerDic(showStr, paramDic)
  local formatted = showStr:gsub("{(%a+)}", function(match)
    local paramStr = paramDic[match]
    if paramStr == nil then
      paramStr = match
    else
      paramStr = self:CheckGetParamStr(match, paramStr)
    end
    return tostring(paramStr)
  end)
  return formatted
end

return EmailManager
