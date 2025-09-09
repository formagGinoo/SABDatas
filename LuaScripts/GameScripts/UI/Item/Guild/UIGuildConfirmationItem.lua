local UIItemBase = require("UI/Common/UIItemBase")
local UIGuildConfirmationItem = class("UIGuildConfirmationItem", UIItemBase)

function UIGuildConfirmationItem:OnInit()
  local itemTrans = self.m_itemRootObj.transform
  local c_circle_head = itemTrans:Find("c_circle_head").gameObject
  self.playerHeadCom = self:createPlayerHead(c_circle_head)
end

function UIGuildConfirmationItem:OnFreshData()
  local itemData = self.m_itemData
  self.playerHeadCom:SetPlayerHeadInfo(itemData)
  self.m_txt_playername_Text.text = itemData.sRoleName
end

return UIGuildConfirmationItem
