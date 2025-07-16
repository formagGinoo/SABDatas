local Form_Email = class("Form_Email", require("UI/UIFrames/Form_EmailUI"))
local ipairs = _ENV.ipairs
local next = _ENV.next
local defaultChooseIndex = 1
local CData_ItemInstance = CS.CData_Item.GetInstance()
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
  self.m_cacheFJItemIconWidget = {}
  self.m_cacheMailItemIconWidget = {}
  self.m_curChooseIndex = nil
  self.m_email_list_InfinityGrid:RegisterBindCallback(handler(self, self.OnEmailItemBind))
  self.m_email_list_InfinityGrid:RegisterButtonCallback("c_email_tab_item", handler(self, self.OnEmailTabClick))
  self.m_email_list_scroll_rect = self.m_email_list:GetComponent("ScrollRect")
  self.m_fj_item_list_InfinityGrid:RegisterBindCallback(handler(self, self.OnFjItemBind))
  self.m_fj_item_list_InfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnFjItemClk))
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
  self:RemoveEventListeners()
  self.m_newEmailEventHandle = self:addEventListener("eGameEvent_Email_GetNewEmail", handler(self, self.OnEventGetNewEmail))
  self.m_readEmailHandle = self:addEventListener("eGameEvent_Email_ReadEmail", handler(self, self.OnEventReadEmail))
  self.m_delEmailHandle = self:addEventListener("eGameEvent_Email_DelEmail", handler(self, self.OnEventDelEmail))
  self.m_attachEmailHandle = self:addEventListener("eGameEvent_Email_AttachEmail", handler(self, self.OnEventAttachEmail))
  self:InitData()
  self:FreshUI()
end

function Form_Email:OnInactive()
  self.super.OnInactive(self)
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
  if self.m_cacheFJItemIconWidget then
    self.m_cacheFJItemIconWidget = {}
  end
  if self.m_cacheMailItemIconWidget then
    self.m_cacheMailItemIconWidget = {}
  end
  self.m_curChooseIndex = nil
end

