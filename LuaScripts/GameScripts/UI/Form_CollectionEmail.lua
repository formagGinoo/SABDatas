local Form_CollectionEmail = class("Form_CollectionEmail", require("UI/UIFrames/Form_CollectionEmailUI"))
local ipairs = _ENV.ipairs
local next = _ENV.next
local defaultChooseIndex = 1
local MailLimitCount = 4
local MailFJLimitCount = 5

function Form_CollectionEmail:SetInitParam(param)
end

function Form_CollectionEmail:AfterInit()
  self.super.AfterInit(self)
  self.m_allShowEmailItemDataList = nil
  self.m_curChooseShowItemList = nil
  local initGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnEmailTabClick(itemIndex)
    end
  }
  self.m_luaEmailListInfinityGrid = self:CreateInfinityGrid(self.m_email_list_InfinityGrid, "Email/UIEmailCollectionItem", initGridData)
  local initFJGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnFjItemClk(itemIndex)
    end
  }
  self.m_luaFjListInfinityGrid = self:CreateInfinityGrid(self.m_fj_item_list_InfinityGrid, "Email/UIEmailFJItem", initFJGridData)
  self.m_curChooseIndex = nil
  self.m_email_list_scroll_rect = self.m_email_list:GetComponent("ScrollRect")
  self.m_fj_item_list_scroll_rect = self.m_fj_item_list:GetComponent("ScrollRect")
  self.m_textMeshProLink = self.m_txt.transform:GetComponent("TextMeshProLink")
  if self.m_textMeshProLink then
    self.m_textMeshProLink.UICamera = self:OwnerStack().Group:GetCamera()
  end
end

function Form_CollectionEmail:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:InitData()
  self:FreshUI()
end

function Form_CollectionEmail:OnInactive()
  self.super.OnInactive(self)
  self:ClearData()
  self:RemoveAllEventListeners()
end

function Form_CollectionEmail:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CollectionEmail:InitData()
  self:FreshAllShowEmailItemData()
end

function Form_CollectionEmail:ClearData()
  self.m_curChooseIndex = nil
end

