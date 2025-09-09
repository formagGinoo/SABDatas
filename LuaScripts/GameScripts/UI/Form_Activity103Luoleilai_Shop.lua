local Form_Activity103Luoleilai_Shop = class("Form_Activity103Luoleilai_Shop", require("UI/UIFrames/Form_Activity103Luoleilai_ShopUI"))

function Form_Activity103Luoleilai_Shop:SetInitParam(param)
end

function Form_Activity103Luoleilai_Shop:AfterInit()
  self.super.AfterInit(self)
  self.m_GoodsListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_shop_InfinityGrid, "HeroActivity/UIHeroActShopGoodsItem")
  self.m_GoodsListInfinityGrid:RegisterButtonCallback("c_btn_shopitem_buy", handler(self, self.OnShopBuyBtnClk))
  self:SetCellPerLine()
end

function Form_Activity103Luoleilai_Shop:OnActive()
  self.super.OnActive(self)
end

function Form_Activity103Luoleilai_Shop:OnInactive()
  self.super.OnInactive(self)
end

local fullscreen = true
ActiveLuaUI("Form_Activity103Luoleilai_Shop", Form_Activity103Luoleilai_Shop)
return Form_Activity103Luoleilai_Shop