function Form_Email:FreshAllShowEmailItemData()
  local allEmailDataList = EmailManager:GetAllEmailDataList()
  local showItemList = {}
  if allEmailDataList and next(allEmailDataList) then
    for _, v in ipairs(allEmailDataList) do
      if v then
        showItemList[#showItemList + 1] = v
      end
    end
  end
  self.m_allShowEmailItemDataList = showItemList
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

function Form_Email:GetFirstItemStrIDAndNum(itemDataList)
  if not itemDataList then
    return
  end
  return itemDataList[1].iID, itemDataList[1].iNum
end

function Form_Email:CheckReqReadEmail()
  if not self.m_curChooseIndex then
    return
  end
  local curEmailData = self.m_allShowEmailItemDataList[self.m_curChooseIndex]
  if not curEmailData then
    return
  end
  local serverData = curEmailData.serverData
  local attachmentItems = serverData.vItems
  if attachmentItems and next(attachmentItems) and serverData.iRcvAttachTime == 0 then
    return
  end
  if curEmailData.serverData.iOpenTime == 0 then
    EmailManager:ReqReadMail(curEmailData.serverData.iMailId)
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
    if emailID == v.serverData.iMailId then
      return i
    end
  end
end

function Form_Email:RemoveMailDataByID(emailID)
  if not emailID then
    return
  end
  for i, v in ipairs(self.m_allShowEmailItemDataList) do
    if v.serverData.iMailId == emailID then
      table.remove(self.m_allShowEmailItemDataList, i)
    end
  end
end

function Form_Email:IsMailFJItemHaveOverMaxNum(mailData)
  if not mailData then
    return
  end
  local serverData = mailData.serverData
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
  local serverData = mailData.serverData
  if serverData and serverData.iDelTime then
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
      local serverData = mailData.serverData
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
      local serverData = mailData.serverData
      if serverData.vItems and next(serverData.vItems) and serverData.iRcvAttachTime == 0 and ItemManager:IsItemAddNumOverMaxNum(mailData) ~= true then
        isCanAttach = true
        return isCanAttach
      end
    end
  end
  return isCanAttach
end

function Form_Email:RemoveEventListeners()
  if self.m_newEmailEventHandle then
    self:removeEventListener("eGameEvent_Email_GetNewEmail", self.m_newEmailEventHandle)
    self.m_newEmailEventHandle = nil
  end
  if self.m_readEmailHandle then
    self:removeEventListener("eGameEvent_Email_ReadEmail", self.m_readEmailHandle)
    self.m_readEmailHandle = nil
  end
  if self.m_delEmailHandle then
    self:removeEventListener("eGameEvent_Email_DelEmail", self.m_delEmailHandle)
    self.m_delEmailHandle = nil
  end
  if self.m_attachEmailHandle then
    self:removeEventListener("eGameEvent_Email_AttachEmail", self.m_attachEmailHandle)
    self.m_attachEmailHandle = nil
  end
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
  local curEmailID = curChooseEmailData.serverData.iMailId
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
    self.m_curChooseIndex = defaultChooseIndex
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
  if self.m_curChooseIndex == nil then
    self.m_curChooseIndex = defaultChooseIndex
  end
  self:UnRegisterAllRedDotItem()
  self:RegisterOrUpdateRedDotItem(self.m_img_red_dot_rec_all, RedDotDefine.ModuleType.MailHaveRec)
  self.m_email_list_InfinityGrid:Clear()
  self.m_email_list_InfinityGrid.TotalItemCount = #self.m_allShowEmailItemDataList
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
  local serverData = emailData.serverData
  local templateId = emailData.iTemplateId
  local templateCfg = emailData.templateConfigData or {}
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
  local sendTime = emailData.serverData.iTime
  local timerStr = self:GetFormatSendTimeStr(sendTime)
  self.m_txt_title_Text.text = titleStr
  self.m_txt_name_Text.text = fromStr
  self.m_txt_time_Text.text = timerStr
  self.m_txt_Text.text = contentStr
  local attachmentItems = serverData.vItems
  local isCanRcv = false
  if attachmentItems and next(attachmentItems) then
    self.m_img_bg_line02:SetActive(true)
    self.m_curChooseShowItemList = attachmentItems
    self.m_fj_item_list_InfinityGrid:Clear()
    self.m_fj_item_list_InfinityGrid.TotalItemCount = #self.m_curChooseShowItemList
    if #self.m_curChooseShowItemList <= MailFJLimitCount then
      self.m_fj_item_list_scroll_rect.movementType = ScrollRect_MovementType.Clamped
    else
      self.m_fj_item_list_scroll_rect.movementType = ScrollRect_MovementType.Elastic
    end
    if emailData.serverData.iRcvAttachTime == 0 then
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

function Form_Email:OnEmailItemBind(templateCache, gameObject, index)
  local itemIndex = index + 1
  gameObject.name = itemIndex
  local isSelect = itemIndex == self.m_curChooseIndex
  templateCache:GameObject("c_bg_tab_selected"):SetActive(isSelect)
  local emailData = self.m_allShowEmailItemDataList[itemIndex]
  if not emailData then
    return
  end
  local serverData = emailData.serverData
  local templateId = serverData.iTemplateId
  local templateCfg = emailData.templateConfigData or {}
  self:RegisterOrUpdateRedDotItem(templateCache:GameObject("c_img_redpoint"), RedDotDefine.ModuleType.MainItem, serverData.iMailId)
  local titleStr = templateId ~= 0 and templateCfg.m_mTitle or serverData.sTitle
  local fromStr = templateId ~= 0 and templateCfg.m_mFrom or serverData.sFrom
  local delTime = serverData.iDelTime
  local curServerTime = TimeUtil:GetServerTimeS()
  local leftTime = delTime - curServerTime
  leftTime = 0 < leftTime and leftTime or 0
  local leftTimeStr = TimeUtil:SecondsToFormatStrOnlyToMin(leftTime, true)
  templateCache:TMPPro("c_txt_email_title").text = titleStr
  templateCache:TMPPro("c_txt_people_name").text = fromStr
  templateCache:TMPPro("c_txt_email_time").text = leftTimeStr
  local attachmentItems = serverData.vItems
  local isCanRcv = false
  if attachmentItems and next(attachmentItems) and serverData.iRcvAttachTime == 0 then
    isCanRcv = true
    local itemID, _ = self:GetFirstItemStrIDAndNum(attachmentItems)
    local gameObjectHashCode = gameObject:GetHashCode()
    if not self.m_cacheMailItemIconWidget[gameObjectHashCode] then
      local tempWidgetCom = self:createCommonItem(templateCache:GameObject("c_common_item"))
      self.m_cacheMailItemIconWidget[gameObjectHashCode] = tempWidgetCom
    end
    local iconWidget = self.m_cacheMailItemIconWidget[gameObjectHashCode]
    local processData = ResourceUtil:GetProcessRewardData({iID = itemID, iNum = nil})
    iconWidget:SetItemInfo(processData)
  end
  templateCache:GameObject("c_common_item"):SetActive(isCanRcv)
  local isRead = serverData.iOpenTime ~= 0
  templateCache:GameObject("c_bg_tab_red"):SetActive(isRead)
  local isShowRead = not isCanRcv and isRead
  local isShowNoRead = not isCanRcv and not isRead
  templateCache:GameObject("c_img_icon02"):SetActive(isShowRead)
  templateCache:GameObject("c_img_icon01"):SetActive(isShowNoRead)
  local isImportant = serverData.bSticky
  templateCache:GameObject("c_img_important"):SetActive(isImportant and not isRead)
end

function Form_Email:OnEmailTabClick(index, go)
  local itemIndex = index + 1
  if itemIndex == self.m_curChooseIndex then
    return
  end
  local lastChooseIndex = self.m_curChooseIndex
  self.m_curChooseIndex = itemIndex
  if lastChooseIndex ~= nil then
    self.m_email_list_InfinityGrid:ReBind(lastChooseIndex - 1)
  end
  self.m_email_list_InfinityGrid:ReBind(index)
  self:CheckReqReadEmail()
  self:FreshShowContent()
end

function Form_Email:OnFjItemBind(templateCache, gameObject, index)
  local itemIndex = index + 1
  local fjItemData = self.m_curChooseShowItemList[itemIndex]
  if not fjItemData then
    return
  end
  local gameObjectHashCode = gameObject:GetHashCode()
  if not self.m_cacheFJItemIconWidget[gameObjectHashCode] then
    self.m_cacheFJItemIconWidget[gameObjectHashCode] = self:createCommonItem(templateCache:GameObject("c_common_item"))
  end
  local iconWidget = self.m_cacheFJItemIconWidget[gameObjectHashCode]
  local processData = ResourceUtil:GetProcessRewardData({
    iID = fjItemData.iID,
    iNum = fjItemData.iNum
  })
  iconWidget:SetItemInfo(processData)
  iconWidget:SetItemIconClickCB(function()
    self:OnFjItemClk(itemIndex - 1, templateCache:GameObject("c_common_item"))
  end)
  local curChooseEmailData = self.m_allShowEmailItemDataList[self.m_curChooseIndex]
  if curChooseEmailData.serverData.iRcvAttachTime ~= 0 then
    iconWidget:SetItemHaveGetActive(true)
  else
    iconWidget:SetItemHaveGetActive(false)
  end
end

function Form_Email:OnFjItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  if not self.m_curChooseIndex then
    return
  end
  local chooseFJItemData = self.m_curChooseShowItemList[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop(chooseFJItemData)
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
  EmailManager:ReqRcvMailAttach(emailData.serverData.iMailId)
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
      EmailManager:ReqDelMail(emailData.serverData.iMailId)
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
