local Form_Email = class("Form_Email", require("UI/UIFrames/Form_EmailUI"))
local ipairs = _ENV.ipairs
local next = _ENV.next
local defaultChooseIndex = 1
local MailLimitCount = 4
local MailFJLimitCount = 5
local EmailManager = _ENV.EmailManager

function Form_Email:SetInitParam(param)
end

function Form_Email:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_allShowEmailItemDataList = nil
  self.m_curChooseShowItemList = nil
  local initGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnEmailTabClick(itemIndex)
    end
  }
  self.m_luaEmailListInfinityGrid = self:CreateInfinityGrid(self.m_email_list_InfinityGrid, "Email/UIEmailItem", initGridData)
  local initFJGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnFjItemClk(itemIndex)
    end
  }
  self.m_luaFjListInfinityGrid = self:CreateInfinityGrid(self.m_fj_item_list_InfinityGrid, "Email/UIEmailFJItem", initFJGridData)
  self.m_curChooseIndex = nil
  self.m_email_list_scroll_rect = self.m_email_list:GetComponent("ScrollRect")
  self.m_fj_item_list_scroll_rect = self.m_fj_item_list:GetComponent("ScrollRect")
  local goBackBtnRoot = goRoot.transform:Find("panel_content/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  local resourceBarRoot = self.m_rootTrans:Find("panel_content/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self.m_textMeshProLink = self.m_txt.transform:GetComponent("TextMeshProLink")
  if self.m_textMeshProLink then
    self.m_textMeshProLink.UICamera = self:OwnerStack().Group:GetCamera()
  end
end

function Form_Email:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:InitData()
  self:FreshUI()
end

function Form_Email:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:ClearData()
end

function Form_Email:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Email:InitData()
  local isHaveNewEmail = EmailManager:GetIsHaveNewMail()
  if isHaveNewEmail then
    EmailManager:ReqGetNewMail()
  else
    self:FreshAllShowEmailItemData()
  end
end

function Form_Email:ClearData()
  self.m_curChooseIndex = nil
end

function Form_Email:FreshAllShowEmailItemData()
  local allEmailDataList = EmailManager:GetAllEmailDataList()
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

function Form_Email:FreshUI()
  if not self.m_allShowEmailItemDataList or #self.m_allShowEmailItemDataList <= 0 then
    self:ShowEmptyNode()
  else
    self:InitShowEmailList()
  end
end

function Form_Email:GetFormatSendTimeStr(timer)
  if not timer then
    return
  end
  local fmt = "%Y-%m-%d  %H:%M"
  local t = os.date(fmt, timer)
  return t
end

function Form_Email:SplitItemStrToArray(itemStr)
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

function Form_Email:CheckReqReadEmail()
  if not self.m_curChooseIndex then
    return
  end
  local curEmailData = self.m_allShowEmailItemDataList[self.m_curChooseIndex]
  if not curEmailData then
    return
  end
  local serverData = curEmailData.mailData.serverData
  local attachmentItems = serverData.vItems
  if attachmentItems and next(attachmentItems) and serverData.iRcvAttachTime == 0 then
    return
  end
  if curEmailData.mailData.serverData.iOpenTime == 0 then
    EmailManager:ReqReadMail(curEmailData.mailData.serverData.iMailId)
  end
end

function Form_Email:GetShowMailIndexByID(emailID)
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

function Form_Email:RemoveMailDataByID(emailID)
  if not emailID then
    return
  end
  for i, v in ipairs(self.m_allShowEmailItemDataList) do
    if v.mailData.serverData.iMailId == emailID then
      table.remove(self.m_allShowEmailItemDataList, i)
    end
  end
end

function Form_Email:IsMailFJItemHaveOverMaxNum(mailData)
  if not mailData then
    return
  end
  local serverData = mailData.mailData.serverData
  local attachmentItems = serverData.vItems
  local isHaveItemOverMax = false
  if attachmentItems and next(attachmentItems) then
    for i, v in ipairs(attachmentItems) do
      if ItemManager:IsItemAddNumOverMaxNum(v.itemID, v.itemNum) == true then
        isHaveItemOverMax = true
        return isHaveItemOverMax
      end
    end
  end
  return isHaveItemOverMax
end

function Form_Email:IsMailDataIsOverDelTime(mailData)
  if not mailData then
    return
  end
  local serverData = mailData.mailData.serverData
  if serverData and serverData.iDelTime ~= nil and serverData.iDelTime > 0 then
    local curServerTime = TimeUtil:GetServerTimeS()
    return curServerTime >= serverData.iDelTime
  end
end

function Form_Email:IsHaveReadOrAttachMailData()
  if not self.m_allShowEmailItemDataList then
    return
  end
  if #self.m_allShowEmailItemDataList <= 0 then
    return
  end
  local isCanDelMail = false
  for _, mailData in ipairs(self.m_allShowEmailItemDataList) do
    if mailData then
      local serverData = mailData.mailData.serverData
      local delTime = serverData.iDelTime
      local curServerTime = TimeUtil:GetServerTimeS()
      local isOverDelTime = delTime ~= 0 and delTime < curServerTime
      if serverData.vItems == nil or next(serverData.vItems) == nil then
        isCanDelMail = serverData.iOpenTime ~= 0 and not isOverDelTime
      else
        isCanDelMail = serverData.iOpenTime ~= 0 and serverData.iRcvAttachTime ~= 0 and not isOverDelTime
      end
      if isCanDelMail == true then
        return isCanDelMail
      end
    end
  end
  return isCanDelMail
end

function Form_Email:IsHaveCanAttachMailData()
  if not self.m_allShowEmailItemDataList then
    return
  end
  if #self.m_allShowEmailItemDataList <= 0 then
    return
  end
  local isCanAttach = false
  for _, mailData in ipairs(self.m_allShowEmailItemDataList) do
    if mailData then
      local serverData = mailData.mailData.serverData
      if serverData.vItems and next(serverData.vItems) and serverData.iRcvAttachTime == 0 and ItemManager:IsItemAddNumOverMaxNum(mailData) ~= true then
        isCanAttach = true
        return isCanAttach
      end
    end
  end
  return isCanAttach
end

function Form_Email:GetContentRewardList(rewardList)
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

function Form_Email:AddEventListeners()
  self:addEventListener("eGameEvent_Email_GetNewEmail", handler(self, self.OnEventGetNewEmail))
  self:addEventListener("eGameEvent_Email_ReadEmail", handler(self, self.OnEventReadEmail))
  self:addEventListener("eGameEvent_Email_DelEmail", handler(self, self.OnEventDelEmail))
  self:addEventListener("eGameEvent_Email_AttachEmail", handler(self, self.OnEventAttachEmail))
end

function Form_Email:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Email:OnEventGetNewEmail()
  self:FreshAllShowEmailItemData()
  self:FreshUI()
end

function Form_Email:OnEventReadEmail(emailID)
  log.info("Form_Email OnEventReadEmail emailID : ", emailID)
  if not emailID then
    return
  end
  local itemIndex = self:GetShowMailIndexByID(emailID)
  if itemIndex then
    self.m_email_list_InfinityGrid:ReBind(itemIndex - 1)
  end
end

function Form_Email:OnEventDelEmail(emailIDList)
  log.info("Form_Email OnEventDelEmail emailIDList : ", tostring(emailIDList))
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
      curChooseItem.isChoose = false
    end
    self:FreshUI()
  else
    self:FreshUI()
  end
end

function Form_Email:OnEventAttachEmail(emailID)
  log.info("Form_Email OnEventAttachEmail emailID : ", emailID)
  if emailID then
    local itemIndex = self:GetShowMailIndexByID(emailID)
    if itemIndex then
      self.m_email_list_InfinityGrid:ReBind(itemIndex - 1)
      if itemIndex == self.m_curChooseIndex then
        self:CheckReqReadEmail()
        self:FreshShowContent()
      end
    end
  else
    self.m_email_list_InfinityGrid:ReBindAll()
    self:CheckReqReadEmail()
    self:FreshShowContent()
  end
end

function Form_Email:ShowEmptyNode()
  self.m_bg_01:SetActive(false)
  self.m_bg_02:SetActive(false)
  self.m_bg_empty:SetActive(true)
end

function Form_Email:InitShowEmailList()
  self.m_bg_01:SetActive(true)
  self.m_bg_02:SetActive(true)
  self.m_bg_empty:SetActive(false)
  self:UnRegisterAllRedDotItem()
  self:RegisterOrUpdateRedDotItem(self.m_img_red_dot_rec_all, RedDotDefine.ModuleType.MailHaveRec)
  self.m_luaEmailListInfinityGrid:ShowItemList(self.m_allShowEmailItemDataList, true)
  if #self.m_allShowEmailItemDataList <= MailLimitCount then
    self.m_email_list_scroll_rect.movementType = ScrollRect_MovementType.Clamped
  else
    self.m_email_list_scroll_rect.movementType = ScrollRect_MovementType.Elastic
  end
  self:CheckReqReadEmail()
  self:FreshShowContent()
end

function Form_Email:FreshShowContent()
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
  self:RegisterOrUpdateRedDotItem(self.m_img_red_dot_rec, RedDotDefine.ModuleType.MainItemCanRec, serverData.iMailId)
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
  local isCanRcv = false
  if attachmentItems and next(attachmentItems) then
    self.m_img_bg_line02:SetActive(true)
    self.m_curChooseShowItemList = self:GetContentRewardList(attachmentItems)
    self.m_luaFjListInfinityGrid:ShowItemList(self.m_curChooseShowItemList, true)
    if #self.m_curChooseShowItemList <= MailFJLimitCount then
      self.m_fj_item_list_scroll_rect.movementType = ScrollRect_MovementType.Clamped
    else
      self.m_fj_item_list_scroll_rect.movementType = ScrollRect_MovementType.Elastic
    end
    if emailData.mailData.serverData.iRcvAttachTime == 0 then
      isCanRcv = true
    end
  else
    self.m_img_bg_line02:SetActive(false)
  end
  self.m_btn_delete:SetActive(not isCanRcv)
  self.m_btn_receive:SetActive(isCanRcv)
end

function Form_Email:DelCurChooseOverTimeEmail()
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

function Form_Email:OnEmailTabClick(index)
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
  self:CheckReqReadEmail()
  self:FreshShowContent()
end

function Form_Email:OnFjItemClk(index, go)
  if not self.m_curChooseIndex then
    return
  end
  local chooseFJItemData = self.m_curChooseShowItemList[index]
  if chooseFJItemData then
    utils.openItemDetailPop(chooseFJItemData.itemData)
  end
end

function Form_Email:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_EMAIL)
end

