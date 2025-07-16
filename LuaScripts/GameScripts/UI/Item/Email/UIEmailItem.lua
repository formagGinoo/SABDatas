local UIItemBase = require("UI/Common/UIItemBase")
local UIEmailItem = class("UIEmailItem", UIItemBase)

function UIEmailItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_itemWidget = self:createCommonItem(self.m_common_item)
end

function UIEmailItem:OnFreshData()
  self.m_emailItemData = self.m_itemData
  if not self.m_emailItemData then
    return
  end
  self:FreshItemUI()
  self:FreshChooseStatus(self.m_emailItemData.isChoose)
  self:CheckFreshRedDot()
end

function UIEmailItem:GetFirstItemStrIDAndNum(itemDataList)
  if not itemDataList then
    return
  end
  return itemDataList[1].iID, itemDataList[1].iNum
end

function UIEmailItem:FreshItemUI()
  if not self.m_emailItemData then
    return
  end
  self:FreshItemName()
  local templateCfg = self.m_emailItemData.mailData.templateConfigData or {}
  if templateCfg.m_TemplateMailType ~= nil and templateCfg.m_TemplateMailType ~= 0 then
    UILuaHelper.SetActive(self.m_pnl_normal_mail, false)
    UILuaHelper.SetActive(self.m_pnl_specialmail, true)
    self:FreshSpecialMailShow()
  else
    UILuaHelper.SetActive(self.m_pnl_normal_mail, true)
    UILuaHelper.SetActive(self.m_pnl_specialmail, false)
    self:FreshNormalMailShow()
  end
end

function UIEmailItem:FreshNormalMailShow()
  if not self.m_emailItemData then
    return
  end
  local serverData = self.m_emailItemData.mailData.serverData
  local templateId = serverData.iTemplateId
  local templateCfg = self.m_emailItemData.mailData.templateConfigData or {}
  local titleStr = templateId ~= 0 and templateCfg.m_mTitle or serverData.sTitle
  local fromStr = templateId ~= 0 and templateCfg.m_mFrom or serverData.sFrom
  local delTime = serverData.iDelTime
  local curServerTime = TimeUtil:GetServerTimeS()
  local leftTime = delTime - curServerTime
  leftTime = 0 < leftTime and leftTime or 0
  local leftTimeStr = TimeUtil:SecondsToFormatStrOnlyToMin(leftTime, true)
  self.m_txt_email_title_Text.text = titleStr
  self.m_txt_from_Text.text = fromStr
  self.m_txt_email_time_Text.text = leftTimeStr
  local attachmentItems = serverData.vItems
  local isCanRcv = false
  if attachmentItems and next(attachmentItems) and serverData.iRcvAttachTime == 0 then
    isCanRcv = true
    local itemID, _ = self:GetFirstItemStrIDAndNum(attachmentItems)
    local processData = ResourceUtil:GetProcessRewardData({iID = itemID, iNum = nil})
    self.m_itemWidget:SetItemInfo(processData)
  end
  self.m_itemWidget:SetActive(isCanRcv)
  local isRead = serverData.iOpenTime ~= 0
  UILuaHelper.SetActive(self.m_bg_tab_read, isRead)
  local isShowRead = not isCanRcv and isRead
  local isShowNoRead = not isCanRcv and not isRead
  UILuaHelper.SetActive(self.m_read_icon, isShowRead)
  UILuaHelper.SetActive(self.m_no_read_icon, isShowNoRead)
  local isImportant = serverData.bSticky
  UILuaHelper.SetActive(self.m_img_important, isImportant and not isRead)
  UILuaHelper.SetActive(self.m_img_bg_important, isImportant and not isRead)
end

function UIEmailItem:FreshSpecialMailShow()
  if not self.m_emailItemData then
    return
  end
  local serverData = self.m_emailItemData.mailData.serverData
  local templateId = serverData.iTemplateId
  local templateCfg = self.m_emailItemData.mailData.templateConfigData or {}
  if templateCfg.m_TemplateMailType == nil or templateCfg.m_TemplateMailType == 0 then
    return
  end
  local attachmentItems = serverData.vItems
  if attachmentItems == nil or next(attachmentItems) == nil then
    return
  end
  local titleStr = templateId ~= 0 and templateCfg.m_mTitle or serverData.sTitle
  local fromStr = templateId ~= 0 and templateCfg.m_mFrom or serverData.sFrom
  local delTime = serverData.iDelTime
  local curServerTime = TimeUtil:GetServerTimeS()
  local leftTime = delTime - curServerTime
  leftTime = 0 < leftTime and leftTime or 0
  local leftTimeStr = TimeUtil:SecondsToFormatStrOnlyToMin(leftTime, true)
  self.m_txt_title_specialmail_Text.text = titleStr
  self.m_txt_people_name_specialmail_Text.text = fromStr
  self.m_txt_email_time_specialmail_Text.text = leftTimeStr
  UILuaHelper.SetAtlasSprite(self.m_head_icon_Image, templateCfg.m_MailIcon)
  local isRcv = serverData.iRcvAttachTime ~= 0
  UILuaHelper.SetActive(self.m_bg_grey_specialmail, isRcv)
  UILuaHelper.SetActive(self.m_bg_normal_specialmail, not isRcv)
  UILuaHelper.SetActive(self.m_pnl_read_specialmail, isRcv)
end

function UIEmailItem:FreshItemName()
  self.m_itemRootObj.name = self.m_itemIndex
end

function UIEmailItem:CheckFreshRedDot()
  if not self.m_emailItemData then
    return
  end
  local serverData = self.m_emailItemData.mailData.serverData
  if not serverData then
    return
  end
  self:RegisterOrUpdateRedDotItem(self.m_img_redpoint, RedDotDefine.ModuleType.MainItem, serverData.iMailId)
end

function UIEmailItem:FreshChooseStatus(isChoose)
  UILuaHelper.SetActive(self.m_bg_tab_selected, isChoose)
end

function UIEmailItem:ChangeChooseStatus(isChoose)
  self.m_emailItemData.isChoose = isChoose
  self:FreshChooseStatus(isChoose)
end

function UIEmailItem:OnBtnEmailItemClicked()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIEmailItem
