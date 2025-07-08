local UIItemBase = require("UI/Common/UIItemBase")
local UIGuildIconListItem = class("UIGuildIconListItem", UIItemBase)

function UIGuildIconListItem:OnInit()
  self.m_imgLogo = self.m_itemRootObj.transform:Find("offset/c_img_logo"):GetComponent(T_Image)
  self.m_lockObj = self.m_itemRootObj.transform:Find("offset/c_img_guild_bg_lock").gameObject
  self.m_selectObj = self.m_itemRootObj.transform:Find("offset/c_img_select").gameObject
end

function UIGuildIconListItem:OnFreshData()
  self:SetItemInfo(self.m_itemData)
end

function UIGuildIconListItem:SetItemInfo(itemData)
  ResourceUtil:CreateGuildIconById(self.m_imgLogo, itemData.m_BadgeID)
  self.m_selectObj:SetActive(itemData.is_selected or false)
  self.m_lockObj:SetActive(itemData.lockFlag)
end

function UIGuildIconListItem:OnChooseItem(flag)
  self.m_itemData.is_selected = flag
  self.m_selectObj:SetActive(flag)
end

return UIGuildIconListItem
