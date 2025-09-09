local Form_Activity108Shop = class("Form_Activity108Shop", require("UI/UIFrames/Form_Activity108ShopUI"))

function Form_Activity108Shop:SetInitParam(param)
end

function Form_Activity108Shop:AfterInit()
  self.super.AfterInit(self)
  self.m_GoodsListInfinityGrid = self:CreateInfinityGrid(self.m_scrollView_shop_InfinityGrid, "HeroActivity/UIHeroActShopGoodsItem")
  self.m_GoodsListInfinityGrid:RegisterButtonCallback("c_btn_shopitem_buy", handler(self, self.OnShopBuyBtnClk))
end

function Form_Activity108Shop:OnActive()
  self.super.OnActive(self)
end

function Form_Activity108Shop:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity108Shop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity108Shop:CheckShowEnterAnim()
end

local fullscreen = true
ActiveLuaUI("Form_Activity108Shop", Form_Activity108Shop)
return Form_Activity108Shop
