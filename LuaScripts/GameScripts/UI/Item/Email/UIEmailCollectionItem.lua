local UIItemBase = require("UI/Common/UIItemBase")
local UIEmailCollectionItem = class("UIEmailCollectionItem", UIItemBase)

function UIEmailCollectionItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
end

function UIEmailCollectionItem:OnFreshData()
  self.m_emailItemData = self.m_itemData
  if not self.m_emailItemData then
    return
  end
  self:FreshItemUI()
  self:FreshChooseStatus(self.m_emailItemData.isChoose)
end

function UIEmailCollectionItem:GetFirstItemStrIDAndNum(itemDataList)
  if not itemDataList then
    return
  end
  return itemDataList[1].iID, itemDataList[1].iNum
end

function UIEmailCollectionItem:FreshItemUI()
  if not self.m_emailItemData then
    return
  end
  self:FreshItemName()
  self:FreshSpecialMailShow()
end

function UIEmailCollectionItem:FreshSpecialMailShow()
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
  UILuaHelper.SetActive(self.m_img_cake, templateCfg.m_CakeIcon == 1)
end

function UIEmailCollectionItem:FreshItemName()
  self.m_itemRootObj.name = self.m_itemIndex
end

function UIEmailCollectionItem:FreshChooseStatus(isChoose)
  UILuaHelper.SetActive(self.m_bg_tab_selected, isChoose)
end

function UIEmailCollectionItem:ChangeChooseStatus(isChoose)
  self.m_emailItemData.isChoose = isChoose
  self:FreshChooseStatus(isChoose)
end

function UIEmailCollectionItem:OnBtnEmailItemClicked()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIEmailCollectionItem
