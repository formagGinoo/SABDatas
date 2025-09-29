local UIItemBase = require("UI/Common/UIItemBase")
local MinigameCardItem = class("MinigameCardItem", UIItemBase)

function MinigameCardItem:OnInit()
  self.m_stActivity = ActivityManager:GetActivityByID(self.m_itemData.activityId)
  self.isOpen = false
  self.ispair = false
  if self.m_itemInitData then
    self.OnItemClkCallback = self.m_itemInitData.OnItemClk
  end
end

function MinigameCardItem:OnFreshData()
  local card_id = self.m_itemData.cfg.m_CardID
  UILuaHelper.SetAtlasSprite(self.m_img_card_Image, self.m_itemData.cfg.m_Pic)
end

function MinigameCardItem:OnBtnflopClicked()
  self.OnItemClkCallback(self.m_itemIndex)
end

function MinigameCardItem:ShowCardFont()
  UILuaHelper.SetActive(self.m_pnl_mask, false)
  self.isOpen = true
end

function MinigameCardItem:ShowCardBack()
  UILuaHelper.SetActive(self.m_pnl_mask, true)
  self.isOpen = false
end

return MinigameCardItem
