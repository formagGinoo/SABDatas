local UIItemBase = require("UI/Common/UIItemBase")
local StatueItem = class("StatueItem", UIItemBase)

function StatueItem:OnInit()
  local button = self.m_itemRootObj:GetComponent("Button")
  button.onClick:RemoveAllListeners()
  button.onClick:AddListener(handler(self, self.OnItemClicked))
end

function StatueItem:OnFreshData()
  local server_data = StatueShowroomManager:GetServerData()
  self.m_item_icon:SetActive(server_data.iLevel >= self.m_itemData.m_StatueLevel)
  self.m_item_icon_lock:SetActive(server_data.iLevel < self.m_itemData.m_StatueLevel)
  self.m_item_lv_num_Text.text = self.m_itemData.m_StatueLevel
  UILuaHelper.SetAtlasSprite(self.m_item_icon_Image, self.m_itemData.m_StatuePic)
  UILuaHelper.SetAtlasSprite(self.m_item_icon_lock_Image, self.m_itemData.m_StatuePic)
end

function StatueItem:OnItemClicked()
  StackPopup:Push(UIDefines.ID_FORM_CASTLESTATUEDETAILS, self.m_itemIndex)
end

return StatueItem
