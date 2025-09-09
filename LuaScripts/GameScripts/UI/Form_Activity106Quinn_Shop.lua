local Form_Activity106Quinn_Shop = class("Form_Activity106Quinn_Shop", require("UI/UIFrames/Form_Activity106Quinn_ShopUI"))

function Form_Activity106Quinn_Shop:SetInitParam(param)
end

function Form_Activity106Quinn_Shop:AfterInit()
  self.super.AfterInit(self)
  self.m_GoodsListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_shop_InfinityGrid, "HeroActivity/UIHeroActShopGoodsItem")
  self.m_GoodsListInfinityGrid:RegisterButtonCallback("c_btn_shopitem_buy", handler(self, self.OnShopBuyBtnClk))
  self:SetCellPerLine()
end

function Form_Activity106Quinn_Shop:OnActive()
  self.super.OnActive(self)
end

function Form_Activity106Quinn_Shop:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity106Quinn_Shop:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Activity106Quinn_Shop", Form_Activity106Quinn_Shop)
return Form_Activity106Quinn_Shop