function Form_Email:OnBtnreceiveClicked()
  if not self.m_curChooseIndex then
    return
  end
  local emailData = self.m_allShowEmailItemDataList[self.m_curChooseIndex]
  if not emailData then
    return
  end
  local isOverItemMaxNum = self:IsMailFJItemHaveOverMaxNum(emailData)
  if isOverItemMaxNum == true then
    utils.CheckAndPushCommonTips({tipsID = 1212})
    return
  end
  EmailManager:ReqRcvMailAttach(emailData.mailData.serverData.iMailId)
end

function Form_Email:OnBtndeleteClicked()
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
      EmailManager:ReqDelMail(emailData.mailData.serverData.iMailId)
    end
  })
end

function Form_Email:OnBtndeleteallClicked()
  local isHaveReadOrAttachMailData = self:IsHaveReadOrAttachMailData()
  if isHaveReadOrAttachMailData == true then
    utils.CheckAndPushCommonTips({
      tipsID = 1214,
      func1 = function()
        EmailManager:ReqDelAllRcvMail()
      end
    })
  end
end

function Form_Email:OnBtndeceiveallClicked()
  local isHaveCanAttachMailData = self:IsHaveCanAttachMailData()
  if isHaveCanAttachMailData == true then
    EmailManager:ReqRcvAllMailAttach()
  end
end

function Form_Email:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Email", Form_Email)
return Form_Email
