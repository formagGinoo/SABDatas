local UIItemBase = require("UI/Common/UIItemBase")
local UIShopGoodsItem = class("UIShopGoodsItem", UIItemBase)

function UIShopGoodsItem:OnInit()
  self.m_itemIcon = self:createShopGoodsItem(self.m_itemTemplateCache:GameObject("c_common_shopitem"))
end

function UIShopGoodsItem:OnFreshData()
  self.m_itemIcon:SetItemInfo(self.m_itemData)
end

function UIShopGoodsItem:OnUpdate(dt)
end

return UIShopGoodsItem