function Form_CollectionEmail:FreshAllShowEmailItemData()
  local allEmailDataList = EmailManager:GetAllCollectEmailList()
  local showItemList = {}
  if allEmailDataList and next(allEmailDataList) then
    for _, v in ipairs(allEmailDataList) do
      if v then
        local tempData = {mailData = v, isChoose = false}
        showItemList[#showItemList + 1] = tempData
      end
    end
  end
  self.m_allShowEmailItemDataList = showItemList
  local chooseIndex = self.m_curChooseIndex or defaultChooseIndex
  if self.m_allShowEmailItemDataList[chooseIndex] then
    self.m_allShowEmailItemDataList[chooseIndex].isChoose = true
    self.m_curChooseIndex = chooseIndex
  end
end

function Form_CollectionEmail:GetFormatSendTimeStr(timer)
  if not timer then
    return
  end
  local fmt = "%Y-%m-%d  %H:%M"
  local t = os.date(fmt, timer)
  return t
end

function Form_CollectionEmail:SplitItemStrToArray(itemStr)
  local itemStrArray = string.split(itemStr, ";")
  local showItemList = {}
  for _, item in ipairs(itemStrArray) do
    if item then
      local itemIDNumArray = string.split(item, ",")
      local itemID = tonumber(itemIDNumArray[1])
      local itemNum = tonumber(itemIDNumArray[2])
      showItemList[#showItemList + 1] = {itemID = itemID, itemNum = itemNum}
    end
  end
  return showItemList
end

function Form_CollectionEmail:GetShowMailIndexByID(emailID)
  if not emailID then
    return
  end
  if not self.m_allShowEmailItemDataList then
    return
  end
  for i, v in ipairs(self.m_allShowEmailItemDataList) do
    if emailID == v.mailData.serverData.iMailId then
      return i
    end
  end
end

function Form_CollectionEmail:RemoveMailDataByID(emailID)
  if not emailID then
    return
  end
  for i, v in ipairs(self.m_allShowEmailItemDataList) do
    if v.mailData.serverData.iMailId == emailID then
      table.remove(self.m_allShowEmailItemDataList, i)
    end
  end
end

function Form_CollectionEmail:IsMailDataIsOverDelTime(mailData)
  if not mailData then
    return
  end
  local serverData = mailData.mailData.serverData
  if serverData and serverData.iDelTime ~= nil and serverData.iDelTime > 0 then
    local curServerTime = TimeUtil:GetServerTimeS()
    return curServerTime >= serverData.iDelTime
  end
end

function Form_CollectionEmail:GetContentRewardList(rewardList)
  if not rewardList then
    return
  end
  local emailFJItemDataList = {}
  local curChooseEmailData = self.m_allShowEmailItemDataList[self.m_curChooseIndex]
  local isRcv = curChooseEmailData.mailData.serverData.iRcvAttachTime ~= 0
  for i, v in ipairs(rewardList) do
    local tempData = {isChoose = isRcv, itemData = v}
    emailFJItemDataList[#emailFJItemDataList + 1] = tempData
  end
  return emailFJItemDataList
end

function Form_CollectionEmail:AddEventListeners()
  self:addEventListener("eGameEvent_Email_DelCollectEmail", handler(self, self.OnEventDelCollectEmail))
end

function Form_CollectionEmail:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CollectionEmail:OnEventDelCollectEmail(emailIDList)
  log.info("Form_CollectionEmail OnEventDelEmail emailIDList : ", tostring(emailIDList))
  if not emailIDList then
    return
  end
  local curChooseEmailData = self.m_allShowEmailItemDataList[self.m_curChooseIndex]
  if not curChooseEmailData then
    return
  end
  local curEmailID = curChooseEmailData.mailData.serverData.iMailId
  local removeCurChoose = false
  for _, v in pairs(emailIDList) do
    if v == curEmailID then
      removeCurChoose = true
    end
    self:RemoveMailDataByID(v)
  end
  local allItemNum = #self.m_allShowEmailItemDataList
  if allItemNum <= 0 then
    self:FreshUI()
  elseif removeCurChoose == true then
    local lastChooseItem = self.m_allShowEmailItemDataList[self.m_curChooseIndex]
    if lastChooseItem then
      lastChooseItem.isChoose = false
    end
    self.m_curChooseIndex = defaultChooseIndex
    local curChooseItem = self.m_allShowEmailItemDataList[self.m_curChooseIndex]
    if curChooseItem then
      curChooseItem.isChoose = true
    end
    self:FreshUI()
  else
    self:FreshUI()
  end
end

function Form_CollectionEmail:FreshUI()
  if not self.m_allShowEmailItemDataList or #self.m_allShowEmailItemDataList <= 0 then
    self:ShowEmptyNode()
  else
    self:InitShowEmailList()
  end
end

function Form_CollectionEmail:ShowEmptyNode()
  self.m_bg_01:SetActive(false)
  self.m_bg_02:SetActive(false)
  self.m_bg_empty:SetActive(true)
end

function Form_CollectionEmail:InitShowEmailList()
  self.m_bg_01:SetActive(true)
  self.m_bg_02:SetActive(true)
  self.m_bg_empty:SetActive(false)
  local curCollectEmailNum = #self.m_allShowEmailItemDataList
  local maxCollectNum = tonumber(ConfigManager:GetGlobalSettingsByKey("CollectMailMaxNum"))
  self.m_txt_collectnum_Text.text = curCollectEmailNum .. "/" .. maxCollectNum
  self.m_luaEmailListInfinityGrid:ShowItemList(self.m_allShowEmailItemDataList, true)
  if #self.m_allShowEmailItemDataList <= MailLimitCount then
    self.m_email_list_scroll_rect.movementType = ScrollRect_MovementType.Clamped
  else
    self.m_email_list_scroll_rect.movementType = ScrollRect_MovementType.Elastic
  end
  self:FreshShowContent()
end

function Form_CollectionEmail:FreshShowContent()
  if not self.m_curChooseIndex then
    return
  end
  self.m_bg_02:SetActive(true)
  local emailData = self.m_allShowEmailItemDataList[self.m_curChooseIndex]
  if not emailData then
    return
  end
  local serverData = emailData.mailData.serverData
  local templateId = serverData.iTemplateId
  local templateCfg = emailData.mailData.templateConfigData or {}
  local titleStr = templateId ~= 0 and templateCfg.m_mTitle or serverData.sTitle
  if serverData.mTitleParam and next(serverData.mTitleParam) then
    titleStr = EmailManager:ReplaceParamStrByServerDic(titleStr, serverData.mTitleParam)
  end
  local fromStr = templateId ~= 0 and templateCfg.m_mFrom or serverData.sFrom
  local contentStr = templateId ~= 0 and templateCfg.m_mContent or serverData.sContent
  if serverData.mTemplateParam and next(serverData.mTemplateParam) then
    contentStr = EmailManager:ReplaceParamStrByServerDic(contentStr, serverData.mTemplateParam)
  end
  local sendTime = emailData.mailData.serverData.iTime
  local timerStr = self:GetFormatSendTimeStr(sendTime)
  self.m_txt_title_Text.text = titleStr
  self.m_txt_name_Text.text = fromStr
  self.m_txt_time_Text.text = timerStr
  self.m_txt_Text.text = contentStr
  local attachmentItems = serverData.vItems
  if attachmentItems and next(attachmentItems) then
    self.m_img_bg_line02:SetActive(true)
    self.m_curChooseShowItemList = self:GetContentRewardList(attachmentItems)
    self.m_luaFjListInfinityGrid:ShowItemList(self.m_curChooseShowItemList, true)
    if #self.m_curChooseShowItemList <= MailFJLimitCount then
      self.m_fj_item_list_scroll_rect.movementType = ScrollRect_MovementType.Clamped
    else
      self.m_fj_item_list_scroll_rect.movementType = ScrollRect_MovementType.Elastic
    end
  else
    self.m_img_bg_line02:SetActive(false)
  end
end

function Form_CollectionEmail:DelCurChooseOverTimeEmail()
  if not self.m_allShowEmailItemDataList then
    return
  end
  if not self.m_curChooseIndex then
    return
  end
  table.remove(self.m_allShowEmailItemDataList, self.m_curChooseIndex)
  local allItemNum = #self.m_allShowEmailItemDataList
  if 0 < allItemNum then
    self.m_curChooseIndex = defaultChooseIndex
  end
  self:FreshUI()
end

function Form_CollectionEmail:OnEmailTabClick(index)
  local itemIndex = index
  if itemIndex == self.m_curChooseIndex then
    return
  end
  local lastChooseIndex = self.m_curChooseIndex
  local lastShowItem = self.m_luaEmailListInfinityGrid:GetShowItemByIndex(lastChooseIndex)
  if lastShowItem then
    lastShowItem:ChangeChooseStatus(false)
  else
    self.m_allShowEmailItemDataList[lastChooseIndex].isChoose = false
  end
  self.m_curChooseIndex = itemIndex
  local curChooseItem = self.m_luaEmailListInfinityGrid:GetShowItemByIndex(self.m_curChooseIndex)
  if curChooseItem then
    curChooseItem:ChangeChooseStatus(true)
  else
    self.m_allShowEmailItemDataList[self.m_curChooseIndex].isChoose = true
  end
  self:FreshShowContent()
end

function Form_CollectionEmail:OnFjItemClk(index, go)
  if not self.m_curChooseIndex then
    return
  end
  local chooseFJItemData = self.m_curChooseShowItemList[index]
  if chooseFJItemData then
    utils.openItemDetailPop(chooseFJItemData.itemData)
  end
end

function Form_CollectionEmail:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_CollectionEmail:OnBtnruleClicked()
  utils.popUpDirectionsUI({tipsID = 1039})
end

function Form_CollectionEmail:OnBtndeleteClicked()
  if not self.m_curChooseIndex then
    return
  end
  local emailData = self.m_allShowEmailItemDataList[self.m_curChooseIndex]
  if not emailData then
    return
  end
  local isOverTime = self:IsMailDataIsOverDelTime(emailData)
  if isOverTime == true then
    self:DelCurChooseOverTimeEmail()
    return
  end
  utils.CheckAndPushCommonTips({
    tipsID = 1213,
    func1 = function()
      EmailManager:ReqDelCollectMail(emailData.mailData.serverData.iMailId)
    end
  })
end

ActiveLuaUI("Form_CollectionEmail", Form_CollectionEmail)
return Form_CollectionEmail
