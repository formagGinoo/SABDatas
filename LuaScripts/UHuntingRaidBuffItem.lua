local UIItemBase = require("UI/Common/UIItemBase")
local UHuntingRaidBuffItem = class("UHuntingRaidBuffItem", UIItemBase)

function UHuntingRaidBuffItem:OnInit()
end

function UHuntingRaidBuffItem:OnFreshData()
  if not self.m_itemData then
    return
  end
  self:FreshUI()
end

function UHuntingRaidBuffItem:FreshUI()
  local cfg = self.m_itemData.cfg
  UILuaHelper.SetAtlasSprite(self.m_img_iconskillbuff_Image, cfg.m_Icon)
  UILuaHelper.SetActive(self.m_img_select, self.m_itemData.is_select)
  UILuaHelper.SetActive(self.m_img_buffchoose, self.m_itemData.is_choose)
end

return UHuntingRaidBuffItem
